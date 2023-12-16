import 'package:flutter/material.dart';
import 'package:ebooking/review_page.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool creditCardSelected = true; // Initial selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleIndicator(label: 'Checkout', isChecked: true),
                CircleIndicator(label: 'Review', isChecked: true),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a payment method',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'You won\'t be charged until you review this order in the next step.',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Radio(
                      value: true,
                      groupValue: creditCardSelected,
                      onChanged: (value) {
                        setState(() {
                          creditCardSelected = true;
                        });
                      },
                    ),
                    Text('Credit Card'),
                    SizedBox(width: 16.0),
                    Radio(
                      value: false,
                      groupValue: creditCardSelected,
                      onChanged: (value) {
                        setState(() {
                          creditCardSelected = false;
                        });
                      },
                    ),
                    Text('PayPal'),
                  ],
                ),
                if (creditCardSelected) ...[
                  // Credit Card Form
                  TextField(
                    decoration: InputDecoration(labelText: 'Card Number'),
                  ),
                  SizedBox(height: 12.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(labelText: 'Expiration Date'),
                        ),
                      ),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(labelText: 'Security Code'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    decoration: InputDecoration(labelText: 'Name on Card'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewPage(),
                ),
              );
            },
            child: Text('Confirm and Continue'),
          ),
        ),
      ),
    );
  }
}

class CircleIndicator extends StatelessWidget {
  final String label;
  final bool isChecked;

  CircleIndicator({required this.label, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isChecked ? Colors.blue : Colors.grey,
          ),
          child: Icon(
            Icons.check,
            size: 16.0,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
