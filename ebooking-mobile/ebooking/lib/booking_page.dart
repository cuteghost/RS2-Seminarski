import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'checkout_page.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int numberOfGuests = 1; // Initial number of guests
  DateTime? fromDate; // Selected from date
  DateTime? toDate; // Selected to date
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  TimeOfDay? _selectedCheckInTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Your Stay'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Number of Guests
            Text(
              'Number of guests',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (numberOfGuests > 1) {
                        numberOfGuests--;
                      }
                    });
                  },
                ),
                Text(
                  numberOfGuests.toString(),
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      numberOfGuests++;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            // Calendar
            Text(
              'Select Dates',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(Duration(days: 365)),
                focusedDay: fromDate ?? DateTime.now(),
                calendarFormat: _calendarFormat,
                onDaySelected: (selectedDay, focusedDay) {
                  if (fromDate == null || toDate != null) {
                    // If from date is null or both from and to dates are selected, reset the selection
                    setState(() {
                      fromDate = selectedDay;
                      toDate = null;
                    });
                  } else {
                    // If from date is already selected, set the to date
                    setState(() {
                      toDate = selectedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                selectedDayPredicate: (day) {
                  // Highlight the selected date range
                  return fromDate != null &&
                      toDate != null &&
                      day.isAfter(fromDate!) &&
                      day.isBefore(toDate!.add(Duration(days: 1)));
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            // Check-in Hours
            Text(
              'Check-in',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Check-in',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? selectedTime = await showRoundedTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: 12, minute: 0),
                );
                if (selectedTime != null) {
                  setState(() {
                    _selectedCheckInTime = selectedTime;
                  });
                }
              },
              child: Text(
                _selectedCheckInTime != null
                    ? 'Selected Time: ${_selectedCheckInTime!.format(context)}'
                    : 'Select Check-in Time',
              ),
            ),
            SizedBox(height: 16.0),
            // Confirm Booking Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue,
              ),
              child: Text('Confirm Booking'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Suggestions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
