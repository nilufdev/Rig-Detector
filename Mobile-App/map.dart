import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:shake/shake.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  late GoogleMapController mapController;

  final LatLng start = const LatLng(10.6798, 76.1370);
  final LatLng destination = const LatLng(10.6508, 76.06494);

  late LatLng currentPosition;
  List<LatLng> pathPoints = [];

  Timer? timer;
  int currentStep = 0;

  final int totalSteps = 60;

  final Random random = Random();

  ShakeDetector? shakeDetector;

  @override
  void initState() {
    super.initState();
    currentPosition = start;
    pathPoints = _generateRandomPath(start, destination, totalSteps);

    shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () {
        _storeCurrentLocation();
      },
      shakeThresholdGravity: 2.7, // adjust sensitivity
    );
  }

  List<LatLng> _generateRandomPath(LatLng start, LatLng end, int steps) {
    List<LatLng> points = [];

    for (int i = 0; i <= steps; i++) {
      double fraction = i / steps;

      double lat = start.latitude + (end.latitude - start.latitude) * fraction;
      double lng =
          start.longitude + (end.longitude - start.longitude) * fraction;

      double latOffset = (random.nextDouble() - 0.5) * 0.002;
      double lngOffset = (random.nextDouble() - 0.5) * 0.002;

      lat += latOffset * (1 - fraction);
      lng += lngOffset * (1 - fraction);

      points.add(LatLng(lat, lng));
    }
    return points;
  }

  void _startSimulation() {
    timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (currentStep >= pathPoints.length) {
        timer.cancel();
        return;
      }

      setState(() {
        currentPosition = pathPoints[currentStep];
        currentStep++;
        mapController.animateCamera(CameraUpdate.newLatLng(currentPosition));
      });
    });
  }

  Future<void> _storeCurrentLocation() async {
    try {
      await FirebaseFirestore.instance.collection('locations').add({
        'latitude': currentPosition.latitude,
        'longitude': currentPosition.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location stored to Firebase!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to store location: $e')));
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _startSimulation();
  }

  @override
  void dispose() {
    timer?.cancel();
    shakeDetector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: start, zoom: 14.5),
        markers: {
          Marker(
            markerId: const MarkerId('start'),
            position: start,
            infoWindow: const InfoWindow(title: 'Start'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
          Marker(
            markerId: const MarkerId('destination'),
            position: destination,
            infoWindow: const InfoWindow(title: 'Destination'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
          Marker(
            markerId: const MarkerId('current'),
            position: currentPosition,
            infoWindow: const InfoWindow(title: 'Current Position'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        },
        polylines: {
          Polyline(
            polylineId: const PolylineId('random_path'),
            points: pathPoints,
            color: Colors.blue,
            width: 5,
          ),
        },
      ),
    );
  }
}
