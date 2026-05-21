import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart'; // 🔹 Naya add kiya current location ke liye
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  // 🔹 Optional parameter agar LocationScreen se location bhejna chahein
  final LatLng? initialLocation;

  const MapPickerScreen({Key? key, this.initialLocation}) : super(key: key);

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng selectedLatLng;
  GoogleMapController? mapController;

  bool _isFetchingAddress = false; // Load state for button
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default location
    selectedLatLng = widget.initialLocation ?? const LatLng(28.6139, 77.2090);

    // Agar start mein location nahi mili, toh phone ki current location nikal lo
    if (widget.initialLocation == null) {
      _moveToCurrentLocation();
    }
  }

  // 🔹 Ye function khulte hi map ko user ke ghar le jayega
  Future<void> _moveToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        selectedLatLng = currentLatLng;
      });

      // Map camera ko smoothly nayi jagah le jana
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLatLng, zoom: 16),
        ),
      );
    } catch (e) {
      debugPrint("Could not get current location: $e");
    }
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      setState(() {
        _isFetchingAddress = true;
        _errorMessage = null;
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        selectedLatLng.latitude,
        selectedLatLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // 🔹 Null check taaki khali data na aaye
        String address =
            "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}";

        // Faltu commas ko saaf karne ka formula
        address = address
            .replaceAll(RegExp(r'^, |, $'), '')
            .replaceAll(', ,', ',');

        if (mounted) {
          Navigator.pop(
            context,
            address,
          ); // 🔹 LocationScreen ko wapas address bhej diya
        }
      } else {
        setState(() => _errorMessage = "No address found for this location");
      }
    } catch (e) {
      setState(
        () => _errorMessage = "Failed to get address. Please try again.",
      );
    } finally {
      if (mounted) {
        setState(() => _isFetchingAddress = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Pick Location",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xffF7CB45), // 🔹 App theme se match
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: selectedLatLng,
              zoom: 16,
            ),
            onCameraMove: (position) {
              selectedLatLng = position.target;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),

          // center pin location
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35.0),
              child: Icon(Icons.location_on, size: 40, color: Colors.red),
            ),
          ),

          // ERROR MESSAGE
          if (_errorMessage != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),

      // FLOATING BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isFetchingAddress ? null : _getAddressFromLatLng,
        backgroundColor: const Color(0xffF7CB45),
        label:
            _isFetchingAddress
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
                : const Text(
                  "Confirm Location",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        icon:
            _isFetchingAddress
                ? null
                : const Icon(Icons.check, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
