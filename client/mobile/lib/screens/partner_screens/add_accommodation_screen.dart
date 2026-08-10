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
  const AddAccommodationScreen({super.key});

  @override
  AddAccommodationScreenState createState() => AddAccommodationScreenState();
}

class AddAccommodationScreenState extends State<AddAccommodationScreen> {
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
    if (!mounted) return;
    try {
      resultList = await AssetPicker.pickAssets(
            context,
            pickerConfig: const AssetPickerConfig(
              maxAssets: 20,
              requestType: RequestType.image,
              selectedAssets: [],
            ),
          ) ??
          [];
    } on Exception catch (_) {
      // Ignore picker errors — user may have cancelled
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
    _addressController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _accommodationDetailsNumBeds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Accommodation'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Basic Information',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
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
                DropdownButtonFormField<Country>(
                  initialValue: _selectedCountry,
                  hint: const Text('Select Country'),
                  onChanged: (Country? newValue) async {
                    setState(() {
                      if (newValue != null) {
                        _selectedCountry = newValue;
                        _selectedCity = null;
                      }
                    });

                    if (_selectedCountry != null) {
                      final locationProvider = Provider.of<LocationProvider>(
                          context,
                          listen: false);
                      await locationProvider
                          .fetchCities(_selectedCountry?.id);
                    }
                  },
                  items: (Provider.of<LocationProvider>(context, listen: true)
                          .countries)
                      .map<DropdownMenuItem<Country>>((Country country) {
                    return DropdownMenuItem<Country>(
                        value: country, child: Text(country.name));
                  }).toList(),
                ),
                DropdownButtonFormField<City>(
                  initialValue: _selectedCity,
                  hint: const Text('Select City'),
                  onChanged: (City? newValue) {
                    setState(() {
                      _selectedCity = newValue;
                    });
                  },
                  items: (Provider.of<LocationProvider>(context, listen: true)
                          .cities)
                      .map<DropdownMenuItem<City>>((City city) {
                    return DropdownMenuItem<City>(
                        value: city, child: Text(city.name));
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 10),
                const Text('Accommodation Details',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: loadImages,
                    child: const Text('Load Images'),
                  ),
                ),
                const SizedBox(height: 10),
                images.isNotEmpty
                    ? SizedBox(
                        height: min(
                            images.length > 3
                                ? (images.length / 3).ceil() * 120.0
                                : 100.0,
                            MediaQuery.of(context).size.height),
                        child: Column(children: <Widget>[
                          Expanded(
                            child: CustomScrollView(
                              slivers: <Widget>[
                                SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
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
                                            if (selectedIndex == index &&
                                                indexCounter == 2) {
                                              images.removeAt(selectedIndex!);
                                              selectedIndex = null;
                                              indexCounter = 1;
                                            } else if (selectedIndex == null &&
                                                indexCounter == 1) {
                                              selectedIndex = index;
                                              indexCounter++;
                                            } else if (selectedIndex !=
                                                    index &&
                                                indexCounter == 1) {
                                              selectedIndex = index;
                                              indexCounter = 1;
                                            } else if (selectedIndex !=
                                                    index &&
                                                indexCounter == 2) {
                                              selectedIndex = index;
                                              indexCounter = 1;
                                            } else if (selectedIndex ==
                                                    index &&
                                                indexCounter == 1) {
                                              selectedIndex = index;
                                              indexCounter++;
                                            }
                                          });
                                        },
                                        child: Stack(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 100.0,
                                              width: 120.0,
                                              child: AssetThumbnail(
                                                  asset: asset),
                                            ),
                                            if (selectedIndex == index)
                                              SizedBox(
                                                height: 100.0,
                                                width: 120.0,
                                                child: ColoredBox(
                                                  color: Colors.red
                                                      .withValues(alpha: 0.5),
                                                  child: const Icon(
                                                      Icons.delete_outlined,
                                                      color: Colors.red),
                                                ),
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
                        ]))
                    : const SizedBox.shrink(),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _accommodationDetailsNumBeds,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 10),
                ..._accommodationDetails.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(key),
                    value: _accommodationDetails[key],
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          _accommodationDetails[key] = value;
                        });
                      }
                    },
                  );
                }),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final locationProvider = Provider.of<LocationProvider>(
                              context,
                              listen: false);
                          final accommodationProvider =
                              Provider.of<AccommodationProvider>(context,
                                  listen: false);
                          locationProvider
                              .craftGeoCode(
                                  '${_addressController.text} ${_selectedCity?.name} ${_selectedCountry?.name}')
                              .then((value) async {
                            Location locationToPass = Location(
                              latitude: value[0],
                              longitude: value[1],
                              address: _addressController.text,
                              cityId: _selectedCity?.id ?? '',
                            );
                            AccommodationImages accommodationImages =
                                AccommodationImages(
                                    images: await Future.wait(images
                                        .map((e) async => await e.file)
                                        .toList()));
                            AccommodationPOST accommodation = AccommodationPOST(
                              images: accommodationImages,
                              name: _nameController.text,
                              pricePerNight:
                                  double.parse(_priceController.text),
                              description: _descriptionController.text,
                              location: locationToPass,
                              typeOfAccommodation: 1,
                              accommodationDetails: AccommodationDetails(
                                numberOfBeds: int.parse(
                                    _accommodationDetailsNumBeds.text),
                                bathub: _accommodationDetails['Bathtub']!,
                                balcony: _accommodationDetails['Balcony']!,
                                privateBathroom:
                                    _accommodationDetails['Private Bathroom']!,
                                ac: _accommodationDetails['Air Conditioning']!,
                                terrace: _accommodationDetails['Terrace']!,
                                kitchen: _accommodationDetails['Kitchen']!,
                                privatePool:
                                    _accommodationDetails['Private Pool']!,
                                coffeeMachine:
                                    _accommodationDetails['Coffee Machine']!,
                                view: _accommodationDetails['View']!,
                                seaView: _accommodationDetails['Sea View']!,
                                washingMachine:
                                    _accommodationDetails['Washing Machine']!,
                                spaTub: _accommodationDetails['Spa Tub']!,
                                soundProof:
                                    _accommodationDetails['Soundproof']!,
                                breakfast: _accommodationDetails['Breakfast']!,
                              ),
                              status: true,
                            );
                            accommodationProvider
                                .addAccommodation(accommodation);
                          });
                        }
                      },
                      child: const Text('Submit'),
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
