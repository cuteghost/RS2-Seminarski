import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/feedback_model.dart';
import 'package:ebooking/providers/feedback_provider.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

/// The review this customer already sent for one stay, read only.
///
/// Editing a review is a separate job and no endpoint accepts it, so nothing
/// on this screen is writable and no second review can be started from here.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    super.key,
    required this.accommodationId,
    required this.accommodationName,
  });

  final String accommodationId;
  final String accommodationName;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late Future<MyReview> _review;

  @override
  void initState() {
    super.initState();
    _review = _load();
  }

  Future<MyReview> _load() => Provider.of<FeedbackProvider>(
    context,
    listen: false,
  ).myReview(widget.accommodationId);

  void _retry() {
    setState(() {
      _review = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Your review')),
      body: FutureBuilder<MyReview>(
        future: _review,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      // ApiException.message is the server's own sentence, and
                      // for a missing review it says exactly that.
                      error is ApiException ? error.message : '$error',
                      style: textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _retry,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final review = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.accommodationName, style: textTheme.titleLarge),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.star(PhosphorIconsStyle.fill),
                            size: 18,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${review.rating} / 10',
                            style: textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _Answer(
                        question: 'Did you enjoy your stay?',
                        answer: review.satisfaction,
                      ),
                      const SizedBox(height: 10),
                      _Answer(
                        question: 'Would you recommend us?',
                        answer: review.wouldRecommend,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('WHAT YOU WROTE', style: textTheme.labelSmall),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  ),
                  child: Text(
                    review.comment.trim().isEmpty
                        ? 'You left a rating without a comment.'
                        : review.comment,
                    style: review.comment.trim().isEmpty
                        ? textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          )
                        : textTheme.bodyLarge?.copyWith(height: 1.35),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'A review can be sent once per stay and cannot be changed '
                  'from the app.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Answer extends StatelessWidget {
  const _Answer({required this.question, required this.answer});

  final String question;
  final bool answer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(
          answer ? PhosphorIcons.checkCircle() : PhosphorIcons.xCircle(),
          size: 16,
          color: answer ? AppColors.success : AppColors.textTertiary,
        ),
        const SizedBox(width: 9),
        Expanded(child: Text(question, style: textTheme.bodyMedium)),
        Text(
          answer ? 'Yes' : 'No',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
