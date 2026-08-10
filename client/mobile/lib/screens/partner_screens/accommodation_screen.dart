import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AccommodationScreen extends StatefulWidget {
  final AccommodationGET accommodation;

  const AccommodationScreen({super.key, required this.accommodation});

  @override
  AccommodationScreenState createState() => AccommodationScreenState();
}

class AccommodationScreenState extends State<AccommodationScreen> {
  ValueNotifier<bool> hasChanges = ValueNotifier<bool>(false);
  late AccommodationGET accommodation;

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
  List<AssetEntity> images = <AssetEntity>[];
  int? selectedIndex;
  int indexCounter = 1;

  @override
  void initState() {
    super.initState();
    accommodation = widget.accommodation;
    _addressController.text = accommodation.location.address;
    _nameController.text = accommodation.name;
    _priceController.text = accommodation.pricePerNight.toString();
    _descriptionController.text = accommodation.description;
    _accommodationDetailsNumBeds.text =
        accommodation.accommodationDetails.numberOfBeds.toString();
    _accommodationDetails['Bathtub'] =
        accommodation.accommodationDetails.bathub;
    _accommodationDetails['Balcony'] =
        accommodation.accommodationDetails.balcony;
    _accommodationDetails['Private Bathroom'] =
        accommodation.accommodationDetails.privateBathroom;
    _accommodationDetails['Air Conditioning'] =
        accommodation.accommodationDetails.ac;
    _accommodationDetails['Terrace'] =
        accommodation.accommodationDetails.terrace;
    _accommodationDetails['Kitchen'] =
        accommodation.accommodationDetails.kitchen;
    _accommodationDetails['Private Pool'] =
        accommodation.accommodationDetails.privatePool;
    _accommodationDetails['Coffee Machine'] =
        accommodation.accommodationDetails.coffeeMachine;
    _accommodationDetails['View'] = accommodation.accommodationDetails.view;
    _accommodationDetails['Sea View'] =
        accommodation.accommodationDetails.seaView;
    _accommodationDetails['Washing Machine'] =
        accommodation.accommodationDetails.washingMachine;
    _accommodationDetails['Spa Tub'] =
        accommodation.accommodationDetails.spaTub;
    _accommodationDetails['Soundproof'] =
        accommodation.accommodationDetails.soundProof;
    _accommodationDetails['Breakfast'] =
        accommodation.accommodationDetails.breakfast;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodation Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[200],
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      const Text('Basic Information',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          hasChanges.value = true;
                          accommodation.name = value;
                        },
                        initialValue: accommodation.name,
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
                      const SizedBox(height: 10),
                      SizedBox(
                          height: 200.0,
                          child: maps.GoogleMap(
                            initialCameraPosition: maps.CameraPosition(
                                target: maps.LatLng(
                                    accommodation.location.latitude,
                                    accommodation.location.longitude),
                                zoom: 14.4746,
                                tilt: 2.0),
                            markers: () {
                              final markers = <maps.Marker>{};
                              markers.add(
                                maps.Marker(
                                  markerId: maps.MarkerId(accommodation.name),
                                  position: maps.LatLng(
                                      accommodation.location.latitude,
                                      accommodation.location.longitude),
                                ),
                              );
                              return markers;
                            }(),
                          )),
                    ])),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text('Accommodation Details',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200.0,
                        child: PageView.builder(
                          itemBuilder: (context, index) {
                            if (index == accommodation.images.images.length) {
                              return IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () async {
                                  await loadImages();
                                  for (var element in images) {
                                    accommodation.images.images
                                        .add(await element.file);
                                  }
                                  images.clear();
                                },
                              );
                            } else {
                              return GestureDetector(
                                onLongPress: () {
                                  setState(() {
                                    selectedIndex =
                                        selectedIndex == index ? -1 : index;
                                  });
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: FileImage(accommodation
                                              .images.images[index]!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    if (selectedIndex == index) ...[
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        bottom: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              accommodation.images.images
                                                  .insert(
                                                      0,
                                                      accommodation
                                                          .images.images
                                                          .removeAt(index));
                                              selectedIndex = -1;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.all(8.0),
                                            width: 173,
                                            decoration: BoxDecoration(
                                              color: Colors.blue
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8.0),
                                                bottomLeft:
                                                    Radius.circular(8.0),
                                              ),
                                            ),
                                            child: const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(Icons.home,
                                                    color: Colors.white,
                                                    size: 40.0),
                                                Text('Make Home Picture',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        bottom: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              accommodation.images.images
                                                  .removeAt(index);
                                              selectedIndex = -1;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.all(8.0),
                                            width: 174,
                                            decoration: BoxDecoration(
                                              color: Colors.red
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topRight: Radius.circular(8.0),
                                                bottomRight:
                                                    Radius.circular(8.0),
                                              ),
                                            ),
                                            child: const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(Icons.delete,
                                                    color: Colors.white,
                                                    size: 40.0),
                                                Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }
                          },
                          itemCount: accommodation.images.images.length + 1,
                        ),
                      ),
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
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        AccommodationDetails detailsToUpdate =
                            AccommodationDetails(
                          numberOfBeds:
                              int.parse(_accommodationDetailsNumBeds.text),
                          bathub: _accommodationDetails['Bathtub']!,
                          balcony: _accommodationDetails['Balcony']!,
                          privateBathroom:
                              _accommodationDetails['Private Bathroom']!,
                          ac: _accommodationDetails['Air Conditioning']!,
                          terrace: _accommodationDetails['Terrace']!,
                          kitchen: _accommodationDetails['Kitchen']!,
                          privatePool: _accommodationDetails['Private Pool']!,
                          coffeeMachine:
                              _accommodationDetails['Coffee Machine']!,
                          view: _accommodationDetails['View']!,
                          seaView: _accommodationDetails['Sea View']!,
                          washingMachine:
                              _accommodationDetails['Washing Machine']!,
                          spaTub: _accommodationDetails['Spa Tub']!,
                          soundProof: _accommodationDetails['Soundproof']!,
                          breakfast: _accommodationDetails['Breakfast']!,
                        );
                        final accommodationToUpdate = AccommodationPATCH(
                          id: accommodation.id,
                          status: accommodation.status,
                          images: accommodation.images,
                          name: _nameController.text,
                          pricePerNight: double.parse(_priceController.text),
                          description: _descriptionController.text,
                          accommodationDetails: detailsToUpdate,
                          typeOfAccommodation:
                              accommodation.typeOfAccommodation,
                        );
                        final provider = Provider.of<AccommodationProvider>(
                            context,
                            listen: false);
                        final result = await provider
                            .updateAccommodation(accommodationToUpdate);
                        if (!context.mounted) return;
                        if (result) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Success'),
                                  content: const Text(
                                      'Accommodation updated successfully'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              });
                        } else {
                          showAboutDialog(
                              context: context,
                              applicationName: 'Error',
                              children: <Widget>[
                                const Text('Failed to update accommodation'),
                              ]);
                        }
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
