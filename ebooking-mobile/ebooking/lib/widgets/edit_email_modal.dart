import 'package:flutter/material.dart';

class EditEmailModal extends StatefulWidget {
  final String currentEmail;

  const EditEmailModal({Key? key, required this.currentEmail}) : super(key: key);

  @override
  _EditEmailModalState createState() => _EditEmailModalState();
}

class _EditEmailModalState extends State<EditEmailModal> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Email Address',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'New Email Address'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Implement logic to save the new email
                // For now, just print the new email to the console
                String newEmail = _emailController.text;
                print('New Email Address: $newEmail');

                // Close the modal
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
