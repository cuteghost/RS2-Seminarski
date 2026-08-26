import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/partner_model.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/screens/partner_screens/partner_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).fetchCountries();
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
    if (_selectedCountry == null) {
      setState(() => _formError = 'Please select a country.');
      return;
    }

    setState(() => _isSubmitting = true);
    final partner = Partner(
      userId: widget.userId,
      countryId: _selectedCountry!.id,
      taxName: taxNameController.text,
      taxId: int.parse(taxIdController.text),
      phoneNumber: int.parse(phoneController.text),
    );
    // The old handler fired this without awaiting or checking the result,
    // so it always navigated to the partner profile even on failure.
    final success =
        await Provider.of<AuthProvider>(context, listen: false).registerPartner(partner);
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const PartnerProfilePage()));
    } else {
      setState(() {
        _isSubmitting = false;
        _formError = 'Could not register as a partner. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final countries = Provider.of<LocationProvider>(context, listen: true).countries;

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
                  decoration: const InputDecoration(labelText: 'Tax name'),
                  controller: taxNameController,
                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter tax name' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tax ID'),
                  controller: taxIdController,
                  keyboardType: TextInputType.number,
                  // Fixes a crash: submitting used to call int.parse() on
                  // whatever was typed here with no numeric validation,
                  // so a single letter would throw a FormatException.
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter tax ID';
                    if (int.tryParse(v) == null) return 'Numbers only';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone number'),
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter phone number';
                    if (int.tryParse(v) == null) return 'Numbers only';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<Country>(
                  initialValue: _selectedCountry,
                  decoration: const InputDecoration(labelText: 'Country'),
                  hint: const Text('Select country'),
                  onChanged: (Country? newValue) => setState(() => _selectedCountry = newValue),
                  items: countries
                      .map<DropdownMenuItem<Country>>(
                          (c) => DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                ),
                if (_formError != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.28)),
                      borderRadius: BorderRadius.circular(AppColors.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.warningCircle(), size: 16, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_formError!,
                              style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
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
                          height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
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
