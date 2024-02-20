import 'package:ebooking_desktop/services/http.dart';
import 'package:flutter/material.dart';

Future <void> showEditCountryModal(BuildContext context, int countryId, String countryName) async {
  String selectedCountryName = countryName;

  showModalBottomSheet<void> (
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Edit Country',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              initialValue: countryName,
              decoration: InputDecoration(
                labelText: 'New Country Name',
              ),
              onChanged: (value) {
                selectedCountryName = value;
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                try {
                  await CountryHttpService.editCountry(
                    selectedCountryName,
                    countryId,
                  );
                  Navigator.pop(context); // Close the modal
                } catch (e) {
                  // Handle or show error
                  print('Error editing country: $e');
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      );
    },
  );
}