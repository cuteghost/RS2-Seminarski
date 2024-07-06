
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/models/city_model.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/location_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ebooking/widgets/asset_thumbnail.dart';

class AddAccommodationScreen extends StatefulWidget {
  @override
  _AddAccommodationScreenState createState() => _AddAccommodationScreenState();
}

class _AddAccommodationScreenState extends State<AddAccommodationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _accommodationDetailsNumBeds = TextEditingController(); 
  final _accommodationDetails = {
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
  City? _selectedCity;
  Country? _selectedCountry;
  List<AssetEntity> images = <AssetEntity>[];
  int? selectedIndex;
  int indexCounter = 1;

  Future<void> loadImages() async {
    PermissionStatus status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        return;
      }
    }

    List<AssetEntity> resultList = <AssetEntity>[];
    try {
      resultList = await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(
          maxAssets: 20,
          requestType: RequestType.image,
          selectedAssets: [],
        ),
      ) ?? [];
    } on Exception catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
      
    });
}

  
  
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
                const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
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
                  controller: _priceController,
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
                  controller: _descriptionController,
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
              SizedBox(height: 10),
              TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the address';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 10),
                const Text('Accommodation Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 10),
                
                Center(
                  child: ElevatedButton(
                    child: Text("Load Images"),
                    onPressed: loadImages,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  child: images.isNotEmpty ?
                    Container(
                      alignment: Alignment.center,
                      height: min(images.length > 3 ? (images.length / 3).ceil() * 120.0 : 100.0, MediaQuery.of(context).size.height),
                      child: Column(
                        children: <Widget>[
                            Expanded(
                              
                              child: CustomScrollView(
                                slivers: <Widget>[
                                  SliverGrid(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 1.0,
                                      crossAxisSpacing: 1.0,

                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        AssetEntity asset = images[index];
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (selectedIndex == index && indexCounter == 2) {
                                                images.removeAt(selectedIndex!);
                                                selectedIndex = null;
                                                indexCounter = 1;
                                              }
                                              else if(selectedIndex == null && indexCounter == 1){
                                                selectedIndex = index;
                                                indexCounter++;
                                              }
                                              else if(selectedIndex != index && indexCounter == 1){
                                                selectedIndex = index;
                                                indexCounter = 1;
                                              }
                                              else if(selectedIndex != index && indexCounter == 2){
                                                selectedIndex = index;
                                                indexCounter = 1;
                                              }
                                              else if(selectedIndex == index && indexCounter == 1){
                                                selectedIndex = index;
                                                indexCounter++;
                                              }
                                              print('Index $index <> Selected $selectedIndex <> Counter $indexCounter');
                                              
                                          });
                                          },
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                              height: 100.0,
                                              width: 120.0,
                                              child: AssetThumbnail(asset: asset),
                                              ),
                                              if(selectedIndex == index)
                                                Container(
                                                  height: 100.0,
                                                  width: 120.0,
                                                  color: Colors.red.withOpacity(0.5),
                                                  child: Icon(Icons.delete_outlined, color: Colors.red),
                                                )
                                            ],
                                          ),
                                        );
                                      },
                                      childCount: images.length,
                                    ),
                                  ),
                                ],
                              ),
                          )
                        ]
                      )
                    )
                  :
                    SizedBox.shrink()
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _accommodationDetailsNumBeds,
                  decoration: InputDecoration(
                    labelText: 'Number of Beds',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the number of beds';
                    }
                    return null;
                  },
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
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: ElevatedButton (
                      child: Text('Submit'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          Provider.of<LocationProvider>(context, listen: false).craftGeoCode('${_addressController.text} ${_selectedCity?.name} ${_selectedCountry?.name}').then((value) async {
                            Location locationToPass = Location(
                              latitude: value[0],
                              longitude: value[1],
                              address: _addressController.text,
                              cityId: _selectedCity?.id ?? '',
                            );
                              AccommodationImages accommodationImages = AccommodationImages(
                                images: await Future.wait(images.map((e) async => await e.file).toList())
                                );
                              AccommodationPOST accommodation = AccommodationPOST(
                                images: accommodationImages,
                                name: _nameController.text,
                                pricePerNight: double.parse(_priceController.text),
                                description: _descriptionController.text,
                                location: locationToPass,
                                typeOfAccommodation: 1,
                                accommodationDetails: AccommodationDetails(
                                  numberOfBeds: int.parse(_accommodationDetailsNumBeds.text),
                                  bathub: _accommodationDetails['Bathtub']!,
                                  balcony: _accommodationDetails['Balcony']!,
                                  privateBathroom: _accommodationDetails['Private Bathroom']!,
                                  ac: _accommodationDetails['Air Conditioning']!,
                                  terrace: _accommodationDetails['Terrace']!,
                                  kitchen: _accommodationDetails['Kitchen']!,
                                  privatePool: _accommodationDetails['Private Pool']!,
                                  coffeeMachine: _accommodationDetails['Coffee Machine']!,
                                  view: _accommodationDetails['View']!,
                                  seaView: _accommodationDetails['Sea View']!,
                                  washingMachine: _accommodationDetails['Washing Machine']!,
                                  spaTub: _accommodationDetails['Spa Tub']!,
                                  soundProof: _accommodationDetails['Soundproof']!,
                                  breakfast: _accommodationDetails['Breakfast']!,
                                ),
                                status: true,
                              );
                              Provider.of<AccommodationProvider>(context, listen: false).addAccommodation(accommodation);
                              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PartnerProfilePage()));
                                
                              
                          });
                        }
                      },
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

