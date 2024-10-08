import 'package:ebooking/models/feedback_model.dart';
import 'package:ebooking/providers/feedback_provider.dart';
import 'package:ebooking/screens/customer_screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedbackPage extends StatefulWidget {
  final String accommodationID;

  FeedbackPage({required this.accommodationID});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double rating = 5.0;
  bool? enjoyedStay = true;
  bool? recommendUs = true;
  TextEditingController commentsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate your stay',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: rating,
              onChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
              min: 0,
              max: 10,
              divisions: 10,
              label: rating.toString(),
            ),
            _buildQuestion('Did you enjoy your stay?', enjoyedStay, (value) {
              setState(() {
                enjoyedStay = value;
              });
            }),
            _buildQuestion('Would you recommend us?', recommendUs, (value) {
              setState(() {
                recommendUs = value;
              });
            }),
            _buildHeader('Additional comments'),
            TextField(
              controller: commentsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your comments...',
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<FeedbackProvider>(context, listen: false).makeFeedback(FeedbackPOST(
                      rating: rating.toInt(),
                      satisfaction: enjoyedStay!,
                      wouldRecommend: recommendUs!,
                      comment: commentsController.text,
                      accommodationId: widget.accommodationID
                    )
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ReservationHistoryPage()));
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(String question, bool? value, ValueChanged<bool?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            question,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: value,
              onChanged: onChanged,
            ),
            Text('Yes'),
            Radio<bool>(
              value: false,
              groupValue: value,
              onChanged: onChanged,
            ),
            Text('No'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(String header) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        header,
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}
