import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TeleponController {
  // Contact Data
  final String adminPhone = "+628972114998"; // Ganti dengan nomor admin

  // Emergency Contacts
  final List<EmergencyContact> emergencyContacts = [
    EmergencyContact(
      name: "Polisi",
      number: "110",
      icon: Icons.local_police,
      color: Colors.blue,
    ),
    EmergencyContact(
      name: "Pemadam Kebakaran",
      number: "113",
      icon: Icons.local_fire_department,
      color: Colors.red,
    ),
    EmergencyContact(
      name: "Ambulans",
      number: "118/119",
      icon: Icons.local_hospital,
      color: Colors.green,
    ),
  ];

  // Operating Hours
  final List<OperatingHour> operatingHours = [
    OperatingHour(
      day: "Senin - Jumat",
      hours: "08:00 - 17:00 WIB",
    ),
    OperatingHour(
      day: "Sabtu - Minggu",
      hours: "08:00 - 12:00 WIB",
    ),
  ];

  // Guidelines
  final List<Guideline> guidelines = [
    Guideline(
      text: "Siapkan laporan jika ada",
      icon: Icons.check_circle,
    ),
    Guideline(
      text: "Sebutkan lokasi masalah dengan jelas",
      icon: Icons.check_circle,
    ),
    Guideline(
      text: "Foto bukti untuk mempercepat proses",
      icon: Icons.check_circle,
    ),
  ];

  // Phone Call Methods
  Future<void> callNumber(String number) async {
    final url = 'tel:$number';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> callAdmin() async {
    await callNumber(adminPhone);
  }

  Future<void> whatsappAdmin() async {
    final url = 'https://wa.me/$adminPhone?text=Halo%20Admin,%20saya%20butuh%20bantuan';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> callEmergency(String number) async {
    await callNumber(number);
  }

  // Helper Methods
  String getAdminPhoneFormatted() {
    // Format nomor untuk display
    if (adminPhone.length >= 10) {
      return "${adminPhone.substring(0, 4)} ${adminPhone.substring(4, 7)} ${adminPhone.substring(7)}";
    }
    return adminPhone;
  }
}

// Data Models
class EmergencyContact {
  final String name;
  final String number;
  final IconData icon;
  final Color color;

  EmergencyContact({
    required this.name,
    required this.number,
    required this.icon,
    required this.color,
  });
}

class OperatingHour {
  final String day;
  final String hours;
  final bool isClosed;

  OperatingHour({
    required this.day,
    required this.hours,
    this.isClosed = false,
  });
}

class Guideline {
  final String text;
  final IconData icon;

  Guideline({
    required this.text,
    required this.icon,
  });
}