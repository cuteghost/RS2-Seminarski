import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/screens/partner_screens/partner_register_screen.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:ebooking/widgets/edit_email_modal.dart';
import 'package:ebooking/widgets/edit_password_modal.dart';
import 'package:ebooking/widgets/edit_personal_details_modal.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/utils/session_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await Provider.of<ProfileProvider>(context, listen: false).getProfile();
    } on ApiException catch (e) {
      // Without this the screen sat on its spinner forever whenever the
      // profile could not be loaded.
      if (!mounted) return;
      setState(() => _loadError = e.message);
    }
  }

  void _openModal(Widget modal) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: modal,
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account and everything in it. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    try {
      await Provider.of<AuthProvider>(context, listen: false).deleteAccount();
    } on ApiException catch (error) {
      // The call used to be fire-and-forget, so a refused delete still sent
      // the user to the login screen with the account intact.
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }
    if (!mounted) return;
    await endSession(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Watched, not a local copy: a saved display name or email reaches this
    // header the moment the provider holds it, without leaving the screen.
    final profile = Provider.of<ProfileProvider>(context).profile;

    if (profile == null) {
      return Scaffold(
        body: Center(
          child: _loadError == null
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _loadError!,
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: profile.profilePicture.isEmpty
                          ? null
                          : MemoryImage(profile.profilePicture),
                      child: profile.profilePicture.isEmpty
                          ? Icon(PhosphorIcons.user(), size: 24)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            '${profile.firstName} ${profile.lastName}',
                            style: textTheme.bodySmall,
                          ),
                          Text(
                            profile.emailAddress,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Text(
                  'Welcome, here you can edit your profile.',
                  style: textTheme.bodySmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 6),
                child: Text('ACCOUNT', style: textTheme.labelSmall),
              ),
              _ProfileRow(
                icon: PhosphorIcons.userCircle(),
                label: 'Personal details',
                onTap: () =>
                    _openModal(EditPersonalDetailsModal(profile: profile)),
              ),
              _ProfileRow(
                icon: PhosphorIcons.envelopeSimple(),
                label: 'Email address',
                onTap: profile.isSocialAccount
                    ? null
                    : () => _openModal(
                        EditEmailModal(currentEmail: profile.emailAddress),
                      ),
                disabledReason: profile.isSocialAccount
                    ? 'Managed by ${profile.socialProvider}'
                    : null,
              ),
              _ProfileRow(
                icon: PhosphorIcons.lockSimple(),
                label: 'Password',
                onTap: profile.isSocialAccount
                    ? null
                    : () => _openModal(const EditPasswordModal()),
                disabledReason: profile.isSocialAccount
                    ? 'Managed by ${profile.socialProvider}'
                    : null,
              ),
              if (profile.isSocialAccount)
                _ProfileRow(
                  icon: PhosphorIcons.linkSimple(),
                  label: 'Linked accounts',
                  trailing: profile.socialProvider,
                  isLast: true,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
                child: Text('HOSTING', style: textTheme.labelSmall),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  onTap: () {
                    // Pushed, not replaced: the form has a back arrow, and
                    // replacing left the system back button with nowhere to go
                    // while the arrow returned here.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PartnerRegisterScreen(userId: profile.id),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppColors.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.houseLine(),
                          size: 22,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Become a partner',
                                style: textTheme.titleMedium,
                              ),
                              Text(
                                'List your place and take bookings',
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          PhosphorIcons.caretRight(),
                          size: 15,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
                child: Text('PREFERENCES', style: textTheme.labelSmall),
              ),
              _ProfileRow(
                icon: PhosphorIcons.signOut(),
                label: 'Log out',
                labelColor: AppColors.text,
                isLast: true,
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final (signedOut, message) = await signOut(context);
                  if (!signedOut) {
                    messenger.showSnackBar(SnackBar(content: Text(message)));
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: GestureDetector(
                  onTap: _confirmDelete,
                  child: Text(
                    'Delete account',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final Color? labelColor;
  final bool isLast;
  final VoidCallback? onTap;
  final String? disabledReason;

  const _ProfileRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.labelColor,
    this.isLast = false,
    this.onTap,
    this.disabledReason,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDisabled = disabledReason != null;
    return InkWell(
      onTap: isDisabled ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: isDisabled ? AppColors.textTertiary : AppColors.accent,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodyLarge?.copyWith(
                        color: isDisabled
                            ? AppColors.textTertiary
                            : (labelColor ?? AppColors.text),
                      ),
                    ),
                    if (isDisabled)
                      Text(
                        disabledReason!,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                Text(trailing!, style: textTheme.bodySmall),
                const SizedBox(width: 8),
              ],
              if (onTap != null && !isDisabled)
                Icon(
                  PhosphorIcons.caretRight(),
                  size: 15,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
