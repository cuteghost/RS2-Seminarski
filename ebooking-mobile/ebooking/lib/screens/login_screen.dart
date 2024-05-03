import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/screens/customer_screens/customer_register_screen.dart';
import 'package:ebooking/screens/partner_screens/partner_dashboard_screen.dart';
import 'package:ebooking/screens/partner_screens/partner_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ebooking/screens/customer_screens/discover_screen.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
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
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20.0),
                  Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  SizedBox(height: 15.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      if( await Provider.of<AuthProvider>(context, listen:false).login(_emailController.text, _passwordController.text) == true ){
                       if(await Provider.of<AuthProvider>(context, listen:false).roleCheck() == "Customer"){
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DiscoverPropertiesPage()));
                              }
                              else{
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PartnerDashboardScreen()));
                              }
                      }
                      else{
                        // Handle login failure
                      }
                    },
                    child: Text('CONTINUE'),
                  ),
                  SizedBox(height: 20.0),
                  Text('OR USE ONE OF THESE OPTIONS'),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialMediaButton(
                        icon: Icons.facebook,
                        onPressed: () async{
                          // Invoke Facebook login through provider
                            await Provider.of<AuthProvider>(context, listen:false).loginWithFacebook();
                            if(await Provider.of<AuthProvider>(context, listen:false).checkLoggedInStatus() == true){
                              if(await Provider.of<AuthProvider>(context, listen:false).roleCheck() == "Customer"){
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DiscoverPropertiesPage()));
                              }
                              else{
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PartnerDashboardScreen()));
                              }
                            }
                            else{
                              // Handle login failure
                            }
                        },
                      ),
                      SocialMediaButton(
                        icon: MdiIcons.google,
                        onPressed: () async {
                          await  Provider.of<AuthProvider>(context, listen:false).loginWithGoogle();
                          if(await Provider.of<AuthProvider>(context, listen:false).checkLoggedInStatus() == true){
                            if(await Provider.of<AuthProvider>(context, listen:false).roleCheck() == "Customer"){
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DiscoverPropertiesPage()));
                              }
                              else{
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PartnerDashboardScreen()));
                              }
                          }
                          else{
                            // Handle login failure
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Want to start booking?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => CustomerRegisterScreen()));
                        },
                        child: Text('Sign up'),
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
