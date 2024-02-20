import 'package:ebooking_desktop/models/country.dart';
import 'package:ebooking_desktop/services/http.dart';
import 'package:ebooking_desktop/pages/countries/modals/editCountryModal.dart';
import 'package:flutter/material.dart';

class ManageCountryPage extends StatefulWidget {
  @override
  _ManageCountryPageState createState() => _ManageCountryPageState();
}

class _ManageCountryPageState extends State<ManageCountryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<Country> countries = []; // Assuming Country is a defined class

  @override
  void initState() {
    super.initState();
    _fetchCountries(); // Populate 'countries' when the widget is initialized
  }

  String selectedCountryName = "";
  int selectedCountryId = 0;
  Future<void> _fetchCountries() async {
    try {
      final fetchedCountries = await CountryHttpService.fetchCountries();
      setState(() {
        countries = fetchedCountries;
      });
    } catch (e) {
      // Handle or show error
      print('Error fetching countries: $e');
    }
  }

  Future<void> _deleteCountry(int countryId) async {
    try {
      await CountryHttpService.deleteCountry(countryId);
      // After successfully deleting a country, update the list of countries.
      await _fetchCountries();
    } catch (e) {
      // Handle or show error
      print('Error deleting country: $e');
    }
  }

  Future<void> _updateCountry(BuildContext context, int id, String name) async {
    try {
      await showEditCountryModal(context, id, name);
      await _fetchCountries();  
    } catch (e) {
      print('Error updating country: $e');
    }

  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Countries"),
      ),
      body: Column(
        children: [
          // Form for adding a country
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Country Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a country name';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await CountryHttpService.addCountry(_nameController.text);
                        // After successfully adding a country, update the list of countries.
                        final updatedCountries = await CountryHttpService.fetchCountries();
                        setState(() {
                          countries = updatedCountries;
                        });
                      } catch (e) {
                        // Handle or show error
                        print('Error adding country: $e');
                      }
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
          // List of countries
          Expanded(
            child: ListView.builder(
              itemCount: countries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(countries[index].name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: (){
                          _updateCountry(context, countries[index].id, countries[index].name);
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Call the deleteCountry function when the trash icon is pressed
                          _deleteCountry(countries[index].id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}