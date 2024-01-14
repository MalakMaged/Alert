import 'dart:typed_data';
import 'constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';



class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}


class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  LocationData? currentLocation;
  Set<Marker> crimeMarkers = {};
  bool placingPin = false;

  @override
  void initState() {
    
    super.initState();
    getLocation();
    loadMarkersFromFirestore();
  }

  Future<void> getLocation() async {
    try {
      var location = Location();
      var currentLocation = await location.getLocation();
      setState(() {
        this.currentLocation = currentLocation;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _addCrimeMarker(
    
      LatLng position,
      String description,
      Uint8List imageBytes,
      String reporterName,
      bool isAnonymous,
      String crimeType,
      DateTime reportTime) async {
    final markerId = MarkerId('${position.latitude}-${position.longitude}');
    final marker = Marker(
      markerId: markerId,
      position: position,
      icon: BitmapDescriptor.fromBytes(imageBytes),
      infoWindow: InfoWindow(
        title: 'Crime',
        snippet: '$reporterName - $reportTime\n$Type: $crimeType\n$description',
      ),
    );

    setState(() {
      crimeMarkers.add(marker);
    });

    DocumentReference<Map<String, dynamic>> docRef =
        await FirebaseFirestore.instance.collection('crimeMarkers').add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'description': description,
      'imageUrl': '',
      'reporterName': reporterName,
      'isAnonymous': isAnonymous,
      'reportTime': Timestamp.fromDate(reportTime),
      'crimeType': crimeType,
    });

    String imageUrl = await _uploadImageToFirestore(imageBytes, docRef.id);

    await docRef.update({'imageUrl': imageUrl});
  }

  Future<String> _uploadImageToFirestore(
      Uint8List imageBytes, String documentId) async {
    String imageName = DateTime.now().toIso8601String();

    Reference ref =
        FirebaseStorage.instance.ref().child('crime_images/$imageName.jpg');
    UploadTask uploadTask = ref.putData(imageBytes);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    return imageUrl;
  }

  Future<void> loadMarkersFromFirestore() async {
    final markers =
        await FirebaseFirestore.instance.collection('crimeMarkers').get();

    for (var doc in markers.docs) {
      
      final latitude = doc['latitude'] as double;
      final longitude = doc['longitude'] as double;
      final description = doc['description'] as String;
      final imageUrl = doc['imageUrl'] as String;
      final reporterName = doc['reporterName'] as String;
      final isAnonymous = doc['isAnonymous'] as bool;
      final reportTime = (doc['reportTime'] as Timestamp).toDate();
      final crimeType = doc['crimeType'] as String;

      final markerId = MarkerId('$latitude-$longitude');
      final marker = Marker(
        markerId: markerId,
        position: LatLng(latitude, longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerColor(crimeType)),
        infoWindow: InfoWindow(
          title: 'Crime',
          snippet: '''
          Crime Type: $crimeType
          Description: $description
          Reporter: $reporterName
          Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(reportTime)}
        ''',
        ),
      );

      setState(() {
        crimeMarkers.add(marker);
      });
    }
  }

  double _getMarkerColor(String crimeType) {
    
    switch (crimeType) {
      case 'CarAccident':
        return BitmapDescriptor.hueBlue;
      case 'fireAccident':
        return BitmapDescriptor.hueOrange;
      case 'robberyAssault':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  Future<void> _showPlacePinDialog(LatLng position) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrimeDetailsPage(position),
      ),
    ).then((crimeDetails) {
      if (crimeDetails != null) {
        _addCrimeMarker(
          position,
          crimeDetails['description'],
          crimeDetails['imageBytes'],
          crimeDetails['reporterName'],
          crimeDetails['isAnonymous'],
          crimeDetails['crimeType'],
          crimeDetails['reportTime'],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: [
          if (currentLocation != null)
            GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              markers: crimeMarkers,
              onTap: (LatLng position) {
                if (placingPin) {
                  _showPlacePinDialog(position);
                }
              },
            ),
          Positioned(
            bottom: 16,
            left: 16,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  placingPin = !placingPin;
                });
              },
              child: Text(placingPin ? 'Cancel Placing Pin' : 'Place Pin'),
            ),
          ),
        ],
      ),
    );
  }
}

class CrimeDetailsPage extends StatefulWidget {
  
  final LatLng position;

  CrimeDetailsPage(this.position);

  @override
  _CrimeDetailsPageState createState() => _CrimeDetailsPageState();
}

class _CrimeDetailsPageState extends State<CrimeDetailsPage> {
  
  String description = '';
  Uint8List imageBytes = Uint8List(0);
  String reporterName = '';
  bool isAnonymous = false;
  String crimeType = 'Car Accident';
  DateTime reportTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Crime Details'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: crimeType,
              onChanged: (value) {
                setState(() {
                  crimeType = value!;
                });
              },
              items: <String>[
                'Car Accident',
                'Fire',
                'Robbery/Assault',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              onChanged: (value) => description = value,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              onChanged: (value) => reporterName = value,
              decoration: InputDecoration(labelText: 'Reporter Name'),
            ),
            Row(
              children: [
                Checkbox(
                  value: isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      isAnonymous = value!;
                    });
                  },
                ),
                Text('Anonymous'),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final imagePicker = ImagePicker();
                final pickedFile =
                    await imagePicker.pickImage(source: ImageSource.gallery);

                if (pickedFile != null) {
                  final bytes = await pickedFile.readAsBytes();
                  setState(() {
                    imageBytes = bytes;
                  });
                }
              },
              child: Text('Pick Image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                primary: Colors.redAccent,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  {
                    'description': description,
                    'imageBytes': imageBytes,
                    'reporterName': reporterName,
                    'isAnonymous': isAnonymous,
                    'crimeType': crimeType,
                    'reportTime': reportTime,
                  },
                );
              },
              
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                primary: Colors.redAccent,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
