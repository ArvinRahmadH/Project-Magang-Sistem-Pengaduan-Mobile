import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../menu/views/menu_view.dart';



class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  // Fungsi login
  Future<void> login(BuildContext context, Function setLoading) async {
    setLoading(true);

    final response = await http.post(
      Uri.parse("h..."),
      headers: {"Accept": "application/json"},
      body: {
        "email": emailController.text,
        "password": passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final name = data['user']['name'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('name', name);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenuPage(token: token, name: name)),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Berhasil")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login gagal: ${response.body}")),
      );
    }

    setLoading(false);
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
