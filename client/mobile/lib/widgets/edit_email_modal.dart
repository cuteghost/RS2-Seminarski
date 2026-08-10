import 'package:flutter/material.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class EditEmailModal extends StatefulWidget {
  final String currentEmail;

  const EditEmailModal({super.key, required this.currentEmail});

  @override
  EditEmailModalState createState() => EditEmailModalState();
}

class EditEmailModalState extends State<EditEmailModal> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.currentEmail);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit Email Address',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'New Email Address'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              obscureText: true,
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Your Password'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final profileProvider =
                    Provider.of<ProfileProvider>(context, listen: false);
                String message = await profileProvider.updateEmail(
                    _emailController.text, _passwordController.text);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 3),
                ));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
