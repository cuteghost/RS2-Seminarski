import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/partner_model.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/screens/partner_screens/partner_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final addressController = TextEditingController();
  final taxNameController = TextEditingController();
  final taxIdController = TextEditingController();
  final zipCodeController = TextEditingController();

  Country? _selectedCountry;

  @override
  void dispose() {
    phoneController.dispose();
    addressController.dispose();
    taxNameController.dispose();
    taxIdController.dispose();
    zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register As Partner'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tax Name'),
                  controller: taxNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tax name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tax ID'),
                  controller: taxIdController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tax ID';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  controller: phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<Country>(
                  initialValue: _selectedCountry,
                  hint: const Text('Select Country'),
                  onChanged: (Country? newValue) async {
                    setState(() {
                      if (newValue != null) {
                        _selectedCountry = newValue;
                      }
                    });
                  },
                  items: (Provider.of<LocationProvider>(context, listen: true)
                          .countries)
                      .map<DropdownMenuItem<Country>>((Country country) {
                    return DropdownMenuItem<Country>(
                        value: country, child: Text(country.name));
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedCountry != null &&
                            _selectedCountry?.id != null) {
                          Country toPass = _selectedCountry!;
                          Partner partner = Partner(
                            userId: widget.userId,
                            countryId: toPass.id,
                            taxName: taxNameController.text,
                            taxId: int.parse(taxIdController.text),
                            phoneNumber: int.parse(phoneController.text),
                          );
                          Provider.of<AuthProvider>(context, listen: false)
                              .registerPartner(partner);
                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PartnerProfilePage()));
                        }
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
