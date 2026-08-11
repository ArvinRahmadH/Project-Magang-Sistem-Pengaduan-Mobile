import 'package:flutter/material.dart';
import '../controllers/welcome_controller.dart';

// Import halaman login dan register
import '../../../modules/login/views/login_view.dart';
import '../../../modules/register/views/register_view.dart';

class WelcomePage extends StatelessWidget {
  final WelcomeController _controller = WelcomeController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _controller.getPrimaryColor(),
      body: Stack(
        children: [
          // Bagian biru atas
          _buildTopBlueSection(),

          // Card putih melengkung
          _buildWhiteCardSection(),

          // Konten utama
          _buildMainContent(context),
        ],
      ),
    );
  }

  Widget _buildTopBlueSection() {
    return Container(
      width: double.infinity,
      height: 590,
      color: _controller.getPrimaryColor(),
    );
  }

  Widget _buildWhiteCardSection() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: 350,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final spacing = _controller.spacing;
    final buttons = _controller.buttons;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            SizedBox(height: spacing['titleTop']),

            // Judul + Deskripsi
            _buildTitleSection(),
            SizedBox(height: spacing['titleToSlogan']),

            // Slogan
            _buildSloganSection(),
            SizedBox(height: spacing['sloganToLogo']),

            // Logo - TANPA BULAT PUTIH
            _buildLogoSection(),
            SizedBox(height: spacing['logoToWelcome']),

            // Welcome Text
            _buildWelcomeTextSection(),
            SizedBox(height: spacing['welcomeToLogin']),

            // Tombol Login
            _buildLoginButton(context, buttons['login']!),
            SizedBox(height: spacing['loginToRegister']),

            // Tombol Register
            _buildRegisterButton(context, buttons['register']!),
            SizedBox(height: spacing['registerBottom']),

            // ============ COPYRIGHT ============
            _buildCopyrightSection(),
            const SizedBox(height: 16),
            // ==================================
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Text(
      _controller.getAppName(),
      style: TextStyle(
        fontFamily: 'Poppins', // atau 'Montserrat'
        fontSize: 42,          // Ukuran sedang, tidak terlalu besar
        fontWeight: FontWeight.w700, // Bold (700)
        color: Colors.white,
        letterSpacing: 3,      // Spasi antar huruf
      ),
    );
  }

  Widget _buildSloganSection() {
    return Text(
      _controller.getAppSlogan(),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Poppins', // atau 'Montserrat'
        fontSize: 14,          // Ukuran lebih kecil
        fontWeight: FontWeight.w400, // Regular (400)
        color: Colors.white.withOpacity(0.85),
        height: 1.5,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLogoSection() {
    final logoConfig = _controller.logoConfig;
    final size = logoConfig['size'] as double;

    return Image.asset(
      logoConfig['assetPath'] as String,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  Widget _buildWelcomeTextSection() {
    return Text(
      _controller.getWelcomeText(),
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: _controller.getPrimaryColor(),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, Map<String, dynamic> config) {
    return Center(
      child: SizedBox(
        width: config['width'] as double,
        height: config['height'] as double,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: _controller.colors['lightBlueAccent']!,
              width: config['borderWidth'] as double,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(config['borderRadius'] as double),
            ),
          ),
          onPressed: () => _controller.navigateToLogin(context),
          child: Text(
            config['text'] as String,
            style: TextStyle(
              fontSize: config['fontSize'] as double,
              fontWeight: FontWeight.bold,
              color: _controller.colors['lightBlue'],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context, Map<String, dynamic> config) {
    return Center(
      child: SizedBox(
        width: config['width'] as double,
        height: config['height'] as double,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _controller.getPrimaryColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(config['borderRadius'] as double),
            ),
            elevation: config['elevation'] as double,
          ),
          onPressed: () => _controller.navigateToRegister(context),
          child: Text(
            config['text'] as String,
            style: TextStyle(
              fontSize: config['fontSize'] as double,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ============ FUNGSI COPYRIGHT ============
  Widget _buildCopyrightSection() {
    return Column(
      children: [
        const Divider(
          color: Color(0xFFE2E8F0),
          thickness: 1,
          height: 1,
        ),
        const SizedBox(height: 12),
        Text(
          '© ${DateTime.now().year} Polres Malang. All Rights Reserved.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'SIPERA - Sistem Pelaporan Polres Malang',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[400],
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
// ==========================================
}