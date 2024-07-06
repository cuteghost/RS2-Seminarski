import 'package:ebooking_desktop/pages/dashboard.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/providers/auth_provider.dart';
import 'package:ebooking_desktop/providers/message_provider.dart';
import 'package:ebooking_desktop/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn(BuildContext context) async {
    if (!context.mounted) return;

    final authService = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    bool loggedIn = await authService.login(_emailController.text, _passwordController.text);
    if (!loggedIn) {
      // Handle login failure (e.g., show an error message)
      return;
    }

    await messageProvider.startSignalR();
    await messageProvider.getChats();
    for (var chat in messageProvider.chats) {
      await messageProvider.getMessages(chat.Id);
      await messageProvider.addToChat(chat.Id);
    }
    await profileProvider.getProfile();
    await adminProvider.getAccommodations();
    await adminProvider.getProfiles();
    await adminProvider.getReservations();

    // Navigate to DashboardPage on successful login
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
        width: 300.0,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              controller: _emailController,
            ),
            const SizedBox(height: 10.0),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              controller: _passwordController,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async => await _signIn(context),
              child: const Text('Sign In'),
            ),
          ],
        ),
      )
    )
  );  
  }
}
