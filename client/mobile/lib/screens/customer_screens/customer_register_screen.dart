import 'dart:io';
import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

final RegExp _emailFormat = RegExp(
  r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
);

final RegExp _lettersOnly = RegExp(r'^\p{L}+$', unicode: true);

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  CustomerRegisterScreenState createState() => CustomerRegisterScreenState();
}

class CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final displayNameController = TextEditingController();
  DateTime? _dateOfBirth;
  File? _profileImage;
  bool _isSubmitting = false;
  String? _formError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _submit() async {
    setState(() => _formError = null);
    if (!_formKey.currentState!.validate()) return;

    // These two used to be force-unwrapped straight into the register call,
    // which crashed the whole screen if either was left unset. Validate and
    // tell the user instead.
    if (_profileImage == null) {
      setState(() => _formError = 'Please upload a profile photo.');
      return;
    }
    if (_dateOfBirth == null) {
      setState(() => _formError = 'Please select your date of birth.');
      return;
    }

    setState(() => _isSubmitting = true);
    final (
      registered,
      message,
    ) = await Provider.of<AuthProvider>(context, listen: false).register(
      emailController.text.trim(),
      passwordController.text,
      firstNameController.text.trim(),
      lastNameController.text.trim(),
      displayNameController.text,
      _profileImage!,
      _dateOfBirth!.toIso8601String().split('T')[0],
    );
    if (!mounted) return;

    if (registered) {
      resetTo(context, LoginPage());
    } else {
      setState(() {
        _isSubmitting = false;
        // Whatever the server objected to -- a taken email, a password that
        // is too short -- reaches the user in its own words.
        _formError = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          // Pops, like the system back button does. It used to build a second
          // login screen, so the two buttons ended up in different places.
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.surface,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(
                              PhosphorIcons.camera(),
                              color: AppColors.textSecondary,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _pickImage,
                    child: Text(
                      _profileImage == null ? 'Upload photo' : 'Change photo',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: displayNameController,
                  decoration: const InputDecoration(labelText: 'Display name'),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Please enter display name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    errorMaxLines: 3,
                  ),
                  validator: (v) => _emailFormat.hasMatch((v ?? '').trim())
                      ? null
                      : 'Enter an email like name@domain.ba, with no spaces '
                            'or special characters.',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First name',
                    errorMaxLines: 3,
                  ),
                  validator: (v) => _lettersOnly.hasMatch((v ?? '').trim())
                      ? null
                      : 'First name can only contain letters, with no digits, '
                            'spaces or special characters.',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last name',
                    errorMaxLines: 3,
                  ),
                  validator: (v) => _lettersOnly.hasMatch((v ?? '').trim())
                      ? null
                      : 'Last name can only contain letters, with no digits, '
                            'spaces or special characters.',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Please enter password' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of birth',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dateOfBirth == null
                              ? 'Select date'
                              : DateFormat('d MMM yyyy').format(_dateOfBirth!),
                        ),
                        Icon(
                          PhosphorIcons.calendarBlank(),
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_formError != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.28),
                      ),
                      borderRadius: BorderRadius.circular(AppColors.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.warningCircle(),
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formError!,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                OutlinedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
