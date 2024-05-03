import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/partner_model.dart';
import 'package:ebooking/models/profile_model.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/screens/partner_screens/partner_register_screen.dart';
import 'package:ebooking/widgets/edit_email_modal.dart';
import 'package:ebooking/widgets/edit_password_modal.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ebooking/screens/login_screen.dart';

class PartnerProfilePage extends StatefulWidget {
  @override
  _PartnerProfilePageState createState() => _PartnerProfilePageState();
}

class _PartnerProfilePageState extends State<PartnerProfilePage> {
  ValueNotifier<bool> hasChanges = ValueNotifier<bool>(false);
  Country? _selectedCountry;
  Partner? partnerProfile;
  @override
  void initState(){
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
  partnerProfile = await Provider.of<ProfileProvider>(context, listen: false).getPartner();
  var fetchedCountry = await Provider.of<LocationProvider>(context, listen: false).getCountry(partnerProfile!.countryId);
  setState(() {
      _selectedCountry = fetchedCountry;
  });
}
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        Provider.of<ProfileProvider>(context, listen: false).getProfile(),
        Provider.of<LocationProvider>(context, listen: false).fetchCountries(),

      ]), 
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('${snapshot.error}'),
          );
        }
        
        final profile = snapshot.data?[0] as Profile?;

        if (profile == null) {
          return const Center(
            child: Text('No profile or partner profile found!'),
          );
        }

        void editEmail() {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),

                child: EditEmailModal(currentEmail: profile.emailAddress),
              ),
            ),
          );
        }

        

        void editPassword() {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),

                child: const EditPasswordModal(),
              ),
            ),
          );
        }

        Future<void> selectDate(BuildContext context) async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null && picked.toIso8601String().split('T')[0] != profile.dob) {
            hasChanges.value = true;
            profile.dob = picked.toIso8601String().split('T')[0];
          }
        }
        
        ValueNotifier<Country?> selectedCountry = ValueNotifier<Country?>(_selectedCountry);
        ValueNotifier<String?> selectedGender = ValueNotifier<String?>(profile.gender);
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  // Navigate to the LoginScreen
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50.0,
                        backgroundImage: FileImage(profile.profilePicture),
                      ),
                      const SizedBox(height: 16.0),
                      // Public Details Header
                      const Text(
                        'Public Details',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        onChanged: (value) {
                          hasChanges.value = true;
                          profile.displayName = value;
                          } ,
                        initialValue: profile.displayName,
                      ),
                      const SizedBox(height: 8.0),
                      InkWell(
                        onTap: () => selectDate(context),
                        child: Row(
                          children: [
                            Text('Date of Birth: ${profile.dob}'),
                            const Spacer(),
                            const Icon(Icons.calendar_today),
                          ],
                        ),                        
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Details',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        onChanged: (value) {
                          hasChanges.value = true;
                          profile.firstName = value;
                        },
                        initialValue: profile.firstName,
                      ),
                     TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        onChanged: (value) { 
                          hasChanges.value = true;
                          profile.lastName = value;
                        },
                        initialValue: profile.lastName,
                      ),
                      const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
                      Center(
                        child:
                          ValueListenableBuilder<String?>(
                            valueListenable: selectedGender,
                            builder: (context, value, child) {
                            
                            return DropdownButton<String>(
                              value: value,
                              items: const [
                                DropdownMenuItem(value: 'Female', child: Text('Female') ),
                                DropdownMenuItem(value: 'Male', child: Text('Male')),
                              ],
                              onChanged: (String? newValue) {
                                if (value != null) {
                                  hasChanges.value = true;
                                  profile.gender = newValue!;
                                  selectedGender.value = newValue;
                                }
                              },
                              hint: Text(profile.gender),
                            );
                          })
                        ),
                      const SizedBox(height: 16.0),
                      SafeArea(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: hasChanges,
                          builder: (context, value, child) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // Button color
                                shadowColor: Colors.white, // Text color
                                minimumSize: Size(double.infinity, 50), // Button size
                              ),
                              onPressed: value ? () async {

                                bool success = await Provider.of<ProfileProvider>(context, listen: false).updateProfile(profile: profile);
                                if (success) {
                                  hasChanges.value = false;
                                }
                              } : null,
                              child: const Text('SAVE CHANGES'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Partner Details',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Tax Name',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        onChanged: (value) {
                          hasChanges.value = true;
                          profile.firstName = value;
                        },
                        initialValue: partnerProfile!.taxName,
                      ),
                     TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Tax ID',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        onChanged: (value) { 
                          hasChanges.value = true;
                          partnerProfile!.taxId = value as int;
                        },
                        initialValue: partnerProfile!.taxId.toString(),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        onChanged: (value) { 
                          hasChanges.value = true;
                          partnerProfile!.phoneNumber = value as int;
                        },
                        initialValue: partnerProfile!.taxId.toString(),
                      ),
                      const Text('Country', style: TextStyle(fontWeight: FontWeight.bold)),
                      Center(
                        child:
                          ValueListenableBuilder<Country?>(
                            valueListenable: selectedCountry,
                            builder: (context, value, child) {
                            
                            return DropdownButtonFormField<Country>(
                              value: Provider.of<LocationProvider>(context, listen: true).countries.contains(_selectedCountry) ? _selectedCountry : null,
                              hint: _selectedCountry != null ? 
                                    Text(_selectedCountry!.name) : 
                                    Text("Select Country"),
                              onChanged: (Country? newValue) {
                                setState(() {
                                  if (newValue != null) {
                                  hasChanges.value = true;
                                  _selectedCountry = newValue;
                                  selectedCountry.value = newValue;
                                  }
                                });
                              },
                              items: (Provider.of<LocationProvider>(context, listen: true).countries).map<DropdownMenuItem<Country>>((Country country) {
                                return DropdownMenuItem<Country>(value: country, child: Text(country.name));
                              }).toList(),
                            );
                          })
                        ),
                      const SizedBox(height: 16.0),
                      SafeArea(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: hasChanges,
                          builder: (context, value, child) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // Button color
                                shadowColor: Colors.white, // Text color
                                minimumSize: Size(double.infinity, 50), // Button size
                              ),
                              onPressed: value ? () async {

                                bool success = await Provider.of<ProfileProvider>(context, listen: false).updatePartner(partner: partnerProfile!);
                                if (success) {
                                  hasChanges.value = false;
                                }
                              } : null,
                              child: const Text('SAVE CHANGES'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Container 3: Email Address
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[200],
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Settings',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Email Address Display
                      Row(
                        children: [
                          const Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 24.0,
                          ),
                          const SizedBox(width: 8.0),
                          Text(profile.emailAddress),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      // Edit Email Button
                      Center(
                        child:
                          ElevatedButton(
                            onPressed: editEmail,
                            child: const Text('EDIT YOUR EMAIL ADDRESS'),
                          ),
                      ),
                      const SizedBox(height: 16.0),
                      const Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.red,
                          size: 24.0,

                        ),
                        SizedBox(width: 8.0),
                        Text('**********'),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                      // Edit Email Button
                      Center(
                        child:
                          ElevatedButton(
                            onPressed: editPassword,
                            child: const Text('EDIT YOUR PASSWORD'),
                          ),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Container 4: Social Linking if profile.socialLink is not empty create the container
                if (profile.socialLink.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Social Linking',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Social Icon and Label
                      if (profile.socialLink.contains('Facebook'))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                                Icon(
                                  MdiIcons.facebook,
                                  size: 24.0,
                                ),
                              const SizedBox(width: 8.0),
                              const Text('Facebook'),
                            ],
                          ),
                        ],
                      )
                      else if (profile.socialLink.contains('Google'))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                                Icon(
                                  MdiIcons.google,
                                  size: 24.0,
                                ),
                              const SizedBox(width: 8.0),
                              const Text('Google'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                
                const SizedBox(height: 16.0),
                SafeArea(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400], // Button color
                      shadowColor: Colors.white, // Text colorr
                      minimumSize: const Size(double.infinity, 50), // Button size
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PartnerRegisterScreen(userId: profile.id)));
                    },
                    child: const Text('BECOME A PARTNER'),
                  ),
                ),
                  const SizedBox(height: 40.0),
                SafeArea(
                  child: ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button color
                    shadowColor: Colors.white, // Text color
                    minimumSize: const Size(double.infinity, 50), // Button size
                  ),
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false).deleteAccount();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: const Text('DELETE ACCOUNT'),
                  ),),
              ],
            ),
          ),
        );
      },
    );
  }
}