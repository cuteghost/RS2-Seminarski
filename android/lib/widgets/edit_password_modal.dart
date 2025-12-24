import 'package:flutter/material.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:provider/provider.dart';  

class EditPasswordModal extends StatefulWidget {
  const EditPasswordModal() : super();

  @override
  _EditPasswordModalState createState() => _EditPasswordModalState();
}

class _EditPasswordModalState extends State<EditPasswordModal> {
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();

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
              obscureText: true,
              controller: _oldPasswordController,
              decoration: InputDecoration(labelText: 'Old Password'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              obscureText: true,
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 16.0),

            ElevatedButton(
              onPressed: () async{
                String message = await Provider.of<ProfileProvider>(context, listen: false)
                    .updatePassword(_oldPasswordController.text, _newPasswordController.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 3),
                ));
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
