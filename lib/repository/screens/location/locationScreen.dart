import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:in_minutes/repository/screens/bottomnav/bottomnavscreen.dart';
import 'package:in_minutes/repository/screens/location/maplocScreen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // disable mapscreen (false)
  final bool _mapSelectionEnabled = false;

  String _selectedAddress = 'Tap to get your current location';
  TextEditingController houseController = TextEditingController();
  TextEditingController areaController = TextEditingController();

  bool _loadingLocation = false;
  bool _saving = false;

  @override
  void dispose() {
    houseController.dispose();
    areaController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📍 Location service is disabled')),
        );
        setState(() => _loadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        setState(() => _loadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.isNotEmpty ? placemarks.first : null;

      setState(() {
        _selectedAddress =
            place != null
                ? '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}'
                : '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to get location')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _openMapPicker() async {
    if (!_mapSelectionEnabled) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapPickerScreen()),
    );
    if (result != null && result is String) {
      setState(() {
        _selectedAddress = result;
      });
    }
  }

  bool get _canSave {
    return _selectedAddress.isNotEmpty &&
        !_selectedAddress.contains('Tap') &&
        houseController.text.trim().isNotEmpty &&
        areaController.text.trim().isNotEmpty &&
        !_saving;
  }

  Future<void> _saveAddress() async {
    if (!_canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please fill all fields')),
      );
      return;
    }

    setState(() => _saving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .add({
            'address': _selectedAddress,
            'house': houseController.text.trim(),
            'area': areaController.text.trim(),
            'timestamp': Timestamp.now(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Address Saved')));
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Bottomnavscreen()),
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to save address')),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildAddressTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    final tile = Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: enabled ? Colors.grey[100] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: enabled ? Colors.black87 : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: enabled ? Colors.black : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: enabled ? Colors.black87 : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (!enabled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Disabled',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(opacity: enabled ? 1.0 : 0.7, child: tile),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black54),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomImageHeight = 160.0;
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width > 700;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF7CB45),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7CB45),
        elevation: 0,
        title: const Text(
          'Select Address',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomImageHeight * 0.6),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Where should we deliver?',
                          style: TextStyle(
                            fontSize: isWide ? 20 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Current location
                      _buildAddressTile(
                        title: 'Use Current Location',
                        subtitle: _selectedAddress,
                        icon: Icons.my_location,
                        onTap: _getCurrentLocation,
                        enabled: true,
                      ),

                      const SizedBox(height: 14),

                      // Map selection (visible but disabled)
                      _buildAddressTile(
                        title: 'Select From Map',
                        subtitle: 'Tap to choose address on map',
                        icon: Icons.map_outlined,
                        onTap: _openMapPicker,
                        enabled: _mapSelectionEnabled,
                      ),

                      const SizedBox(height: 24),

                      _buildTextField(houseController, 'House / Flat No.'),
                      const SizedBox(height: 12),
                      _buildTextField(areaController, 'Area / Landmark'),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _canSave ? _saveAddress : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffF7CB45),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  _saving
                                      ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        'Save Address',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      if (!_mapSelectionEnabled)
                        Center(
                          child: Text(
                            'Map selection is currently disabled. Current location is available.',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
