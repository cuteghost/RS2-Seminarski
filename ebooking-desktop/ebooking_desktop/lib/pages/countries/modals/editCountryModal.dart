import 'package:ebooking_desktop/services/location_service.dart';
import 'package:flutter/material.dart';

Future <void> showEditCountryModal(BuildContext context, String countryId, String countryName) async {
  String selectedCountryName = countryName;

  showModalBottomSheet<void> (
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Edit Country',
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              initialValue: countryName,
              decoration: const InputDecoration(
                labelText: 'New Country Name',
              ),
              onChanged: (value) {
                selectedCountryName = value;
              },
            ),
            const SizedBox(height: 16.0),
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
              child: const Text('Save'),
            ),
          ],
        ),
      );
    },
  );
}