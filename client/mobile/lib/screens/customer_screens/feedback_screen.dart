import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/feedback_model.dart';
import 'package:ebooking/providers/feedback_provider.dart';
import 'package:ebooking/screens/customer_screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class FeedbackPage extends StatefulWidget {
  final String accommodationID;

  const FeedbackPage({super.key, required this.accommodationID});

  @override
  FeedbackPageState createState() => FeedbackPageState();
}

class FeedbackPageState extends State<FeedbackPage> {
  double rating = 8.0;
  bool? enjoyedStay = true;
  bool? recommendUs = true;
  final commentsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    commentsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    Provider.of<FeedbackProvider>(context, listen: false).makeFeedback(
      FeedbackPOST(
        rating: rating.toInt(),
        satisfaction: enjoyedStay!,
        wouldRecommend: recommendUs!,
        comment: commentsController.text,
        accommodationId: widget.accommodationID,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks — your review has been submitted.')),
    );
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const ReservationHistoryPage()));
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
                    Icon(PhosphorIcons.star(PhosphorIconsStyle.fill),
                        size: 16, color: AppColors.accent),
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
            _question('Did you enjoy your stay?', enjoyedStay,
                (value) => setState(() => enjoyedStay = value)),
            const SizedBox(height: 14),
            _question('Would you recommend us?', recommendUs,
                (value) => setState(() => recommendUs = value)),
            const SizedBox(height: 20),
            Text('Additional comments', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: commentsController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Optional...'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 16, width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _question(String question, bool? value, ValueChanged<bool?> onChanged) {
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
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(label,
            style: TextStyle(color: selected ? AppColors.accentText : AppColors.text)),
      ),
    );
  }
}
