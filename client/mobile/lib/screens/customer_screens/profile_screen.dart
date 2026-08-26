import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/profile_model.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/screens/partner_screens/partner_register_screen.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:ebooking/widgets/edit_email_modal.dart';
import 'package:ebooking/widgets/edit_password_modal.dart';
import 'package:ebooking/widgets/edit_personal_details_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebooking/screens/login_screen.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile =
        await Provider.of<ProfileProvider>(context, listen: false).getProfile();
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  void _openModal(Widget modal) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: modal,
      ),
    ).then((updated) {
      // Profile fields are mutated in place on success (see ProfileProvider),
      // so a rebuild is enough -- no need to re-fetch from the server.
      if (updated == true) setState(() {});
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
            'This permanently deletes your account and everything in it. This cannot be undone.'),
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
    Provider.of<AuthProvider>(context, listen: false).deleteAccount();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profile = _profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                      backgroundImage: FileImage(profile.profilePicture),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile.firstName} ${profile.lastName}',
                            style: textTheme.headlineMedium?.copyWith(fontSize: 20),
                          ),
                          Text(profile.emailAddress, style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _openModal(
                          EditPersonalDetailsModal(profile: profile)),
                      child: const Text('Edit'),
                    ),
                  ],
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
                trailing: 'Verified',
                onTap: () => _openModal(
                    EditEmailModal(currentEmail: profile.emailAddress)),
              ),
              _ProfileRow(
                icon: PhosphorIcons.lockSimple(),
                label: 'Password',
                onTap: () => _openModal(const EditPasswordModal()),
              ),
              if (profile.socialLink.isNotEmpty)
                _ProfileRow(
                  icon: PhosphorIcons.linkSimple(),
                  label: 'Linked accounts',
                  trailing: profile.socialLink,
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
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PartnerRegisterScreen(userId: profile.id)));
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
                        Icon(PhosphorIcons.houseLine(),
                            size: 22, color: AppColors.accent),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Become a partner',
                                  style: textTheme.titleMedium),
                              Text('List your place and take bookings',
                                  style: textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Icon(PhosphorIcons.caretRight(),
                            size: 15, color: AppColors.textTertiary),
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
                onTap: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: GestureDetector(
                  onTap: _confirmDelete,
                  child: Text(
                    'Delete account',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.error),
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

  const _ProfileRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.labelColor,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
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
              Icon(icon, size: 19, color: AppColors.accent),
              const SizedBox(width: 13),
              Expanded(
                child: Text(label,
                    style: textTheme.bodyLarge
                        ?.copyWith(color: labelColor ?? AppColors.text)),
              ),
              if (trailing != null) ...[
                Text(trailing!, style: textTheme.bodySmall),
                const SizedBox(width: 8),
              ],
              if (onTap != null)
                Icon(PhosphorIcons.caretRight(),
                    size: 15, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
