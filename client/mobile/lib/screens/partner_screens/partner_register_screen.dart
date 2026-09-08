import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/partner_model.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/screens/partner_screens/partner_profile_screen.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

final RegExp _taxIdFormat = RegExp(r'^\d{12,13}$');

final RegExp _phoneFormat = RegExp(r'^00387\d{8}$');

class PartnerRegisterScreen extends StatefulWidget {
  final String userId;

  const PartnerRegisterScreen({super.key, required this.userId});

  @override
  PartnerRegisterScreenState createState() => PartnerRegisterScreenState();
}

class PartnerRegisterScreenState extends State<PartnerRegisterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      await locationProvider.fetchCountries();
      // An empty dropdown has to say why it is empty.
      if (!mounted || locationProvider.error == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(locationProvider.error!)));
    });
  }

  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final taxNameController = TextEditingController();
  final taxIdController = TextEditingController();

  Country? _selectedCountry;
  bool _isSubmitting = false;
  String? _formError;

  @override
  void dispose() {
    phoneController.dispose();
    taxNameController.dispose();
    taxIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _formError = null);
    if (!_formKey.currentState!.validate()) return;
    final country = _selectedCountry;
    if (country == null) return;

    setState(() => _isSubmitting = true);
    final partner = Partner(
      userId: widget.userId,
      countryId: country.id,
      taxName: taxNameController.text.trim(),
      taxId: int.parse(taxIdController.text.trim()),
      phoneNumber: int.parse(phoneController.text.trim()),
    );
    // The old handler fired this without awaiting or checking the result,
    // so it always navigated to the partner profile even on failure.
    final (success, message) = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).registerPartner(partner);
    if (!mounted) return;

    if (success) {
      // The account is a partner now, so the customer screens this form was
      // opened from must not stay reachable behind it.
      resetTo(context, const PartnerProfilePage());
    } else {
      setState(() {
        _isSubmitting = false;
        _formError = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final countries = Provider.of<LocationProvider>(
      context,
      listen: true,
    ).countries;

    return Scaffold(
      appBar: AppBar(title: const Text('Register as partner')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tax name',
                    helperText: 'The name the business is registered under.',
                    errorMaxLines: 3,
                  ),
                  controller: taxNameController,
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? 'Please enter tax name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tax ID',
                    helperText: 'Digits only, 12 or 13 of them.',
                    errorMaxLines: 3,
                  ),
                  controller: taxIdController,
                  keyboardType: TextInputType.number,
                  // Checking the shape instead of parsing: int.tryParse
                  // returns null for a number too large to hold, so a long
                  // run of digits used to be reported as "Numbers only".
                  validator: (v) => _taxIdFormat.hasMatch((v ?? '').trim())
                      ? null
                      : 'Tax ID has to be 12 or 13 digits, with no spaces or '
                            'other characters.',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    helperText: 'Format: 0038762730854',
                    errorMaxLines: 3,
                  ),
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) => _phoneFormat.hasMatch((v ?? '').trim())
                      ? null
                      : 'Phone number has to be 00387 followed by eight '
                            'digits, like 0038762730854.',
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<Country>(
                  initialValue: _selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    errorMaxLines: 3,
                  ),
                  hint: const Text('Select country'),
                  validator: (v) =>
                      v == null ? 'Please select the country you host in.' : null,
                  onChanged: (Country? newValue) =>
                      setState(() => _selectedCountry = newValue),
                  items: countries
                      .map<DropdownMenuItem<Country>>(
                        (c) => DropdownMenuItem(value: c, child: Text(c.name)),
                      )
                      .toList(),
                ),
                if (_formError != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.28),
                      ),
                      borderRadius: BorderRadius.circular(AppColors.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.warningCircle(),
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formError!,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                OutlinedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
