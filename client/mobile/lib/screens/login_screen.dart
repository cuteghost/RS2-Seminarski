import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/screens/customer_screens/customer_register_screen.dart';
import 'package:ebooking/screens/partner_screens/partner_discover_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/discover_screen.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

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
                  decoration: const BoxDecoration(
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
                    padding: const EdgeInsets.all(20.0),
                    child: const Column(
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
              margin: const EdgeInsets.all(20.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20.0),
                  const Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      final messageProvider =
                          Provider.of<MessageProvider>(context, listen: false);
                      final profileProvider =
                          Provider.of<ProfileProvider>(context, listen: false);

                      final loggedIn = await authProvider.login(
                          _emailController.text, _passwordController.text);
                      if (loggedIn == true) {
                        await messageProvider.startSignalR();
                        await messageProvider.getChats();
                        await Future.wait(messageProvider.chats.map((c) async {
                          await messageProvider.getMessages(c.id);
                          await messageProvider.addToChat(c.id);
                        }));
                        await profileProvider.getProfile();
                        if (!context.mounted) return;
                        final role = await authProvider.roleCheck();
                        if (!context.mounted) return;
                        if (role == "Customer") {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const DiscoverPropertiesPage()));
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PartnerDiscoverPage()));
                        }
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Incorrect email or password. Please try again.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: const Text('CONTINUE'),
                  ),
                  const SizedBox(height: 20.0),
                  const Text('OR USE ONE OF THESE OPTIONS'),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialMediaButton(
                        icon: Icons.facebook,
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false);
                          final messageProvider = Provider.of<MessageProvider>(
                              context,
                              listen: false);
                          final profileProvider = Provider.of<ProfileProvider>(
                              context,
                              listen: false);

                          await authProvider.loginWithFacebook();
                          final loggedIn =
                              await authProvider.checkLoggedInStatus();
                          if (loggedIn == true) {
                            await messageProvider.startSignalR();
                            await messageProvider.getChats();
                            await Future.wait(
                                messageProvider.chats.map((c) async {
                              await messageProvider.getMessages(c.id);
                              await messageProvider.addToChat(c.id);
                            }));
                            await profileProvider.getProfile();
                            if (!context.mounted) return;
                            final role = await authProvider.roleCheck();
                            if (!context.mounted) return;
                            if (role == "Customer") {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DiscoverPropertiesPage()));
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PartnerDiscoverPage()));
                            }
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Facebook login failed. Please try again.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                      SocialMediaButton(
                        icon: Icons.g_mobiledata,
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false);
                          final messageProvider = Provider.of<MessageProvider>(
                              context,
                              listen: false);
                          final profileProvider = Provider.of<ProfileProvider>(
                              context,
                              listen: false);

                          await authProvider.loginWithGoogle();
                          final loggedIn =
                              await authProvider.checkLoggedInStatus();
                          if (loggedIn == true) {
                            await messageProvider.startSignalR();
                            await messageProvider.getChats();
                            await Future.wait(
                                messageProvider.chats.map((c) async {
                              await messageProvider.getMessages(c.id);
                              await messageProvider.addToChat(c.id);
                            }));
                            await profileProvider.getProfile();
                            if (!context.mounted) return;
                            final role = await authProvider.roleCheck();
                            if (!context.mounted) return;
                            if (role == "Customer") {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DiscoverPropertiesPage()));
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PartnerDiscoverPage()));
                            }
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Google login failed. Please try again.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Want to start booking?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CustomerRegisterScreen()));
                        },
                        child: const Text('Sign up'),
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

  const SocialMediaButton(
      {super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}
