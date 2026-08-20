import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../pengaduan/views/pengaduan_page.dart';
import '../../profil/views/profil_page.dart';
import '../../riwayat/views/riwayat_page.dart';
import '../../telepon/views/telepon_page.dart';

class MenuPage extends StatefulWidget {
  final String token;
  final String name;

  const MenuPage({
    super.key,
    required this.token,
    required this.name,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _isDarkMode = false;
  List _notes = [];
  List _news = [];
  bool _isLoading = true;
  bool _isLoadingNews = true;
  String? _userProfileImage;
  bool _isLoadingProfile = false;
  int _currentNewsPage = 0;
  int _totalSelesai = 0;
  int _totalDiproses = 0;
  int _totalMenunggu = 0;
  int _totalSemua = 0;
  int _selectedIndex = 0;

  // Warna Light Mode - Abu-abu Elegan
  final Map<String, Color> _lightColors = {
    'background': const Color(0xFFF7FAFC),
    'primary': const Color(0xFF4A5568),
    'primaryLight': const Color(0xFF718096),
    'primaryDark': const Color(0xFF2D3748),
    'secondary': const Color(0xFF2D3748),
    'textPrimary': const Color(0xFF1A202C),
    'textSecondary': const Color(0xFF4A5568),
    'textTertiary': const Color(0xFF718096),
    'cardBackground': Colors.white,
    'border': const Color(0xFFE2E8F0),
    'success': const Color(0xFF48BB78),
    'warning': const Color(0xFFED8936),
    'info': const Color(0xFF4A5568),
    'error': const Color(0xFFFC8181),
    'surface': Colors.white,
    'onSurface': const Color(0xFF2D3748),
  };

  // Warna Dark Mode - Abu-abu Gelap Elegan
  final Map<String, Color> _darkColors = {
    'background': const Color(0xFF0D1117),
    'primary': const Color(0xFFA0AEC0),
    'primaryLight': const Color(0xFFCBD5E0),
    'primaryDark': const Color(0xFF718096),
    'secondary': const Color(0xFF718096),
    'textPrimary': Colors.white,
    'textSecondary': const Color(0xFFCBD5E1),
    'textTertiary': const Color(0xFF94A3B8),
    'cardBackground': const Color(0xFF1A202C),
    'border': const Color(0xFF2D3748),
    'success': const Color(0xFF48BB78),
    'warning': const Color(0xFFED8936),
    'info': const Color(0xFFA0AEC0),
    'error': const Color(0xFFFC8181),
    'surface': const Color(0xFF1A202C),
    'onSurface': Colors.white,
  };

  Map<String, Color> get colors => _isDarkMode ? _darkColors : _lightColors;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
    _fetchNews();
    _fetchUserProfile();
  }

  Future<void> _fetchNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse("h..."),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        int selesai = 0, diproses = 0, menunggu = 0;

        for (var note in data) {
          switch (note['status']) {
            case 'selesai':
              selesai++;
              break;
            case 'diproses':
              diproses++;
              break;
            case 'menunggu':
              menunggu++;
              break;
          }
        }

        setState(() {
          _notes = data;
          _totalSemua = data.length;
          _totalSelesai = selesai;
          _totalDiproses = diproses;
          _totalMenunggu = menunggu;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse("h..."),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _news = data;
          _isLoadingNews = false;
        });
      } else {
        setState(() => _isLoadingNews = false);
      }
    } catch (e) {
      setState(() => _isLoadingNews = false);
    }
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() => _isLoadingProfile = false);
        return;
      }

      final response = await http.get(
        Uri.parse("h..."),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? profilePhoto;

        if (data['profile_photo'] != null && data['profile_photo'].toString().isNotEmpty) {
          profilePhoto = data['profile_photo'];
        } else if (data['photo'] != null && data['photo'].toString().isNotEmpty) {
          profilePhoto = data['photo'];
        } else if (data['avatar'] != null && data['avatar'].toString().isNotEmpty) {
          profilePhoto = data['avatar'];
        } else if (data['image'] != null && data['image'].toString().isNotEmpty) {
          profilePhoto = data['image'];
        }

        setState(() {
          _userProfileImage = profilePhoto;
          _isLoadingProfile = false;
        });
      } else {
        setState(() => _isLoadingProfile = false);
      }
    } catch (e) {
      setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _isLoadingNews = true;
      _isLoadingProfile = true;
    });
    await _fetchNotes();
    await _fetchNews();
    await _fetchUserProfile();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors['background'],
      body: SafeArea(
        bottom: false,
        child: _getCurrentPage(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors['cardBackground'],
          border: Border(
            top: BorderSide(color: colors['border']!, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: colors['primary'],
            unselectedItemColor: colors['textTertiary'],
            selectedLabelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors['primary'],
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors['textTertiary'],
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history_rounded),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const RiwayatPage();
      case 2:
        return ProfilPage(token: widget.token);
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return _HomeContent(
      name: widget.name,
      profileImage: _userProfileImage,
      isDarkMode: _isDarkMode,
      isLoading: _isLoading,
      isLoadingNews: _isLoadingNews,
      isLoadingProfile: _isLoadingProfile,
      totalSemua: _totalSemua,
      totalMenunggu: _totalMenunggu,
      totalDiproses: _totalDiproses,
      totalSelesai: _totalSelesai,
      news: _news,
      currentNewsPage: _currentNewsPage,
      onNewsPageChanged: (index) {
        setState(() => _currentNewsPage = index);
      },
      colors: colors,
      onToggleTheme: () {
        setState(() => _isDarkMode = !_isDarkMode);
      },
      onRefresh: _refreshData,
      token: widget.token,
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilPage(token: widget.token),
          ),
        );
      },
    );
  }
}

// ==================== HOME CONTENT ====================
class _HomeContent extends StatelessWidget {
  final String name;
  final String? profileImage;
  final bool isDarkMode;
  final bool isLoading;
  final bool isLoadingNews;
  final bool isLoadingProfile;
  final int totalSemua;
  final int totalMenunggu;
  final int totalDiproses;
  final int totalSelesai;
  final List news;
  final int currentNewsPage;
  final ValueChanged<int> onNewsPageChanged;
  final Map<String, Color> colors;
  final VoidCallback onToggleTheme;
  final Future<void> Function() onRefresh;
  final String token;
  final VoidCallback onProfileTap;

  const _HomeContent({
    required this.name,
    this.profileImage,
    required this.isDarkMode,
    required this.isLoading,
    required this.isLoadingNews,
    required this.isLoadingProfile,
    required this.totalSemua,
    required this.totalMenunggu,
    required this.totalDiproses,
    required this.totalSelesai,
    required this.news,
    required this.currentNewsPage,
    required this.onNewsPageChanged,
    required this.colors,
    required this.onToggleTheme,
    required this.onRefresh,
    required this.token,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: colors['primary'],
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== HEADER ====================
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              color: colors['background'],
              child: Row(
                children: [
                  // Foto Profil
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors['primary']!.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors['primary']!.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(child: _buildProfileImage()),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Teks Sambutan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selamat Datang,",
                          style: TextStyle(
                            fontSize: 13,
                            color: colors['textSecondary'],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            color: colors['textPrimary'],
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Tombol Theme & Refresh
                  Row(
                    children: [
                      _buildIconButton(
                        icon: isDarkMode
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        onTap: onToggleTheme,
                        color: colors['primary']!,
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        icon: isLoading ? Icons.refresh : Icons.refresh_outlined,
                        onTap: () => onRefresh(),
                        color: colors['primary']!,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ==================== DASHBOARD CARD ====================
            Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF173A81), Color(0xFF223B65)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF182E53).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Statistik pengaduan Anda",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    color: Colors.white.withOpacity(0.2),
                    thickness: 1,
                  ),
                  const SizedBox(height: 16),

                  // Statistik Cards
                  isLoading
                      ? _buildStatSkeleton()
                      : Row(
                    children: [
                      _buildStatItem(
                        value: totalSemua.toString(),
                        label: "Total",
                        icon: Icons.list_alt_outlined,
                      ),
                      const SizedBox(width: 8),
                      _buildStatItem(
                        value: totalMenunggu.toString(),
                        label: "Tunggu",
                        icon: Icons.schedule_outlined,
                      ),
                      const SizedBox(width: 8),
                      _buildStatItem(
                        value: totalDiproses.toString(),
                        label: "Proses",
                        icon: Icons.timelapse_outlined,
                      ),
                      const SizedBox(width: 8),
                      _buildStatItem(
                        value: totalSelesai.toString(),
                        label: "Selesai",
                        icon: Icons.check_circle_outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==================== LAYANAN CEPAT ====================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Layanan Cepat",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors['textPrimary'],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Akses layanan penting dengan satu klik",
                    style: TextStyle(
                      fontSize: 13,
                      color: colors['textSecondary'],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Menu Grid - 2 Kolom
                  Row(
                    children: [
                      Expanded(
                        child: _buildMenuCard(
                          icon: Icons.edit_note_rounded,
                          title: "Buat Pengaduan",
                          subtitle: "Lapor masalah",
                          color1: const Color(0xFF173A81),
                          color2: const Color(0xFF223B65),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PengaduanPage(token: token),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildMenuCard(
                          icon: Icons.phone_in_talk_rounded,
                          title: "Telepon Darurat",
                          subtitle: "Hubungi admin",
                          color1: const Color(0xFF1E5C1F),
                          color2: const Color(0xFF295126),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeleponPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==================== BERITA TERKINI ====================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Berita Terkini",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: colors['textPrimary'],
                        ),
                      ),
                      if (news.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => _AllNewsPage(
                                  news: news,
                                  colors: colors,
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "Lihat Semua",
                            style: TextStyle(
                              fontSize: 13,
                              color: colors['primary'],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Informasi terbaru seputar infrastruktur",
                    style: TextStyle(
                      fontSize: 13,
                      color: colors['textSecondary'],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // News Section
                  if (isLoadingNews)
                    _buildNewsSkeleton()
                  else if (news.isEmpty)
                    _buildEmptyNews()
                  else
                    _buildNewsCarousel(),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==================== INFO APLIKASI ====================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors['primary']!.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors['primary']!.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colors['primary'],
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Gunakan aplikasi untuk melaporkan masalah infrastruktur dengan cepat",
                        style: TextStyle(
                          fontSize: 12,
                          color: colors['textSecondary'],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==================== BUILD METHODS ====================

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (isLoadingProfile) {
      return Container(
        color: colors['primary']!.withOpacity(0.1),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors['primary'],
          ),
        ),
      );
    }

    if (profileImage != null && profileImage!.isNotEmpty) {
      String imageUrl;
      if (profileImage!.startsWith('http')) {
        imageUrl = profileImage!;
      } else if (profileImage!.startsWith('storage/')) {
        imageUrl = "http:/${profileImage!}";
      } else if (profileImage!.startsWith('/')) {
        imageUrl = "http:$profileImage";
      } else {
        imageUrl = "http:/$profileImage";
      }

      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: colors['primary']!.withOpacity(0.1),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors['primary'],
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildDefaultProfileIcon(),
      );
    }

    return _buildDefaultProfileIcon();
  }

  Widget _buildDefaultProfileIcon() {
    return Container(
      color: colors['primary']!.withOpacity(0.1),
      child: Center(
        child: Icon(Icons.person, color: colors['primary'], size: 28),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSkeleton() {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 25,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 35,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color1.withOpacity(0.25),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCarousel() {
    final height = 200.0;

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            onPageChanged: onNewsPageChanged,
            itemCount: news.length,
            itemBuilder: (context, index) {
              final item = news[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: colors['cardBackground'],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors['border']!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      child: item['image_path'] != null
                          ? CachedNetworkImage(
                        imageUrl:
                        "http:/${item['image_path']}",
                        height: height * 0.55,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: height * 0.55,
                          color: colors['border'],
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: height * 0.55,
                          color: colors['border'],
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: colors['textTertiary'],
                              size: 32,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: height * 0.55,
                        color: colors['primary']!.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.article_outlined,
                            color: colors['primary'],
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    // Judul
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? "Tanpa Judul",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors['textPrimary'],
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                "Baca selengkapnya",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors['primary'],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: colors['primary'],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (news.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              news.length,
                  (index) => Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentNewsPage == index
                      ? colors['primary']
                      : colors['border'],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNewsSkeleton() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colors['cardBackground'],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors['border']!, width: 1),
      ),
      child: Column(
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: colors['border'],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors['border'],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors['border'],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNews() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: colors['cardBackground'],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors['border']!, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.article_outlined, size: 40, color: colors['textTertiary']),
          const SizedBox(height: 8),
          Text(
            "Belum ada berita",
            style: TextStyle(
              fontSize: 14,
              color: colors['textSecondary'],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    final total = totalSemua > 0 ? totalSemua : 1;

    return Column(
      children: [
        _buildProgressBar(
          label: "Selesai",
          value: totalSelesai,
          total: total,
          color: colors['success']!,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 12),
        _buildProgressBar(
          label: "Diproses",
          value: totalDiproses,
          total: total,
          color: colors['warning']!,
          icon: Icons.timelapse_outlined,
        ),
        const SizedBox(height: 12),
        _buildProgressBar(
          label: "Menunggu",
          value: totalMenunggu,
          total: total,
          color: colors['textTertiary']!,
          icon: Icons.schedule_outlined,
        ),
        if (totalSemua > 0) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              "Total $totalSemua pengaduan",
              style: TextStyle(
                fontSize: 12,
                color: colors['textSecondary'],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int value,
    required int total,
    required Color color,
    required IconData icon,
  }) {
    final percentage = (value / total) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors['textPrimary'],
                  ),
                ),
              ],
            ),
            Text(
              "$value ($percentage.toStringAsFixed(1)%)",
              style: TextStyle(
                fontSize: 12,
                color: colors['textSecondary'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: colors['border']!,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== ALL NEWS PAGE ====================
class _AllNewsPage extends StatefulWidget {
  final List news;
  final Map<String, Color> colors;
  final bool isDarkMode;

  const _AllNewsPage({
    required this.news,
    required this.colors,
    required this.isDarkMode,
  });

  @override
  State<_AllNewsPage> createState() => _AllNewsPageState();
}

class _AllNewsPageState extends State<_AllNewsPage> {
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      backgroundColor: widget.colors['background'],
      appBar: AppBar(
        backgroundColor: widget.colors['cardBackground'],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: widget.colors['textPrimary']),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Semua Berita",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: widget.colors['textPrimary'],
          ),
        ),
        centerTitle: true,
      ),
      body: widget.news.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 50, color: widget.colors['textTertiary']),
            const SizedBox(height: 12),
            Text(
              "Belum ada berita",
              style: TextStyle(
                fontSize: 16,
                color: widget.colors['textSecondary'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.news.length,
        itemBuilder: (context, index) {
          final item = widget.news[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: widget.colors['cardBackground'],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.colors['border']!, width: 1),
              boxShadow: widget.isDarkMode
                  ? []
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item['image_path'] != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: CachedNetworkImage(
                      imageUrl:
                      "http:/${item['image_path']}",
                      height: isSmallScreen ? 150 : 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: isSmallScreen ? 150 : 180,
                        color: widget.colors['border'],
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: isSmallScreen ? 150 : 180,
                        color: widget.colors['border'],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: widget.colors['textTertiary'],
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? "Tanpa Judul",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 15 : 17,
                          fontWeight: FontWeight.w700,
                          color: widget.colors['textPrimary'],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _openNewsLink(item['link']),
                        child: Row(
                          children: [
                            Text(
                              "Baca selengkapnya",
                              style: TextStyle(
                                fontSize: 13,
                                color: widget.colors['primary'],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: widget.colors['primary'],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openNewsLink(String? link) async {
    if (link == null || link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Link tidak tersedia"),
          backgroundColor: widget.colors['error'],
        ),
      );
      return;
    }

    String formattedLink = link;
    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      formattedLink = 'https://$link';
    }

    try {
      if (await canLaunchUrl(Uri.parse(formattedLink))) {
        await launchUrl(
          Uri.parse(formattedLink),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal membuka link"),
          backgroundColor: widget.colors['error'],
        ),
      );
    }
  }
}