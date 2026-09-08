import 'package:ebooking/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:provider/provider.dart';

/// Bottom-sheet editor for display name, first/last name, DOB and gender --
/// same save-and-report-result pattern as EditEmailModal / EditPasswordModal.
class EditPersonalDetailsModal extends StatefulWidget {
  final Profile profile;

  const EditPersonalDetailsModal({super.key, required this.profile});

  @override
  EditPersonalDetailsModalState createState() =>
      EditPersonalDetailsModalState();
}

class EditPersonalDetailsModalState extends State<EditPersonalDetailsModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late String _gender;
  late String _dob;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.profile.displayName,
    );
    _firstNameController = TextEditingController(
      text: widget.profile.firstName,
    );
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _gender = widget.profile.gender;
    _dob = widget.profile.dob;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dob) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dob = picked.toIso8601String().split('T')[0]);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final profile = widget.profile
      ..displayName = _displayNameController.text
      ..firstName = _firstNameController.text
      ..lastName = _lastNameController.text
      ..gender = _gender
      ..dob = _dob;

    final (success, message) = await Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).updateProfile(profile: profile);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );

    if (success) {
      Navigator.pop(context, true);
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Personal details',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display name'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14.0),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14.0),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14.0),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const [
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _gender = value);
                },
              ),
              const SizedBox(height: 14.0),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date of birth'),
                  child: Text(_dob),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
