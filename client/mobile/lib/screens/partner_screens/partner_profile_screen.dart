import 'dart:typed_data';

import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/partner_model.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/widgets/custom_partner_bottom_navigation_bar.dart';
import 'package:ebooking/widgets/edit_email_modal.dart';
import 'package:ebooking/widgets/edit_password_modal.dart';
import 'package:ebooking/widgets/remote_image.dart';
import 'package:ebooking/utils/session_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class _PartnerProfileData {
  const _PartnerProfileData({required this.partner, this.country});

  final Partner partner;
  final Country? country;
}

class PartnerProfilePage extends StatefulWidget {
  const PartnerProfilePage({super.key});

  @override
  PartnerProfilePageState createState() => PartnerProfilePageState();
}

class PartnerProfilePageState extends State<PartnerProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late Future<_PartnerProfileData> _future;

  bool _hydrated = false;
  bool _changed = false;
  bool _saving = false;
  Country? _country;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_PartnerProfileData> _load() async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    final partner = await profileProvider.getPartner();
    await locationProvider.fetchCountries();
    final country = await locationProvider.getCountry(partner.countryId);

    return _PartnerProfileData(partner: partner, country: country);
  }

  void _reload() {
    setState(() {
      _hydrated = false;
      _changed = false;
      _saving = false;
      _future = _load();
    });
  }

  void _hydrate(_PartnerProfileData data) {
    if (_hydrated) return;
    _hydrated = true;
    _country = data.country;
    _gender = data.partner.gender;
  }

  void _markChanged() {
    if (!_changed) setState(() => _changed = true);
  }

  Future<void> _pickImage(Partner partner) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final Uint8List bytes;
    try {
      bytes = await picked.readAsBytes();
    } on Exception catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'That photo could not be read from the gallery. Pick another one.',
          ),
        ),
      );
      return;
    }
    if (!mounted) return;

    partner.pickedImage = bytes;
    setState(() => _changed = true);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account, your listings and everything in it. This cannot be undone.',
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
    // Inside a State the guard is `mounted`; `context.mounted` stays true
    // for a context that the element tree has already dropped.
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

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: const Text('Your details'),
      actions: [
        IconButton(
          icon: Icon(PhosphorIcons.signOut()),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final (signedOut, message) = await signOut(context);
            if (!signedOut) {
              messenger.showSnackBar(SnackBar(content: Text(message)));
            }
          },
        ),
      ],
    );
  }

  Widget _statusScaffold(BuildContext context, Widget child) {
    return Scaffold(
      appBar: _appBar(context),
      body: Center(child: child),
      bottomNavigationBar: const CustomPartnerBottomNavigationBar(
        currentIndex: 3,
      ),
    );
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
    ).then((updated) {
      if (updated == true) _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<_PartnerProfileData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _statusScaffold(context, const CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _statusScaffold(
            context,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '${snapshot.error}',
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return _statusScaffold(
            context,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Your partner details could not be loaded, so there is nothing '
                'to show here yet.',
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        _hydrate(data);
        return _content(context, data, textTheme);
      },
    );
  }

  Widget _content(
    BuildContext context,
    _PartnerProfileData data,
    TextTheme textTheme,
  ) {
    final partner = data.partner;

    return Scaffold(
      appBar: _appBar(context),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _saving ? null : () => _pickImage(partner),
                  child: ClipOval(
                    child: SizedBox(
                      width: 88,
                      height: 88,
                      child: _avatar(partner),
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _saving ? null : () => _pickImage(partner),
                  child: Text(
                    partner.imageUrl == null && partner.pickedImage == null
                        ? 'Upload photo'
                        : 'Change photo',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: 'Public details',
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                    ),
                    initialValue: partner.displayName,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => _length(value, 3, 50, 'Display name'),
                    onChanged: (value) {
                      partner.displayName = value;
                      _markChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _selectDate(partner),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of birth',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(partner.dob.isEmpty ? 'Not set' : partner.dob),
                          Icon(
                            PhosphorIcons.calendarBlank(),
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: 'Personal details',
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'First name'),
                    initialValue: partner.firstName,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => _length(value, 3, 15, 'First name'),
                    onChanged: (value) {
                      partner.firstName = value;
                      _markChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Last name'),
                    initialValue: partner.lastName,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => _length(value, 3, 30, 'Last name'),
                    onChanged: (value) {
                      partner.lastName = value;
                      _markChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const [
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue == null) return;
                      partner.gender = newValue;
                      setState(() {
                        _gender = newValue;
                        _changed = true;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: 'Partner details',
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Tax name'),
                    initialValue: partner.taxName,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Tax name is required.'
                        : null,
                    onChanged: (value) {
                      partner.taxName = value;
                      _markChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Tax ID'),
                    keyboardType: TextInputType.number,
                    initialValue: partner.taxId.toString(),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => _positiveNumber(value, 'Tax ID'),
                    // Fixes a crash: `value as int` on a TextFormField's
                    // onChanged (which always hands back a String) threw a
                    // TypeError on the very first keystroke.
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed == null) return;
                      partner.taxId = parsed;
                      _markChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                    ),
                    keyboardType: TextInputType.phone,
                    // Fixes a bug: this field displayed partnerProfile.taxId
                    // instead of .phoneNumber.
                    initialValue: partner.phoneNumber.toString(),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => _positiveNumber(value, 'Phone number'),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed == null) return;
                      partner.phoneNumber = parsed;
                      _markChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final countries = Provider.of<LocationProvider>(
                        context,
                        listen: true,
                      ).countries;
                      return DropdownButtonFormField<Country>(
                        initialValue: countries.any((c) => c.id == _country?.id)
                            ? _country
                            : null,
                        decoration: const InputDecoration(labelText: 'Country'),
                        hint: const Text('Select country'),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => value == null
                            ? 'Pick the country you host in.'
                            : null,
                        // Fixes a bug: this never updated selectedCountry
                        // or hasChanges, so the dropdown looked unresponsive
                        // and Save stayed disabled after picking a country.
                        onChanged: (Country? newValue) {
                          if (newValue == null) return;
                          partner.countryId = newValue.id;
                          setState(() {
                            _country = newValue;
                            _changed = true;
                          });
                        },
                        items: countries
                            .map<DropdownMenuItem<Country>>(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: _changed && !_saving ? () => _save(partner) : null,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save changes'),
              ),
              if (!_changed && !_saving)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Change something above to be able to save.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),

              _SectionCard(
                title: 'Account',
                children: [
                  _AccountRow(
                    icon: PhosphorIcons.envelopeSimple(),
                    label: partner.emailAddress.isEmpty
                        ? 'Email address'
                        : partner.emailAddress,
                    actionLabel: partner.isSocialAccount ? null : 'Edit',
                    onTap: partner.isSocialAccount
                        ? null
                        : () => _openModal(
                            EditEmailModal(currentEmail: partner.emailAddress),
                          ),
                    disabledReason: partner.isSocialAccount
                        ? 'Managed by ${partner.socialProvider}'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _AccountRow(
                    icon: PhosphorIcons.lockSimple(),
                    label: '••••••••',
                    actionLabel: partner.isSocialAccount ? null : 'Edit',
                    onTap: partner.isSocialAccount
                        ? null
                        : () => _openModal(const EditPasswordModal()),
                    disabledReason: partner.isSocialAccount
                        ? 'Managed by ${partner.socialProvider}'
                        : null,
                  ),
                  if (partner.isSocialAccount) ...[
                    const SizedBox(height: 10),
                    _AccountRow(
                      icon: partner.socialProvider == 'Facebook'
                          ? PhosphorIcons.facebookLogo()
                          : PhosphorIcons.googleLogo(),
                      label: '${partner.socialProvider} linked',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _confirmDelete,
                child: Center(
                  child: Text(
                    'Delete account',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomPartnerBottomNavigationBar(
        currentIndex: 3,
      ),
    );
  }

  Widget _avatar(Partner partner) {
    final picked = partner.pickedImage;
    if (picked != null) {
      return Image.memory(picked, width: 88, height: 88, fit: BoxFit.cover);
    }
    if (partner.imageUrl == null) {
      return Container(
        color: AppColors.surfaceRaised,
        child: Icon(PhosphorIcons.user(), size: 32),
      );
    }
    return RemoteImage(path: partner.imageUrl, width: 88, height: 88);
  }

  String? _length(String? value, int minimum, int maximum, String field) {
    final trimmed = (value ?? '').trim();
    if (trimmed.length < minimum || trimmed.length > maximum) {
      return '$field has to be between $minimum and $maximum characters.';
    }
    return null;
  }

  String? _positiveNumber(String? value, String field) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) {
      return '$field has to be a whole number greater than zero, with no '
          'spaces or special characters.';
    }
    return null;
  }

  Future<void> _selectDate(Partner partner) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(partner.dob) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;

    final formatted = picked.toIso8601String().split('T')[0];
    if (formatted == partner.dob) return;

    partner.dob = formatted;
    setState(() => _changed = true);
  }

  Future<void> _save(Partner partner) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);

    final imageReplaced = partner.pickedImage != null;
    final (success, message) = await Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).updatePartner(partner: partner);
    if (!mounted) return;

    if (!success) {
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    if (imageReplaced) {
      await RemoteImage.evict('/api/UserImage/${partner.userId}');
      if (!mounted) return;
    }

    messenger.showSnackBar(SnackBar(content: Text(message)));
    _reload();
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? actionLabel;
  final VoidCallback? onTap;
  final String? disabledReason;

  const _AccountRow({
    required this.icon,
    required this.label,
    this.actionLabel,
    this.onTap,
    this.disabledReason,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.bodyMedium),
              if (disabledReason != null)
                Text(
                  disabledReason!,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onTap, child: Text(actionLabel!)),
      ],
    );
  }
}
