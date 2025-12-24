import 'package:ebooking/models/city_model.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/providers/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ebooking/screens/customer_screens/results_screen.dart';
class SearchAccommodationsScreen extends StatefulWidget {
  @override
  _SearchAccommodationsScreenState createState() =>
      _SearchAccommodationsScreenState();
}

class _SearchAccommodationsScreenState extends State<SearchAccommodationsScreen> {
  DateTime? fromDate; // Selected from date
  DateTime? toDate; // Selected to date
  CalendarFormat _calendarFormat = CalendarFormat.month;
  City? _selectedCity;
  Country? _selectedCountry;

  int numberOfGuests = 1; // Initial number of guests
  int priceFrom = 0;
  int priceTo = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).fetchCountries();
    });
  }

  @override 
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search for Accommodations'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.grey[200],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  
                ),
                child: Column(
                  children:[
                    Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          height: 1.0,
                          color: Colors.black,
                        ),
                      ),
                      Icon(Icons.money),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          height: 1.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  // Price Range
                    Text(
                      'Price Range',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              priceFrom = int.tryParse(value) ?? 0;
                            });
                          },
                          decoration: InputDecoration(labelText: 'From', labelStyle: TextStyle(fontWeight:FontWeight.bold, fontSize: 18.0,), suffixText: '\$', floatingLabelAlignment: FloatingLabelAlignment.center),
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
                          decoration: InputDecoration(labelText: 'To', labelStyle: TextStyle(fontWeight:FontWeight.bold, fontSize: 18.0,), suffixText: '\$', floatingLabelAlignment: FloatingLabelAlignment.center),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              SizedBox(height: 30.0,),
              // Map Icon in the center of the break line
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      height: 1.0,
                      color: Colors.black,
                    ),
                  ),
                  Icon(Icons.map),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      height: 1.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              // Location Input
              DropdownButtonFormField(
                  value: _selectedCountry,
                  hint: const Text('Select Country'),
                  onChanged: (Country? newValue) async {
                    setState(() {
                      if (newValue != null) {
                      _selectedCountry = newValue;
                      _selectedCity = null;
                      }
                    });

                    if(_selectedCountry != null){
                      await Provider.of<LocationProvider>(context, listen: false).fetchCities(_selectedCountry?.id);
                    }
                  },
                  //fill items with countries from provider
                  items: (Provider.of<LocationProvider>(context, listen: true).countries).map<DropdownMenuItem<Country>>((Country country) {
                    return DropdownMenuItem<Country>(value: country, child: Text(country.name));
                  }).toList(),
               ),
                DropdownButtonFormField(
                  value: _selectedCity,
                  hint: const Text('Select City'),
                  onChanged: (City? newValue) {
                    setState(() {
                      _selectedCity = newValue;
                    });
                  },
                items: (Provider.of<LocationProvider>(context ,listen: true).cities).map<DropdownMenuItem<City>>((City city) {
                  return DropdownMenuItem<City>(value: city, child: Text(city.name));
                }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      height: 20,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.man),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      height: 20,
                    ),
                  ),
                ],
              ),
              // Guests Counter
              Text(
                'Guests',
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

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      height: 20,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.calendar_today),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      height: 20,
                    ),
                  ),
                ],
              ),
              // Check-in/Check-out
              Text(
                'Check-in/Check-out',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Calendar Input Field
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
                    } else if (selectedDay.isBefore(fromDate!)) {
                      // If selected day is before the current from date, reset the selection
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
                    print('fromDate: $fromDate, toDate: $toDate');
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  selectedDayPredicate: (day) {
                    // Highlight the selected date and the range between from and to dates
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
              // Search Button
              ElevatedButton.icon(
                onPressed: () async {
                  var results = await Provider.of<SearchProvider>(context, listen: false).search(priceFrom.toDouble(), priceTo.toDouble(), _selectedCity!.name, fromDate!, toDate!);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SearchResultPage(accommodations: results, numberOfDays: (toDate!.difference(fromDate!).inDays)+1)));
                },
                icon: Icon(Icons.search),
                label: Text('Search'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
