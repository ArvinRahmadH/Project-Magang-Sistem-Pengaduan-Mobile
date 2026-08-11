import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilController {
  final String token;
  BuildContext? _context;
  final VoidCallback? onLogoutSuccess; // TAMBAHKAN CALLBACK

  ProfilController(this.token, {this.onLogoutSuccess});

  // User Data
  String? name;
  String? email;
  String? profilePhoto;

  // UI State
  bool isLoading = true;
  bool isDarkMode = false;

  // Theme Colors
  final Map<String, Color> _lightColors = {
    'background': const Color(0xFFF8FAFD),
    'primary': const Color(0xFF4361EE),
    'primaryDark': const Color(0xFF3A0CA3),
    'textPrimary': const Color(0xFF2D3748),
    'textSecondary': const Color(0xFF718096),
    'cardBackground': Colors.white,
    'border': const Color(0xFFE2E8F0),
    'success': const Color(0xFF10B981),
    'warning': const Color(0xFFF59E0B),
    'error': const Color(0xFFEF4444),
  };

  final Map<String, Color> _darkColors = {
    'background': const Color(0xFF0A0E17),
    'primary': const Color(0xFF667EEA),
    'primaryDark': const Color(0xFF764BA2),
    'textPrimary': Colors.white,
    'textSecondary': const Color(0xFF94A3B8),
    'cardBackground': const Color(0xFF1E293B),
    'border': const Color(0xFF334155),
    'success': const Color(0xFF34D399),
    'warning': const Color(0xFFFBBF24),
    'error': const Color(0xFFF87171),
  };

  Map<String, Color> get colors => isDarkMode ? _darkColors : _lightColors;

  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();


  // Initialize context
  void setContext(BuildContext context) {
    _context = context;
  }

  // API Methods
  Future<void> fetchProfile() async {
    try {
      final response = await _dio.get(
        'http:',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200) {
        name = response.data['name'];
        email = response.data['email'];
        profilePhoto = response.data['profile_photo'];
        isLoading = false;
        _notifyListeners();
      }
    } catch (e) {
      print('Error get profile: $e');
      isLoading = false;
      _notifyListeners();
    }
  }
  Future<void> uploadPhoto() async {
    if (_context == null) return;

    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          pickedFile.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        'http:',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Foto profil berhasil diperbarui!', colors['success']!);
        await fetchProfile();
      }
    } catch (e) {
      print('Error upload photo: $e');
      _showSnackBar('Gagal mengupload foto', colors['error']!);
    }
  }

  // Theme Methods
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    _notifyListeners();
  }

  String get themeModeText => isDarkMode ? 'Dark Mode' : 'Light Mode';

  // Logout Methods
  Future<bool> confirmLogout() async {
    if (_context == null) return false;

    final result = await showDialog<bool>(
      context: _context!,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(color: colors['textSecondary']),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors['error'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> performLogout() async {
    if (_context == null) return;

    try {
      // Show loading
      showDialog(
        context: _context!,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Close loading
      Navigator.pop(_context!);

      // Show success message
      _showSnackBar('Logout berhasil!', colors['success']!);

      // Tunggu sebentar untuk snackbar terlihat
      await Future.delayed(const Duration(milliseconds: 800));

      // Panggil callback jika ada
      if (onLogoutSuccess != null) {
        onLogoutSuccess!();
      }

    } catch (e) {
      print('Error saat logout: $e');
      if (_context != null && _context!.mounted) {
        Navigator.pop(_context!); // Close loading if error
        _showSnackBar('Error: $e', colors['error']!);
      }
    }
  }

  // Helper Methods
  String? getProfileImageUrl() {
    return profilePhoto;
  }

  String getUserName() {
    return name ?? 'Tidak Ada Nama';
  }

  String getUserEmail() {
    return email ?? 'tidakada@email.com';
  }

  String getJoinDate() {
    return '01 Jan 2024'; // Static for now, bisa diambil dari API
  }

  void _showSnackBar(String message, Color color) {
    if (_context != null && _context!.mounted) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // Profile Detail Items Data
  List<ProfileDetailItem> getProfileDetailItems() {
    return [
      ProfileDetailItem(
        icon: Icons.person,
        title: 'Nama Lengkap',
        value: getUserName(),
      ),
      ProfileDetailItem(
        icon: Icons.email,
        title: 'Email',
        value: getUserEmail(),
      ),
      ProfileDetailItem(
        icon: Icons.calendar_today,
        title: 'Bergabung sejak',
        value: getJoinDate(),
      ),
    ];
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
    _listeners.clear();
  }
}

// Data Models for UI
class SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool hasSwitch;

  SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.hasSwitch = false,
  });
}

class ProfileDetailItem {
  final IconData icon;
  final String title;
  final String value;

  ProfileDetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });
}