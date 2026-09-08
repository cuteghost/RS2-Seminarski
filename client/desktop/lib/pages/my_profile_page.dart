import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/providers/profile_provider.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    await context.read<ProfileProvider>().getProfile();
    if (!mounted) return;
    final error = context.read<ProfileProvider>().error;
    setState(() {
      _loading = false;
      _loadError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      child: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (_loading) {
            return const NLoading(label: 'Loading profile…');
          }
          if (_loadError != null) {
            return NErrorState(message: _loadError!, onRetry: _load);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const NPageHeader(
                title: 'My Profile',
                subtitle: 'Personal details, email address and password of the logged-in account.',
              ),
              const SizedBox(height: AppSpace.x6),
              _PersonalDetailsCard(profile: provider.profile),
              const SizedBox(height: AppSpace.x6),
              _EmailCard(profile: provider.profile),
              const SizedBox(height: AppSpace.x6),
              const _PasswordCard(),
            ],
          );
        },
      ),
    );
  }
}

class _PersonalDetailsCard extends StatefulWidget {
  final Profile profile;

  const _PersonalDetailsCard({required this.profile});

  @override
  State<_PersonalDetailsCard> createState() => _PersonalDetailsCardState();
}

class _PersonalDetailsCardState extends State<_PersonalDetailsCard> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayName;
  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late DateTime? _birthDate;
  late UserGender _gender;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController(text: widget.profile.displayName);
    _firstName = TextEditingController(text: widget.profile.firstName);
    _lastName = TextEditingController(text: widget.profile.lastName);
    _birthDate = DateTime.tryParse(widget.profile.dob);
    _gender = widget.profile.gender;
  }

  @override
  void didUpdateWidget(covariant _PersonalDetailsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Provider se osvježi i poslije snimanja email adrese ili lozinke.
    // `_hasChanges` u tom trenutku već poredi kontrole sa novim profilom, pa
    // ako je i dalje "false" ovdje nema šta da se prepiše; ako je "true" znači
    // da korisnik ima nesačuvanu izmjenu u ovoj sekciji, pa se ne dira.
    if (_saving || _hasChanges) return;
    _displayName.text = widget.profile.displayName;
    _firstName.text = widget.profile.firstName;
    _lastName.text = widget.profile.lastName;
    _birthDate = DateTime.tryParse(widget.profile.dob);
    _gender = widget.profile.gender;
  }

  @override
  void dispose() {
    _displayName.dispose();
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    final original = widget.profile;
    return _displayName.text.trim() != original.displayName ||
        _firstName.text.trim() != original.firstName ||
        _lastName.text.trim() != original.lastName ||
        _birthDate?.toIso8601String().split('T').first != original.dob ||
        _gender != original.gender;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now.subtract(const Duration(days: 1)),
      helpText: 'Date of birth',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_birthDate == null) {
      setState(() => _error = 'Select a date of birth.');
      return;
    }

    setState(() => _saving = true);
    final provider = context.read<ProfileProvider>();
    final updated = Profile(
      id: widget.profile.id,
      displayName: _displayName.text.trim(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      emailAddress: widget.profile.emailAddress,
      dob: _birthDate!.toIso8601String().split('T').first,
      gender: _gender,
      role: widget.profile.role,
      socialLink: widget.profile.socialLink,
      isActive: widget.profile.isActive,
      profilePicture: widget.profile.profilePicture,
    );

    final result = await provider.updatePersonalDetails(updated);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.success) {
      nToast(context, result.message);
    } else {
      setState(() => _error = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return NCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                NInitialsAvatar(name: widget.profile.fullName, size: 44),
                const SizedBox(width: AppSpace.x4),
                Text('Personal details', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpace.x6),
            NField(
              label: 'Display name',
              child: TextFormField(
                controller: _displayName,
                enabled: !_saving,
                onChanged: (_) => setState(() {}),
                validator: (v) => _text(v, 3, 50, 'Display name'),
              ),
            ),
            const SizedBox(height: AppSpace.x4),
            NField(
              label: 'First name',
              child: TextFormField(
                controller: _firstName,
                enabled: !_saving,
                onChanged: (_) => setState(() {}),
                validator: (v) => _text(v, 3, 15, 'First name'),
              ),
            ),
            const SizedBox(height: AppSpace.x4),
            NField(
              label: 'Last name',
              child: TextFormField(
                controller: _lastName,
                enabled: !_saving,
                onChanged: (_) => setState(() {}),
                validator: (v) => _text(v, 3, 30, 'Last name'),
              ),
            ),
            const SizedBox(height: AppSpace.x4),
            NField(
              label: 'Date of birth',
              child: OutlinedButton.icon(
                onPressed: _saving ? null : _pickBirthDate,
                icon: Icon(PhosphorIcons.calendarBlank(), size: 14),
                label: Text(_birthDate == null
                    ? 'Select date'
                    : dateFormat.format(_birthDate!)),
              ),
            ),
            const SizedBox(height: AppSpace.x4),
            NField(
              label: 'Gender',
              child: DropdownButtonFormField<UserGender>(
                initialValue: _gender,
                isExpanded: true,
                items: [
                  for (final gender in UserGender.values)
                    DropdownMenuItem<UserGender>(
                      value: gender,
                      child: Text(gender.label),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) setState(() => _gender = value);
                      },
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpace.x4),
              _FormError(message: _error!),
            ],
            const SizedBox(height: AppSpace.x6),
            Align(
              alignment: Alignment.centerRight,
              child: _SaveButton(
                saving: _saving,
                disabledReason: !_hasChanges ? 'No changes to save.' : null,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailCard extends StatefulWidget {
  final Profile profile;

  const _EmailCard({required this.profile});

  @override
  State<_EmailCard> createState() => _EmailCardState();
}

class _EmailCardState extends State<_EmailCard> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      _email.text.trim().isNotEmpty &&
      _email.text.trim() != widget.profile.emailAddress;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final provider = context.read<ProfileProvider>();
    final result = await provider.updateEmail(_email.text, _password.text);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.success) {
      _email.clear();
      _password.clear();
      nToast(context, result.message);
    } else {
      setState(() => _error = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Email address', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpace.x2),
            Text(
              'Current address: ${widget.profile.emailAddress}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpace.x4),
            NField(
              label: 'New email address',
              child: TextFormField(
                controller: _email,
                enabled: !_saving,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'name@domain.ba'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  final regex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
                  if (!regex.hasMatch(text)) {
                    return 'Enter a valid email address in the format: name@domain.ba';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpace.x4),
            NField(
              label: 'Current password',
              child: TextFormField(
                controller: _password,
                obscureText: true,
                enabled: !_saving,
                validator: (v) => (_hasChanges && (v ?? '').isEmpty)
                    ? 'Enter your current password to confirm the change.'
                    : null,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpace.x4),
              _FormError(message: _error!),
            ],
            const SizedBox(height: AppSpace.x6),
            Align(
              alignment: Alignment.centerRight,
              child: _SaveButton(
                saving: _saving,
                disabledReason: !_hasChanges
                    ? 'Enter a new email address to save.'
                    : null,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordCard extends StatefulWidget {
  const _PasswordCard();

  @override
  State<_PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<_PasswordCard> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _repeatPassword = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _repeatPassword.dispose();
    super.dispose();
  }

  bool get _hasChanges => _newPassword.text.isNotEmpty;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final provider = context.read<ProfileProvider>();
    final result =
        await provider.updatePassword(_oldPassword.text, _newPassword.text);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.success) {
      _oldPassword.clear();
      _newPassword.clear();
      _repeatPassword.clear();
      nToast(context, result.message);
    } else {
      setState(() => _error = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Password', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpace.x4),
            NField(
              label: 'Current password',
              child: TextFormField(
                controller: _oldPassword,
                obscureText: true,
                enabled: !_saving,
                validator: (v) => (_hasChanges && (v ?? '').isEmpty)
                    ? 'Enter the current password.'
                    : null,
              ),
            ),
            const SizedBox(height: AppSpace.x4),
            NField(
              label: 'New password',
              child: TextFormField(
                controller: _newPassword,
                obscureText: true,
                enabled: !_saving,
                onChanged: (_) => setState(() {}),
                validator: (v) => (v ?? '').isNotEmpty && v!.length < 8
                    ? 'The new password must be at least 8 characters long.'
                    : null,
              ),
            ),
            const SizedBox(height: AppSpace.x4),
            NField(
              label: 'Confirm new password',
              child: TextFormField(
                controller: _repeatPassword,
                obscureText: true,
                enabled: !_saving,
                validator: (v) => (_hasChanges && v != _newPassword.text)
                    ? 'Confirmation does not match the new password.'
                    : null,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpace.x4),
              _FormError(message: _error!),
            ],
            const SizedBox(height: AppSpace.x6),
            Align(
              alignment: Alignment.centerRight,
              child: _SaveButton(
                saving: _saving,
                disabledReason:
                    !_hasChanges ? 'Enter a new password to save.' : null,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool saving;
  final String? disabledReason;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.saving,
    required this.disabledReason,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = saving || disabledReason != null;
    final button = OutlinedButton(
      onPressed: disabled ? null : onPressed,
      child: saving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Save'),
    );
    if (disabledReason == null) return button;
    return Tooltip(message: disabledReason!, child: button);
  }
}

String? _text(String? value, int min, int max, String field) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return '$field is required and must have $min to $max characters.';
  if (text.length < min || text.length > max) {
    return '$field must have between $min and $max characters.';
  }
  return null;
}

class _FormError extends StatelessWidget {
  final String message;

  const _FormError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIcons.warningCircle(), size: 15, color: AppColors.error),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
