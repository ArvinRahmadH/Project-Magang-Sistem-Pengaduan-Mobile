import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'modules/menu/views/menu_view.dart';
import 'modules/welcome/views/welcome_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<Map<String, String?>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'name': prefs.getString('name'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIPERA - Polres Malang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF173A81),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF173A81),
          primary: const Color(0xFF173A81),
        ),
        useMaterial3: true,
      ),
      home: AnimatedSplashScreen(
        duration: 3000,
        splash: Image.asset(
          'assets/logo_intro_sipera2.png',
          width: 500,
          height: 500,
        ),
        nextScreen: FutureBuilder<Map<String, String?>>(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: const Color(0xFF173A81),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            } else {
              final userData = snapshot.data;
              if (userData != null && userData['token'] != null) {
                return MenuPage(
                  token: userData['token']!,
                  name: userData['name'] ?? 'User',
                );
              } else {
                return WelcomePage();
              }
            }
          },
        ),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: const Color(0xFF173A81), // Biru Polres
        splashIconSize: 250,
        animationDuration: const Duration(milliseconds: 800),
        // Efek tambahan untuk animasi yang lebih smooth
        curve: Curves.easeInOut,
      ),
    );
  }
}