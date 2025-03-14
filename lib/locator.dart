import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class AyurvedicStoresPage extends StatefulWidget {
  @override
  _AyurvedicStoresPageState createState() => _AyurvedicStoresPageState();
}

class _AyurvedicStoresPageState extends State<AyurvedicStoresPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  List<Marker> _markers = [];
  final String _mapsApiKey = "AIzaSyA-15D8KYUzHIqGvOZ6lNkCiTaqLlnMM2U";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
    });

    // Center map to user's location
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(position.latitude, position.longitude),
      14,
    ));

    _fetchNearbyStores(position.latitude, position.longitude);
  }

  Future<void> _fetchNearbyStores(double lat, double lng) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng&radius=5000&type=store&keyword=ayurvedic&key=$_mapsApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['results'] != null) {
        setState(() {
          _markers = data['results'].map<Marker>((place) {
            final lat = place['geometry']['location']['lat'];
            final lng = place['geometry']['location']['lng'];
            final name = place['name'];
            return Marker(
              markerId: MarkerId(place['place_id']),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name),
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching stores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nearby Ayurvedic Stores", style: TextStyle(color: Colors.white,))),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          // Automatically move the camera to the current location
          if (_currentPosition != null) {
            _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
              LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              14,
            ));
          }
        },
        markers: Set.from(_markers),
        myLocationEnabled: true,
      ),
    );
  }
}
