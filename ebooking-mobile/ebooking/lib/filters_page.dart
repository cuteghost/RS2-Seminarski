import 'package:flutter/material.dart';

class FiltersPage extends StatefulWidget {

  
  @override
  _FiltersPageState createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  bool freeCancellation = false;
  double ratings = 5.0;
  List<bool> accommodationButtonStates = List.generate(8, (index) => false);
  List<bool> mealsButtonStates = [false, false];
  List<bool> roomFacilitiesButtonStates = List.generate(13, (index) => false);
  List<bool> bedroomsButtonStates = List.generate(4, (index) => false);
  bool freeCancellationButtonState = false;
  int priceFrom = 0;
  int priceTo = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filters'),
        actions: [
          TextButton(
            onPressed: () {
              // Apply Filters logic
            },
            child: Text(
              'Apply Filters',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterButton('Location', () {
              showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
              // You can return the widget for your modal content here
              return Container(
                height: 200.0,
                child: Expanded(
                  child: TextField(
                  decoration: InputDecoration(labelText: 'Location', labelStyle: TextStyle(fontWeight:FontWeight.bold, fontSize: 18.0,)),
                  )
              )
                );
            },
          );
              // Open Location Modal
            }),
            _buildFilterButton('Price', () {
              showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
              // You can return the widget for your modal content here
              return Container(
                height: 200.0,
                child: Row(children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        priceFrom = int.tryParse(value) ?? 0;
                      });
                    },
                    decoration: InputDecoration(labelText: 'From', labelStyle: TextStyle(fontWeight:FontWeight.bold, fontSize: 18.0,)),
                  ),
                ),
                Spacer(),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        priceTo = int.tryParse(value) ?? 0;
                      });
                    },
                    decoration: InputDecoration(labelText: 'To', labelStyle: TextStyle(fontWeight:FontWeight.bold, fontSize: 18.0,)),
                  ),
                ),
              ]),
                );
            },
          );
            }),
            _buildFilterSection('Type of Accommodation',[
             'House',
             'Hotels',
             'Resorts',
             'Apartments',
             'Villas',
             'Hostels',
             'Cottages',
             'Penthouse',],
              accommodationButtonStates
            ),
            _buildSliderSection('Ratings', [
              Slider(
                value: ratings,
                onChanged: (value) {
                  setState(() {
                    ratings = value;
                  });
                },
                min: 0,
                max: 10,
                divisions: 10,
                label: ratings.toString(),
              ),
            ]),
            _buildFilterSection('Meals', [
              'Breakfast Included',
              'Kitchen Facilities'],
              mealsButtonStates
            ),
            _buildFilterSection('Room Facilities', [
              'Bathtub',
              'Balcony',
              'Private Bathroom',
              'AC',
              'Terrace',
              'Kitchen',
              'Private pool',
              'Coffee Machine',
              'View',
              'Sea view',
              'Washing Machine',
              'Spa Tub',
              'Soundproof'],
              roomFacilitiesButtonStates
            ),
            _buildFilterSection('Number of Bedrooms', [
              '1 bedroom',
              '2 bedrooms',
              '3 bedrooms',
              '4+ bedrooms'],
              bedroomsButtonStates
            ),
            _buildToggleButton('Free Cancellation',freeCancellationButtonState, () { setState(() { freeCancellationButtonState = !freeCancellationButtonState; });}),
          ],
        ),
      ),
    );
  }

Widget _buildFilterButton(String label, VoidCallback onPressed) {
  return TextButton(
    onPressed: () {
      onPressed(); // Execute the provided onPressed callback
    },
    child: Text(label),
  );
}

Widget _buildFilterSection(String header, List<String> buttonNames, List<bool> buttonStates) {
  List<Widget> buttons = [];
  for (int i = 0; i < buttonStates.length; i++) {
    buttons.add(_buildToggleButton(
      buttonNames[i],
      buttonStates[i],
      () {
        setState(() {
          buttonStates[i] = !buttonStates[i];
        });
      },
    ));
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          header,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      Wrap(
        children: buttons,
        spacing: 8.0, // Adjust the spacing between buttons
      ),
    ],
  );
}

  Widget _buildToggleButton(String label, bool isToggled, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    child: Text(label),
    style: ElevatedButton.styleFrom(
      primary: isToggled ? Colors.blue : null,
    ),
  );
}
Widget _buildSliderSection(String header, List<Widget> buttons) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          header,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      Wrap(
        children: buttons,
        spacing: 8.0, // Adjust the spacing between buttons
      ),
    ],
  );
}
}