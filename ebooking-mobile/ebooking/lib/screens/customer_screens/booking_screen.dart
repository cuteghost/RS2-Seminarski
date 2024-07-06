import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/providers/reservation_provide.dart';
import 'package:ebooking/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ebooking/screens/customer_screens/checkout_screen.dart';

class BookingScreen extends StatefulWidget {
  final AccommodationGET accommodation;
  @override
  _BookingScreenState createState() => _BookingScreenState();

  BookingScreen({required this.accommodation});
}

class _BookingScreenState extends State<BookingScreen> {
  int numberOfGuests = 1; // Initial number of guests
  DateTime? fromDate; // Selected from date
  DateTime? toDate; // Selected to date
  CalendarFormat _calendarFormat = CalendarFormat.month;
  ValueNotifier<DateTime> _selectedDay = ValueNotifier(DateTime.now());
  DateTime firstFreeDay = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    Provider.of<ReservationProvider>(context, listen: false).fetchReservedDates(widget.accommodation.id);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, DateTime>> reservedDates = Provider.of<ReservationProvider>(context).reservedDates;
    print('Reserved Dates: $reservedDates');
    // Convert the list of maps to a list of DateTime ranges
    List<DateTimeRange> reservedRanges = reservedDates.map((map) {
      return DateTimeRange(start: map['Start']!, end: map['End']!);
    }).toList();
    while (reservedRanges.any((range) => firstFreeDay.isAfter(range.start) && firstFreeDay.isBefore(range.end))) {
      firstFreeDay = firstFreeDay.add(Duration(days: 1));
    }
    
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
              height: MediaQuery.of(context).size.height * 0.59,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(Duration(days: 365)),
                focusedDay: firstFreeDay,
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    this.firstFreeDay = focusedDay;
                  });

                  if (reservedRanges.any((range) => selectedDay.isAfter(range.start) && selectedDay.isBefore(range.end))) {
                    setState(() {
                      fromDate = null;
                      toDate = null;
                    });
                    return;
                  } else if (fromDate == null || toDate != null) {
                    // If from date is null or both from and to dates are selected, reset the selection
                    setState(() {
                      fromDate = selectedDay;
                      toDate = null;
                    });
                  } else if (selectedDay.isBefore(fromDate!)) {
                    // If selected day is before the current from date, reset the selection
                    setState(() {
                      fromDate = selectedDay;
                      toDate = null;
                    });
                  } else {
                    // If fromDate is already selected, check if the range from fromDate to selectedDay includes any reserved dates
                    if (reservedRanges.any((range) => 
                      (range.start.isAfter(fromDate!) && range.start.isBefore(selectedDay)) || 
                      (range.end.isAfter(fromDate!) && range.end.isBefore(selectedDay)))) {
                      setState(() {
                        fromDate = null;
                        toDate = null;
                      });
                      return;
                    } else {
                      // If the range does not include reserved dates, set the toDate
                      setState(() {
                        toDate = selectedDay;
                      });
                    }
                  }
                  print('fromDate: $fromDate, toDate: $toDate');
                },
                selectedDayPredicate: (day) {
                  // Highlight the selected date and the range between from and to dates
                  if (reservedRanges.any((range) => (day.isAfter(range.start) && day.isBefore(range.end)) || isSameDay(range.end, day))) return false;
                  return (fromDate != null &&
                          toDate != null &&
                          ((day.isAfter(fromDate!) &&
                                  day.isBefore(
                                      toDate!.add(Duration(days: 1)))) ||
                              isSameDay(day, fromDate!) ||
                              isSameDay(day, toDate!))) ||
                      (fromDate != null &&
                          toDate == null &&
                          isSameDay(day, fromDate!));
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.indigo[400],
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: Colors.black,
                  ),
                  todayDecoration: reservedRanges.any((range)=>
                        isSameDay(DateTime.now(), range.start) || isSameDay(DateTime.now(), range.end) || 
                        (DateTime.now().isAfter(range.start) && DateTime.now().isBefore(range.end))) ? BoxDecoration(
                    color: Colors.red[300],
                    shape: BoxShape.circle,
                  ):
                  BoxDecoration(
                    color: Colors.green[300],
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  // Use this builder to customize the appearance of the reserved dates
                  defaultBuilder: (context, date, events) {
                    DateTime dateOnly = DateTime(date.year, date.month, date.day);
                    if (reservedRanges.any((range) => 
                        dateOnly.isAtSameMomentAs(DateTime(range.start.year, range.start.month, range.start.day)) || 
                        dateOnly.isAtSameMomentAs(DateTime(range.end.year, range.end.month, range.end.day)) || 
                        (dateOnly.isAfter(range.start) && dateOnly.isBefore(range.end)))) {
                      // If the date is in a reserved range, return a widget with a custom appearance
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red[300],
                            shape: BoxShape.circle,
                          ),
                          height: 40.0,
                          width: 40.0,
                          child: Center(
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      );
                    } else if (isSameDay(fromDate, date) || isSameDay(toDate, date)) {
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red[300],
                            shape: BoxShape.circle,
                          ),
                          height: 40.0,
                          width: 40.0,
                          child: Center(
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green[300],
                            shape: BoxShape.circle,
                          ),
                          height: 40.0,
                          width: 40.0,
                          child: Center(
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 30.0),
            // Confirm Booking Button
            ElevatedButton(
              onPressed: () async {
                if (fromDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a valid date range'),
                    ),
                  );
                  return;
                }
                else if (toDate == null) {
                 toDate = fromDate;
                }
                ReservationPOST reservation = ReservationPOST(
                  accommodationId: widget.accommodation.id,
                  startDate: fromDate!,
                  endDate: toDate!,
                  numberOfGuests: numberOfGuests,
                );
                // await Provider.of<ReservationProvider>(context, listen: false).makeReservation(reservation);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(numberOfDays: toDate!.difference(fromDate!).inDays + 1, 
                                                         pricePerNight: widget.accommodation.pricePerNight, 
                                                         accommodationId: widget.accommodation.id, 
                                                         accommodationName: widget.accommodation.name,
                                                         reservation: reservation)
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
              ),
              child: Text('Confirm Booking'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
