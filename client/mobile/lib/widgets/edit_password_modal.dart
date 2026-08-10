import 'package:flutter/material.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class EditPasswordModal extends StatefulWidget {
  const EditPasswordModal({super.key});

  @override
  EditPasswordModalState createState() => EditPasswordModalState();
}

class EditPasswordModalState extends State<EditPasswordModal> {
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
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
              'Edit Password',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              obscureText: true,
              controller: _oldPasswordController,
              decoration: const InputDecoration(labelText: 'Old Password'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              obscureText: true,
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final profileProvider =
                    Provider.of<ProfileProvider>(context, listen: false);
                String message = await profileProvider.updatePassword(
                    _oldPasswordController.text, _newPasswordController.text);
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
