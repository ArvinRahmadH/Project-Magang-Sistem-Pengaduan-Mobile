import 'package:flutter/material.dart';

import '../../login/views/login_view.dart';
import '../../register/views/register_view.dart';

class WelcomeController {
  // Navigation Methods
  void navigateToLogin(BuildContext context) {
    _navigateWithSlideTransition(
      context,
      const LoginPage(),
    );
  }

  void navigateToRegister(BuildContext context) {
    _navigateWithSlideTransition(
      context,
      const RegisterPage(),
    );
  }

  // Custom slide transition navigation
  void _navigateWithSlideTransition(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // App Information
  Map<String, String> get appInfo {
    return {
      'name': 'SIPERA',
      'slogan': 'Aplikasi Pengaduan Berbasis Digital untuk Pelayanan Masyarakat Polres Malang',
      'welcomeText': 'Welcome',
    };
  }

  // UI Configuration
  Map<String, Color> get colors {
    return {
      'primary': const Color(0xFF173A81),
      'white': Colors.white,
      'white70': Colors.white70,
      'lightBlue': const Color(0xFF3B6CB0),
      'lightBlueAccent': const Color(0xFF5A8BC7),
    };
  }

  // Button Configuration
  Map<String, Map<String, dynamic>> get buttons {
    return {
      'login': {
        'width': 300.0,
        'height': 56.0,
        'borderRadius': 30.0,
        'borderWidth': 2.5,
        'text': 'Login',
        'fontSize': 18.0,
      },
      'register': {
        'width': 300.0,
        'height': 56.0,
        'borderRadius': 30.0,
        'elevation': 6.0,
        'text': 'Register',
        'fontSize': 18.0,
      },
    };
  }

  // Layout Configuration
  Map<String, double> get spacing {
    return {
      'titleTop': 40.0,
      'titleToSlogan': 12.0,
      'sloganToLogo': 60.0,
      'logoToWelcome': 110.0,
      'welcomeToLogin': 30.0,
      'loginToRegister': 35.0,
      'registerBottom': 40.0,
    };
  }

  // Logo Configuration
  Map<String, dynamic> get logoConfig {
    return {
      'size': 180.0, // Ukuran lebih besar
      'assetPath': 'assets/Logo_Polres_Malang-favicon.png',
    };
  }

  // Helper Methods
  String getAppName() {
    return appInfo['name']!;
  }

  String getAppSlogan() {
    return appInfo['slogan']!;
  }

  String getWelcomeText() {
    return appInfo['welcomeText']!;
  }

  Color getPrimaryColor() {
    return colors['primary']!;
  }
}