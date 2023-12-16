import 'package:ebooking/widgets/edit_email_modal.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Placeholder data, replace with your actual data
  String displayName = 'John Doe';
  String dob = '';
  String location = 'New York, USA';
  String firstName = 'John';
  String lastName = 'Doe';
  String mobilePhone = '+1234567890';
  String gender = 'Male';
  String address = '123 Main Street';
  String city = 'New York';
  String country = 'USA';
  String region = 'NY';
  String zipCode = '10001';
  String emailAddress = 'john.doe@email.com';

  // Function to handle the email editing modal
  void _editEmail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Ensures the modal is above the keyboard
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EditEmailModal(currentEmail: emailAddress),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != dob) {
      setState(() {
        dob = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container 1: Public Details
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[200],
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: AssetImage('assets/images/Guy.jpg'),
                    // Replace 'assets/profile_picture.jpg' with the actual path or URL
                  ),
                  SizedBox(height: 16.0),
                  // Public Details Header
                  Text(
                    'Public Details',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Display Name Input
                  InputField(label: 'Display Name', value: displayName),
                  SizedBox(height: 8.0),
                  // Date of Birth Input
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Row(
                      children: [
                        Text('Date of Birth: $dob'),
                        Spacer(),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Location Input
                  InputField(label: 'Location', value: location),
                ],
              ),
            ),
            SizedBox(height: 16.0),

            // Container 2: Personal Details
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[200],
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Details',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // First Name Input
                  InputField(label: 'First Name', value: firstName),
                  // Last Name Input
                  InputField(label: 'Last Name', value: lastName),
                  // Mobile Phone Input
                  InputField(label: 'Mobile Phone', value: mobilePhone),
                  // Gender Input
                  InputField(label: 'Gender', value: gender),
                  // Address Input
                  InputField(label: 'Address', value: address),
                  // City Input
                  InputField(label: 'City', value: city),
                  // Country Input
                  InputField(label: 'Country', value: country),
                  // Region Input
                  InputField(label: 'Region', value: region),
                  // ZIP Code Input
                  InputField(label: 'ZIP Code', value: zipCode),
                ],
              ),
            ),
            SizedBox(height: 16.0),

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
                  Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Email Address Display
                  Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 24.0,
                      ),
                      SizedBox(width: 8.0),
                      Text(emailAddress),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  // Edit Email Button
                  ElevatedButton(
                    onPressed: _editEmail,
                    child: Text('EDIT YOUR EMAIL'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),

            // Container 4: Social Linking
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[200],
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Social Linking',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Social Icon and Label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            MdiIcons.google, // Replace with Google icon
                            size: 24.0,
                          ),
                          SizedBox(width: 8.0),
                          Text('Google'),
                        ],
                      ),
                      // Disconnect Button
                      ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                        child: Text('Disconnect'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final String label;
  final String value;

  const InputField({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          initialValue: value,
          // Add your TextFormField properties here
        ),
        SizedBox(height: 8.0),
      ],
    );
  }
}
