import 'package:flutter/material.dart';
import '../controllers/telepon_controller.dart';

class TeleponPage extends StatelessWidget {
  final TeleponController _controller = TeleponController();

  TeleponPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context),
                const SizedBox(height: 20),

                // Deskripsi
                _buildDescription(),
                const SizedBox(height: 30),

                // Gambar karakter - MODIFIKASI DI SINI
                _buildCharacterImage(),
                const SizedBox(height: 30),

                // Panduan
                _buildGuidelinesCard(),
                const SizedBox(height: 40),

                // Emergency Contact
                _buildEmergencyContactsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1), // Biru transparan
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1976D2), // Biru
            ),
          ),
        ),
        const Text(
          "Telepon Darurat",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1976D2), // Biru seperti login
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      "Hubungi admin untuk bantuan darurat atau masalah mendesak",
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[600], // Abu-abu medium
      ),
    );
  }

  // MODIFIKASI: Widget untuk gambar karakter dengan border melengkung
  Widget _buildCharacterImage() {
    return Container(
      height: 150, // Tinggi bisa disesuaikan
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // Sama dengan Admin Card (20)
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Border abu-abu muda, SAMA dengan Admin Card
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05), // SAMA dengan Admin Card
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/banner_telp.png'),
          fit: BoxFit.cover, // Ubah ke cover agar gambar memenuhi container
        ),
      ),
    );
  }

  // Atau jika ingin lebih presisi seperti gambar:
  Widget _buildCharacterImagePresisi() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20), // Border radius 20
      child: Container(
        height: 140, // Tinggi disesuaikan
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Image.asset(
          'assets/banner_telp.png',
          fit: BoxFit.cover, // Gambar akan memenuhi container
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }


  Widget _buildGuidelinesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Border abu-abu muda
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.1), // Biru transparan
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: const Color(0xFF1976D2), // Biru
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Panduan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748), // Abu-abu gelap
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._controller.guidelines.map((guideline) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1), // Hijau transparan
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    guideline.icon,
                    color: const Color(0xFF10B981), // Hijau
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    guideline.text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4B5563), // Abu-abu medium
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Merah sangat muda
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!), // Border merah muda
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[100], // Merah transparan
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red[700], // Merah
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Kontak Darurat Lainnya",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626), // Merah gelap
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._controller.emergencyContacts.map((contact) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: contact.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    contact.icon,
                    color: contact.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748), // Abu-abu gelap
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.number,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600], // Abu-abu medium
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1), // Hijau transparan
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Color(0xFF10B981), // Hijau
                      size: 20,
                    ),
                  ),
                  onPressed: () => _controller.callEmergency(contact.number),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}