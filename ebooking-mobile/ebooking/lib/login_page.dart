import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'discover_page.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Image.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.10,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Find Your Stay',
                          style: TextStyle(
                            fontSize: 24.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Search and book your perfect stay',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  Text(
                    'Sign in or create account',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  SizedBox(height: 15.0),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      // Perform login logic here
                      // Navigate to DiscoverPropertiesPage on success
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiscoverPropertiesPage(),
                        ),
                      );
                    },
                    child: Text('CONTINUE'),
                  ),
                  SizedBox(height: 20.0),
                  Text('OR USE ONE OF THESE OPTIONS '),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialMediaButton(icon: Icons.facebook, onPressed: () {}),
                      SocialMediaButton(icon: Icons.apple, onPressed: () {}),
                      SocialMediaButton(
                        icon: MdiIcons.google,
                        onPressed: () {},
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
class SocialMediaButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  SocialMediaButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}
