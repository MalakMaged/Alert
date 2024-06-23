import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'secrets.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:path_provider/path_provider.dart';



class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LatLng _initialPosition = const LatLng(30.0285952, 31.5523072);
  LatLng? _startLocation;
  LatLng? _destinationLocation;
  Set<Polyline> _polylines = {};
  Set<LatLng> _avoidCoordinates = {LatLng(30.027439045271805, 31.528331641070277)}; // Set to store avoid coordinates
  late GoogleMapController mapController;
  Set<Marker> crimeMarkers = {};
  
  bool placingPin = false;

  late Future<BitmapDescriptor> _startMarkerIcon;
  late Future<BitmapDescriptor> _destinationMarkerIcon;
  late Future<BitmapDescriptor> _carAccidentMarkerIcon;
  late Future<BitmapDescriptor> _fireAccidentMarkerIcon;
  late Future<BitmapDescriptor> _robberyAssaultMarkerIcon;
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
        crimeDetails['weaponDetected'],
      );
    }
  });
}

  @override
  void initState() {
    super.initState();
    _startMarkerIcon = _loadMarkerIcon('assets/first.png'); 
    _destinationMarkerIcon = _loadMarkerIcon('assets/finish.png');       
    _carAccidentMarkerIcon = _loadMarkerIcon('assets/accident.png');
    _fireAccidentMarkerIcon = _loadMarkerIcon('assets/fire.png');
    _robberyAssaultMarkerIcon = _loadMarkerIcon('assets/robbery.png');
 
    loadMarkersFromFirestore();
  }
    Future<BitmapDescriptor> _loadMarkerIcon(String assetName) async {
    final ByteData byteData = await rootBundle.load(assetName);
    final Uint8List imageData = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(imageData);
  }

Future<void> _addCrimeMarker(
  LatLng position,
  String description,
  Uint8List imageBytes,
  String reporterName,
  bool isAnonymous,
  String crimeType,
  DateTime reportTime,
  bool weaponDetected,  // Add this parameter

) async {
  final markerId = MarkerId('${position.latitude}-${position.longitude}');
  BitmapDescriptor markerIcon;

  switch (crimeType) {
    case 'Car Accident':
      markerIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'assets/car_accident.png');
      break;
    case 'Fire':
      markerIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'assets/fire.png');
      break;
    case 'Robbery/Assault':
      markerIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'assets/robbery_assault.png');
      break;
    default:
      markerIcon = BitmapDescriptor.defaultMarker;
  }

  final marker = Marker(
    markerId: markerId,
    position: position,
    icon: markerIcon,
    infoWindow: InfoWindow(
      title: 'Crime',
      snippet: '$reporterName - $reportTime\n$crimeType: $description',
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
    'imageUrl': base64Encode(imageBytes),
    'reporterName': reporterName,
    'isAnonymous': isAnonymous,
    'reportTime': Timestamp.fromDate(reportTime),
    'crimeType': crimeType,
    'weaponDetected': weaponDetected,  // Save the detection result

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
        // icon: await Marker,
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

  void _onMapTap(LatLng tappedPoint) async {
    setState(() {
      if (_startLocation == null) {
        _startLocation = tappedPoint;
        _addMarker(tappedPoint, 'start', _startMarkerIcon);
      } else if (_destinationLocation == null) {
        _destinationLocation = tappedPoint;
        _addMarker(tappedPoint, 'destination', _destinationMarkerIcon);
        _drawRoute();
      } else {
        _startLocation = tappedPoint;
        _destinationLocation = null;
        _polylines.clear();
        _clearMarkers();
      }
    });
  }

  void _addMarker(LatLng position, String markerId, Future<BitmapDescriptor> icon) async {
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: await icon,
    );

    setState(() {
      crimeMarkers.add(marker);
    });
  }

  void _clearMarkers() {
    setState(() {
      crimeMarkers.clear();
    });
  }

  Future<void> _drawRoute() async {
    if (_startLocation == null || _destinationLocation == null) return;

    // Fetch crime markers from Firestore
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('crimeMarkers').get();

    // Convert crime markers to a Set of LatLng
    final avoidCoordinates = querySnapshot.docs.map((doc) {
      final latitude = doc['latitude'] as double;
      final longitude = doc['longitude'] as double;
      return LatLng(latitude, longitude);
    }).toSet();

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_startLocation!.latitude},${_startLocation!.longitude}&destination=${_destinationLocation!.latitude},${_destinationLocation!.longitude}&key=${Secrets.API_KEY}&alternatives=true');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      List routes = data['routes'];
      _polylines.clear();
      bool anyRouteAdded = false;
      List<LatLng>? fallbackRoute = null;

      for (var i = 0; i < routes.length; i++) {
        List<LatLng> polylineCoordinates = _decodePoly(routes[i]['overview_polyline']['points']);
        bool containsAvoidCoordinate = polylineCoordinates.any((point) => _isNearAvoid(point, avoidCoordinates));

        if (!containsAvoidCoordinate) {
          _polylines.add(_createPolyline(i, polylineCoordinates));
          anyRouteAdded = true;
        } else  { 
          if(fallbackRoute == null)
          fallbackRoute = polylineCoordinates;
        }
      }

      if (!anyRouteAdded && fallbackRoute != null) {
        _askUserForFallback(fallbackRoute);
        loadMarkersFromFirestore(); 
      } else {
        _addMarker(_startLocation!, 'start', _startMarkerIcon);
        loadMarkersFromFirestore();
        setState(() {});  
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }

  void _askUserForFallback(List<LatLng> fallbackRoute) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Routing Issue'),
          content: const Text('All possible routes pass through dangerous areas. Display the best availableroute?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _polylines.add(_createPolyline(0, fallbackRoute)); // Add fallback route
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  Polyline _createPolyline(int index, List<LatLng> coordinates) {
    return Polyline(
      polylineId: PolylineId('route$index'),
      color: _getRouteColor(index),
      points: coordinates,
      width: 5,
    );
  }

  Color _getRouteColor(int routeIndex) {
    switch (routeIndex % 3) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      case 2:
        return Colors.black;
      default:
        return Colors.blue;
    }
  }

  bool _isNearAvoid(LatLng point, Set<LatLng> avoidCoordinates) {
    return avoidCoordinates.any((avoid) => _calculateDistance(point, avoid) < 250);
  }

  List<LatLng> _decodePoly(String poly) {
    List<int> list = poly.codeUnits;
    List<double> latLngList = [];
    int index = 0;
    int current = 0;
    int bit = 0;
    int result = 0;
    int shift;

    while (index < poly.length) {
      current = list[index] - 63;
      result |= (current & 0x1f) << (5 * bit);
      if (current < 0x20) {
        shift = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
        latLngList.add(shift.toDouble());
        index++;
        bit = 0;
        result = 0;
        continue;
      }
      index++;
      bit++;
    }

    List<LatLng> polylineCoordinates = [];
    double lat = 0;
    double lng = 0;

    for (int i = 0; i < latLngList.length; i += 2) {
      lat += latLngList[i] / 100000.0;
      lng += latLngList[i + 1] / 100000.0;
      polylineCoordinates.add(LatLng(lat, lng));
    }

    return polylineCoordinates;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    // harvesine formula
    final lat1 = point1.latitude;
    final lon1 = point1.longitude;
    final lat2 = point2.latitude;
    final lon2 = point2.longitude;
    const R = 6371000.0; // Earth radius in meters
    final phi1 = lat1 * (pi / 180);
    final phi2= lat2 * (pi / 180);
    final deltaPhi = (lat2 - lat1) * (pi / 180);
    final deltaLambda = (lon2 - lon1) * (pi / 180);

    final a = (sin(deltaPhi / 2) * sin(deltaPhi / 2)) +
              (cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in meters
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_initialPosition != null)
            GoogleMap(
             onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    _initialPosition!.latitude!, _initialPosition!.longitude!),
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              markers: crimeMarkers,
              onTap: placingPin ? _showPlacePinDialog : _onMapTap,
              polylines: _polylines,
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

  const CrimeDetailsPage(this.position, {super.key});

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
  bool weaponDetected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Crime Details'),
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
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              onChanged: (value) => reporterName = value,
              decoration: const InputDecoration(labelText: 'Reporter Name'),
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
                const Text('Anonymous'),
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

                  final detectionResult = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => YoloImage(imageBytes: imageBytes),
                    ),
                  );

                  setState(() {
                    weaponDetected = detectionResult['weaponDetected'];
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.redAccent, padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 16),
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
                    'weaponDetected': weaponDetected,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.redAccent, padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class YoloImage extends StatefulWidget {
  final Uint8List imageBytes;

  const YoloImage({required this.imageBytes, Key? key}) : super(key: key);

  @override
  State<YoloImage> createState() => _YoloImageState();
}

class _YoloImageState extends State<YoloImage> {
  late FlutterVision vision;
  List<Map<String, dynamic>> yoloResults = [];
  bool isLoaded = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  int? imageWidth;
  int? imageHeight;

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    loadYoloModel();
    loadImage(widget.imageBytes);
  }

  @override
  void dispose() {
    vision.closeYoloModel();
    super.dispose();
  }

  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
      labels: 'assets/labels.txt',
      modelPath: 'assets/best-fp16.tflite',
      modelVersion: "yolov5",
      numThreads: 8,
      useGpu: false,
    );
    setState(() {
      isLoaded = true;
    });
  }

  Future<void> loadImage(Uint8List imageBytes) async {
    try {
      final pickedFile = await _picker.getImage(source: ImageSource.gallery);
      final image = File(pickedFile!.path);
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage != null) {
        setState(() {
          _image = image;
          imageWidth = decodedImage.width;
          imageHeight = decodedImage.height;
        });
        yoloOnImage(image, imageWidth!, imageHeight!);
      } else {
        throw Exception("Decoded image is null");
      }
    } catch (e) {
      print("Error decoding or saving image: $e");
    }
  }

  Future<void> yoloOnImage(File image, int width, int height) async {
    try {
      if (!await image.exists()) {
        throw Exception("Image file does not exist");
      }
      final bytes = await image.readAsBytes();
      final result = await vision.yoloOnImage(
        bytesList: bytes,
        imageHeight: height,
        imageWidth: width,
        iouThreshold: 0.4,
        confThreshold: 0.4,
        classThreshold: 0.5,
      );
      setState(() {
        yoloResults = result;
      });

      final weaponDetected = yoloResults.any((result) => result['tag'] == 'knife');
      Navigator.pop(context, {'weaponDetected': weaponDetected});
    } catch (e) {
      print("Error during YOLO detection: $e");
      Navigator.pop(context, {'weaponDetected': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("YOLO Image Detection"),
      ),
      body: Column(
        children: [
          if (_image != null)
            Stack(
              children: [
                Image.file(_image!, fit: BoxFit.contain),
                ...displayBoxesAroundRecognizedObjects(size),
              ],
            ),
          if (_image == null)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty || _image == null) return [];
double factorX = screen.width / (imageWidth ?? 1);
double factorY = screen.height / (imageHeight ?? 1);

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return yoloResults.map((result) {
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: colorPick,
              width: 3,
            ),
          ),
          child: Text(
            "${result['tag']} ${(result['confidence'])}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.black,
              fontSize: 15,
            ),
          ),
        ),
      );
    }).toList();
  }
}
