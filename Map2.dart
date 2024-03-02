import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

//key : AIzaSyB5GDGXGS7IHSwJI95-Y1OMcEfmTsSuiN
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Polyline',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController _mapController;
  late LocationData _currentLocation;
  late LocationData _destinationLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _destinationLocation = LocationData.fromMap({
      "latitude": 31.2001,
      "longitude": 29.9187,
    });
  }

  void _getCurrentLocation() async {
    var location = Location();
    _currentLocation = await location.getLocation();
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId("currentLocation"),
        position:
            LatLng(_currentLocation.latitude!, _currentLocation.longitude!),
        infoWindow: InfoWindow(title: "Current Location"),
      ));
    });
  }

  void _drawPolyline() {
    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId("polyline"),
        color: Colors.blue,
        width: 5,
        points: [
          LatLng(_currentLocation.latitude!, _currentLocation.longitude!),
          LatLng(
              _destinationLocation.latitude!, _destinationLocation.longitude!),
        ],
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(24.8960309, 67.0792159),
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _drawPolyline,
              child: Text("Draw Polyline"),
            ),
          ),
        ],
      ),
    );
  }
}
