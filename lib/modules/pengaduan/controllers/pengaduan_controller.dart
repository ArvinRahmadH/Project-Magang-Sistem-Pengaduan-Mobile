import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../maps/views/maps_page.dart';

class PengaduanController {
  // Dependencies
  final String token;
  BuildContext? _context;

  // State
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  bool isLoading = false;
  bool locationLoading = false;
  File? image;
  double? latitude;
  double? longitude;
  String? selectedCategory;

  final ImagePicker picker = ImagePicker();
  final List<String> categories = [
    "Keamanan dan Ketertiban",
    "Kriminalitas",
    "Lalu Lintas",
    "Pelayanan Kepolisian",
    "Lainnya",
  ];

  PengaduanController(this.token);

  // Set context for navigation and dialogs
  void setContext(BuildContext context) {
    _context = context;
  }

  // Location Methods
  Future<void> getCurrentLocation() async {
    if (_context == null) return;

    locationLoading = true;
    _notifyListeners();

    try {
      // Check GPS service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar("GPS tidak aktif, nyalakan dulu", Colors.orange);
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar("Izin lokasi ditolak", Colors.red);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar("Izin lokasi permanen ditolak", Colors.red);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      latitude = position.latitude;
      longitude = position.longitude;

      _showSnackBar("📍 Lokasi berhasil didapat", Colors.green);
    } catch (e) {
      print('Error getCurrentLocation: $e');
      _showSnackBar("⚠️ Gagal mendapatkan lokasi", Colors.orange);
    } finally {
      locationLoading = false;
      _notifyListeners();
    }
  }

  // Image Methods
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      _notifyListeners();
    }
  }

  void removeImage() {
    image = null;
    _notifyListeners();
  }

  // Category Methods
  void setCategory(String? category) {
    selectedCategory = category;
    _notifyListeners();
  }

  // Validation Methods
  String? validateForm() {
    if (titleController.text.isEmpty) return "Judul/alamat wajib diisi";
    if (contentController.text.isEmpty) return "Deskripsi masalah wajib diisi";
    if (image == null) return "Gambar wajib diupload";
    if (selectedCategory == null) return "Pilih kategori permasalahan";
    return null;
  }

  bool get hasLocation => latitude != null && longitude != null;

  Future<bool> handleMissingLocation() async {
    if (_context == null) return false;

    final shouldContinue = await showDialog<bool>(
      context: _context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "⚠️ Lokasi Tidak Ditemukan",
          style: TextStyle(color: Colors.orange),
        ),
        content: const Text(
          "Lokasi tidak terdeteksi. Lanjutkan dengan lokasi default atau pilih manual di peta?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Pilih Manual",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Lanjut Default",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );

    return shouldContinue ?? false;
  }

  void setDefaultLocation() {
    latitude = -7.982298;
    longitude = 112.630539;
    _notifyListeners();
  }

  void setManualLocation(LatLng location) {
    latitude = location.latitude;
    longitude = location.longitude;
    _notifyListeners();
  }

  // API Methods
  Future<void> submitPengaduan() async {
    if (_context == null) return;

    final validationError = validateForm();
    if (validationError != null) {
      _showSnackBar(validationError, Colors.orange);
      return;
    }

    // Handle missing location
    if (!hasLocation) {
      final useDefault = await handleMissingLocation();
      if (!useDefault) return;
      setDefaultLocation();
    }

    isLoading = true;
    _notifyListeners();

    try {
      var uri = Uri.parse("http:");
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['kategori'] = selectedCategory!;
      request.fields['title'] = titleController.text;
      request.fields['content'] = contentController.text;
      request.fields['latitude'] = latitude!.toString();
      request.fields['longitude'] = longitude!.toString();

      // Debug print
      print('=== DATA PENGADUAN ===');
      print('Kategori: $selectedCategory');
      print('Judul: ${titleController.text}');
      print('Lokasi: $latitude, $longitude');

      request.files.add(await http.MultipartFile.fromPath('image', image!.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar("✅ Catatan berhasil disimpan!", Colors.green);
        resetForm();
      } else {
        _showSnackBar("❌ Gagal menyimpan: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      _showSnackBar("❌ Error: $e", Colors.red);
    } finally {
      isLoading = false;
      _notifyListeners();
    }
  }

  // Logout Method
  Future<void> logout() async {
    if (_context == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    // Navigate to login page
    Navigator.pushReplacementNamed(_context!, '/login');
  }

  // Reset Form
  void resetForm() {
    titleController.clear();
    contentController.clear();
    image = null;
    selectedCategory = null;
    // Keep location for next input
    _notifyListeners();
  }

  // Navigation Methods
  Future<LatLng?> navigateToMaps() async {
    if (_context == null) return null;

    final location = await Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => const MapsPage(),
      ),
    );

    return location is LatLng ? location : null;
  }

  // Helper Methods
  void _showSnackBar(String message, Color color) {
    if (_context != null && _context!.mounted) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Listeners
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  // Cleanup
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    _listeners.clear();
  }
}