import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/partner_model.dart';
import 'package:ebooking/models/profile_model.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/widgets/custom_partner_bottom_navigation_bar.dart';
import 'package:ebooking/widgets/edit_email_modal.dart';
import 'package:ebooking/widgets/edit_password_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebooking/screens/login_screen.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class PartnerProfilePage extends StatefulWidget {
  const PartnerProfilePage({super.key});

  @override
  PartnerProfilePageState createState() => PartnerProfilePageState();
}

class PartnerProfilePageState extends State<PartnerProfilePage> {
  final ValueNotifier<bool> hasChanges = ValueNotifier<bool>(false);

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
            'This permanently deletes your account, your listings and everything in it. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    Provider.of<AuthProvider>(context, listen: false).deleteAccount();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    return FutureBuilder<List<dynamic>>(
      future: () async {
        var profile = await profileProvider.getProfile();
        await locationProvider.fetchCountries();
        var partner = await profileProvider.getPartner();
        var country = await locationProvider.getCountry(partner.countryId);
        return [profile, partner, country];
      }(),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('${snapshot.error}')));
        }

        final profile = snapshot.data?[0] as Profile?;
        final partnerProfile = snapshot.data?[1] as Partner?;
        final initialCountry = snapshot.data?[2] as Country?;
        if (profile == null || partnerProfile == null) {
          return const Scaffold(body: Center(child: Text('No profile or partner profile found!')));
        }

        final selectedCountry = ValueNotifier<Country?>(initialCountry);
        final selectedGender = ValueNotifier<String?>(profile.gender);

        void editEmail() {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: EditEmailModal(currentEmail: profile.emailAddress),
            ),
          );
        }

        void editPassword() {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: const EditPasswordModal(),
            ),
          );
        }

        Future<void> selectDate() async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.tryParse(profile.dob) ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null && picked.toIso8601String().split('T')[0] != profile.dob) {
            hasChanges.value = true;
            profile.dob = picked.toIso8601String().split('T')[0];
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Your details'),
            actions: [
              IconButton(
                icon: Icon(PhosphorIcons.signOut()),
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundImage: FileImage(profile.profilePicture),
                  ),
                ),
                const SizedBox(height: 24),

                _SectionCard(
                  title: 'Public details',
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Display name'),
                      onChanged: (value) {
                        hasChanges.value = true;
                        profile.displayName = value;
                      },
                      initialValue: profile.displayName,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date of birth'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(profile.dob),
                            Icon(PhosphorIcons.calendarBlank(), size: 18, color: AppColors.textSecondary),
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
                      onChanged: (value) {
                        hasChanges.value = true;
                        profile.firstName = value;
                      },
                      initialValue: profile.firstName,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Last name'),
                      onChanged: (value) {
                        hasChanges.value = true;
                        profile.lastName = value;
                      },
                      initialValue: profile.lastName,
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<String?>(
                      valueListenable: selectedGender,
                      builder: (context, value, child) {
                        return DropdownButtonFormField<String>(
                          initialValue: value,
                          decoration: const InputDecoration(labelText: 'Gender'),
                          items: const [
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue == null) return;
                            hasChanges.value = true;
                            profile.gender = newValue;
                            selectedGender.value = newValue;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<bool>(
                      valueListenable: hasChanges,
                      builder: (context, value, child) {
                        return OutlinedButton(
                          onPressed: value
                              ? () async {
                                  final success = await Provider.of<ProfileProvider>(context, listen: false)
                                      .updateProfile(profile: profile);
                                  if (success) hasChanges.value = false;
                                }
                              : null,
                          child: const Text('Save changes'),
                        );
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
                      onChanged: (value) {
                        hasChanges.value = true;
                        partnerProfile.taxName = value;
                      },
                      initialValue: partnerProfile.taxName,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Tax ID'),
                      keyboardType: TextInputType.number,
                      // Fixes a crash: `value as int` on a TextFormField's
                      // onChanged (which always hands back a String) threw a
                      // TypeError on the very first keystroke.
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed == null) return;
                        hasChanges.value = true;
                        partnerProfile.taxId = parsed;
                      },
                      initialValue: partnerProfile.taxId.toString(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Phone number'),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed == null) return;
                        hasChanges.value = true;
                        partnerProfile.phoneNumber = parsed;
                      },
                      // Fixes a bug: this field displayed partnerProfile.taxId
                      // instead of .phoneNumber.
                      initialValue: partnerProfile.phoneNumber.toString(),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<Country?>(
                      valueListenable: selectedCountry,
                      builder: (context, value, child) {
                        final countries = Provider.of<LocationProvider>(context, listen: true).countries;
                        return DropdownButtonFormField<Country>(
                          initialValue: countries.any((c) => c.id == value?.id) ? value : null,
                          decoration: const InputDecoration(labelText: 'Country'),
                          hint: const Text('Select country'),
                          // Fixes a bug: this never updated selectedCountry
                          // or hasChanges, so the dropdown looked unresponsive
                          // and Save stayed disabled after picking a country.
                          onChanged: (Country? newValue) {
                            if (newValue == null) return;
                            hasChanges.value = true;
                            partnerProfile.countryId = newValue.id;
                            selectedCountry.value = newValue;
                          },
                          items: countries
                              .map<DropdownMenuItem<Country>>(
                                  (c) => DropdownMenuItem(value: c, child: Text(c.name)))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<bool>(
                      valueListenable: hasChanges,
                      builder: (context, value, child) {
                        return OutlinedButton(
                          onPressed: value
                              ? () async {
                                  final success = await Provider.of<ProfileProvider>(context, listen: false)
                                      .updatePartner(partner: partnerProfile);
                                  if (success) hasChanges.value = false;
                                }
                              : null,
                          child: const Text('Save changes'),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _SectionCard(
                  title: 'Account',
                  children: [
                    _AccountRow(
                      icon: PhosphorIcons.envelopeSimple(),
                      label: profile.emailAddress,
                      actionLabel: 'Edit',
                      onTap: editEmail,
                    ),
                    const SizedBox(height: 10),
                    _AccountRow(
                      icon: PhosphorIcons.lockSimple(),
                      label: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                      actionLabel: 'Edit',
                      onTap: editPassword,
                    ),
                    if (profile.socialLink.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _AccountRow(
                        icon: profile.socialLink.contains('Facebook')
                            ? PhosphorIcons.facebookLogo()
                            : PhosphorIcons.googleLogo(),
                        label: profile.socialLink.contains('Facebook') ? 'Facebook linked' : 'Google linked',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Center(
                    child: Text('Delete account',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          bottomNavigationBar: const CustomPartnerBottomNavigationBar(currentIndex: 3),
        );
      },
    );
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

  const _AccountRow({required this.icon, required this.label, this.actionLabel, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        if (actionLabel != null)
          TextButton(onPressed: onTap, child: Text(actionLabel!)),
      ],
    );
  }
}
