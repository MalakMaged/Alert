import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart'; // Ensure your API key is safely stored here

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LatLng _initialPosition = const LatLng(30.0285952, 31.5523072);
  LatLng? _startLocation;
  LatLng? _destinationLocation;
  Set<Polyline> _polylines = {};
  Set<LatLng> _avoidCoordinates = {LatLng(30.027439045271805, 31.528331641070277)}; // Set to store avoid coordinates

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition:
            CameraPosition(target: _initialPosition, zoom: 13),
        onTap: _onMapTap,
        markers: _buildMarkers(),
        polylines: _polylines,
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};
    if (_startLocation != null) {
      markers.add(Marker(markerId: MarkerId('start'), position: _startLocation!));
    }
    if (_destinationLocation != null) {
      markers.add(Marker(markerId: MarkerId('destination'), position: _destinationLocation!));
    }
    return markers;
  }

  void _onMapTap(LatLng tappedPoint) {
    setState(() {
      if (_startLocation == null) {
        _startLocation = tappedPoint;
      } else if (_destinationLocation == null) {
        _destinationLocation = tappedPoint;
        _drawRoute();
      } else {
        _startLocation = tappedPoint;
        _destinationLocation = null;
        _polylines.clear();
      }
    });
  }

  Future<void> _drawRoute() async {
    if (_startLocation == null || _destinationLocation == null) return;

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
        bool containsAvoidCoordinate = polylineCoordinates.any((point) => _isNearAvoid(point));

        if (!containsAvoidCoordinate) {
          _polylines.add(_createPolyline(i, polylineCoordinates));
          anyRouteAdded = true;
        } else  { 
          if(fallbackRoute == null)
          fallbackRoute = polylineCoordinates;
        }
      }

      if (!anyRouteAdded && fallbackRoute != null) {
        _askUserForFallback(fallbackRoute); // Ask user to accept the fallback route
      } else {
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
          content: const Text('All possible routes pass through dangerous areas. Display the best available route?'),
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

  bool _isNearAvoid(LatLng point) {
    return _avoidCoordinates.any((avoid) => _calculateDistance(point, avoid) < 1000);
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
    final lat1 = point1.latitude;
    final lon1 = point1.longitude;
    final lat2 = point2.latitude;
    final lon2 = point2.longitude;
    const R = 6371000.0; // Earth radius in meters
    final phi1 = lat1 * (pi / 180);
    final phi2 = lat2 * (pi / 180);
    final deltaPhi = (lat2 - lat1) * (pi / 180);
    final deltaLambda = (lon2 - lon1) * (pi / 180);

    final a = (sin(deltaPhi / 2) * sin(deltaPhi / 2)) +
              (cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in meters
  }
}

