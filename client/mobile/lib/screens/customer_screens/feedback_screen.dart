import 'dart:typed_data';

import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/feedback_model.dart';
import 'package:ebooking/providers/feedback_provider.dart';
import 'package:ebooking/screens/customer_screens/history_screen.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class FeedbackPage extends StatefulWidget {
  final String accommodationID;
  final String reservationId;

  const FeedbackPage({
    super.key,
    required this.accommodationID,
    required this.reservationId,
  });

  @override
  FeedbackPageState createState() => FeedbackPageState();
}

class FeedbackPageState extends State<FeedbackPage> {
  double rating = 8.0;
  bool? enjoyedStay = true;
  bool? recommendUs = true;
  final commentsController = TextEditingController();
  bool _isSubmitting = false;
  Uint8List? _photo;

  static const int _maxPhotoBytes = 5 * 1024 * 1024;

  Future<void> _pickPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;

    final Uint8List bytes;
    try {
      bytes = await picked.readAsBytes();
    } on Exception catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('That photo could not be read. Pick another one.'),
        ),
      );
      return;
    }

    if (bytes.length > _maxPhotoBytes) {
      messenger.showSnackBar(
        const SnackBar(content: Text('The photo is larger than 5 MB.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _photo = bytes);
  }

  @override
  void dispose() {
    commentsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final String message;
    try {
      // Awaited now: the review used to be posted and forgotten, so the
      // screen thanked the user even when the server refused it.
      message = await Provider.of<FeedbackProvider>(
        context,
        listen: false,
      ).makeFeedback(
        FeedbackPOST(
          rating: rating.toInt(),
          satisfaction: enjoyedStay!,
          wouldRecommend: recommendUs!,
          comment: commentsController.text,
          accommodationId: widget.accommodationID,
          reservationId: widget.reservationId,
          image: _photo,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    // Replacing only this route would leave the Trips screen the user came
    // from underneath, still listing the stay as unreviewed -- the system back
    // button then walked straight into that stale copy.
    resetTo(context, const ReservationHistoryPage());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Rate your stay')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Overall rating', style: textTheme.titleMedium),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.star(PhosphorIconsStyle.fill),
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 6),
                    Text('${rating.toInt()} / 10', style: textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.text,
                trackHeight: 3,
              ),
              child: Slider(
                value: rating,
                onChanged: (value) => setState(() => rating = value),
                min: 1,
                max: 10,
                divisions: 9,
                label: rating.toInt().toString(),
              ),
            ),
            const SizedBox(height: 18),
            _question(
              'Did you enjoy your stay?',
              enjoyedStay,
              (value) => setState(() => enjoyedStay = value),
            ),
            const SizedBox(height: 14),
            _question(
              'Would you recommend us?',
              recommendUs,
              (value) => setState(() => recommendUs = value),
            ),
            const SizedBox(height: 20),
            Text('Additional comments', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: commentsController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Optional...'),
            ),
            const SizedBox(height: 20),
            Text('Photo', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            _photoPicker(textTheme),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPicker(TextTheme textTheme) {
    final photo = _photo;
    if (photo == null) {
      return OutlinedButton.icon(
        onPressed: _isSubmitting ? null : _pickPhoto,
        icon: Icon(PhosphorIcons.camera(), size: 18),
        label: const Text('Add a photo (optional)'),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          child: Image.memory(photo, width: 96, height: 96, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: _isSubmitting ? null : _pickPhoto,
                child: const Text('Change photo'),
              ),
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() => _photo = null),
                child: const Text('Remove photo'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _question(
    String question,
    bool? value,
    ValueChanged<bool?> onChanged,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: textTheme.bodyLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            _pill('Yes', value == true, () => onChanged(true)),
            const SizedBox(width: 10),
            _pill('No', value == false, () => onChanged(false)),
          ],
        ),
      ],
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentTint : null,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.accentText : AppColors.text,
          ),
        ),
      ),
    );
  }
}
