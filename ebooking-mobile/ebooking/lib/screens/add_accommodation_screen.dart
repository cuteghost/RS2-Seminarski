import 'package:ebooking/models/city_model.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebooking/providers/location_provider.dart';

class AddAccommodationScreen extends StatefulWidget {
  @override
  _AddAccommodationScreenState createState() => _AddAccommodationScreenState();
}

class _AddAccommodationScreenState extends State<AddAccommodationScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCity;
  String? _selectedCountry;

  // Sample data for checkboxes
  Map<String, bool> _accommodationDetails = {
    'Bathtub': false,
    'Balcony': false,
    'Private Bathroom': false,
    'Air Conditioning': false,
    'Terrace': false,
    'Kitchen': false,
    'Private Pool': false,
    'Coffee Machine': false,
    'View': false,
    'Sea View': false,
    'Washing Machine': false,
    'Spa Tub': false,
    'Soundproof': false,
    'Breakfast': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Accommodation'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the accommodation name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Price Per Night',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the price per night';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCity = newValue;
                    });
                  },
                  items: locationProvider.cities
                      .map<DropdownMenuItem<String>>((dynamic city) {
                    final City typedCity = city as City;
                    return DropdownMenuItem<String>(
                      value: typedCity.id,
                      child: Text(typedCity.name),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCountry = newValue;
                    });
                  },
                  items: locationProvider.cities
                      .map<DropdownMenuItem<String>>((dynamic country) {
                    final Country typedCountry = country as Country;
                    return DropdownMenuItem<String>(
                      value: typedCountry.id,
                      child: Text(typedCountry.name),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                ..._accommodationDetails.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(key),
                    value: _accommodationDetails[key],
                    onChanged: (bool? value) {
                      // Accept a nullable bool
                      if (value != null) {
                        // Check if the value is not null
                        setState(() {
                          _accommodationDetails[key] = value;
                        });
                      }
                    },
                  );
                }).toList(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Using the null check operator `!`
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Processing Data')),
                          );
                          // Call a provider or bloc method to save the data
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
