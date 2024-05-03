import 'package:flutter/material.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:provider/provider.dart';  
class EditEmailModal extends StatefulWidget {
  final String currentEmail;

  const EditEmailModal({Key? key, required this.currentEmail}) : super(key: key);

  @override
  _EditEmailModalState createState() => _EditEmailModalState();
}

class _EditEmailModalState extends State<EditEmailModal> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.currentEmail);
    _passwordController = TextEditingController();

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
              decoration: InputDecoration(labelText: 'New Email Address'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              obscureText: true,
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Your Password'),
            ),
            const SizedBox(height: 16.0),

            ElevatedButton(
              onPressed: () async{
                String message = await Provider.of<ProfileProvider>(context, listen: false)
                    .updateEmail(_emailController.text, _passwordController.text);
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
