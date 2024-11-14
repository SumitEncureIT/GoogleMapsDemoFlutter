import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_demo/consts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = Location();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  static const LatLng _pGooglePixel = LatLng(37.4223, -122.0848);
  static const LatLng _pApplePark = LatLng(37.3346, -122.0090);
  static const LatLng _postalPark =
      LatLng(26.140369676880724, 85.38601039184057);

  LatLng? _currentP = null;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getLocationsUpdates();
    // getLocationsUpdates().then((_) => {
    //       Future.delayed(Duration(seconds: 5), () {
    //         getPolylinePoints().then(
    //             (coordinates) => {generatesPolyLinesFromPoints(coordinates)});
    //       }),
    //     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? const Center(
              child: Text("Loading..."),
            )
          : Container(
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: GoogleMap(
                onMapCreated: ((GoogleMapController controller) =>
                    _mapController.complete(controller)),
                initialCameraPosition:
                    CameraPosition(target: _postalPark, zoom: 13),
                markers: {
                  Marker(
                      markerId: MarkerId("_currentLocation"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: _postalPark),
                  // Marker(
                  //     markerId: MarkerId("_sourceLocation"),
                  //     icon: BitmapDescriptor.defaultMarker,
                  //     position: _postalPark),
                  // Marker(
                  //     markerId: MarkerId("_destinationLocation"),
                  //     icon: BitmapDescriptor.defaultMarker,
                  //     position: _pApplePark)
                },
                // polylines: Set<Polyline>.of(polylines.values),
              ),
          ),
    );
  }

  Future<void> getLocationsUpdates() async {
    bool _serviceEnable;
    PermissionStatus _permissionGranted;

    _serviceEnable = await _locationController.serviceEnabled();
    if (_serviceEnable) {
      _serviceEnable = await _locationController.requestService();
    } else {
      return;
    }
    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          print("Current Location1 : $_currentP");
          _cameraToPosition(_postalPark);
        });
      }
    });
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 13);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  // Future<List<LatLng>> getPolylinePoints() async {
  //   List<LatLng> polylineCordinates = [];
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       GOOGLE_API_KEY,
  //       PointLatLng(_currentP!.latitude, _currentP!.longitude),
  //       PointLatLng(_postalPark.latitude, _postalPark.longitude),
  //       travelMode: TravelMode.driving);
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((PointLatLng point) {
  //       polylineCordinates.add(LatLng(point.latitude, point.longitude));
  //     });
  //   } else {
  //     print("Error Message : $result.errorMessage");
  //   }
  //   return polylineCordinates;
  // }
  //
  // void generatesPolyLinesFromPoints(List<LatLng> polylinesCoodinates) async {
  //   PolylineId id = PolylineId("poly");
  //   Polyline polyline = Polyline(
  //       polylineId: id,
  //       color: Colors.black,
  //       points: polylinesCoodinates,
  //       width: 3);
  //   setState(() {
  //     polylines[id] = polyline;
  //   });
  // }
}
