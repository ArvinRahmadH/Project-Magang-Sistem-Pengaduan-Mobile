import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RiwayatController {
  // State
  List<dynamic> notes = [];
  List<dynamic> messages = [];
  bool isLoadingMessages = false;
  bool isLoading = true;
  int selectedFilter = 0; // 0: Semua, 1: Menunggu, 2: Diproses, 3: Selesai

  // Constants
  final List<String> filterOptions = ['Semua', 'Menunggu', 'Diproses', 'Selesai'];

  // API Configuration
  final String baseUrl = 'http:';
  BuildContext? _context;

  // Initialize context
  void setContext(BuildContext context) {
    _context = context;
  }

  // API Methods
  Future<void> fetchNotes() async {
    if (_context == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showSnackBar("Token tidak ditemukan, login ulang", Colors.red);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/notes"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        notes = jsonDecode(response.body);
        isLoading = false;
        _notifyListeners();
      } else {
        isLoading = false;
        _notifyListeners();
        _showSnackBar("Gagal ambil riwayat: ${response.statusCode}", Colors.orange);
      }
    } catch (e) {
      isLoading = false;
      _notifyListeners();
      _showSnackBar("Error: $e", Colors.red);
    }
  }

  Future<void> deleteNote(int id) async {
    if (_context == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/notes/$id"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar("✅ Catatan berhasil dihapus", Colors.green);
        await fetchNotes(); // refresh list
      } else {
        _showSnackBar("❌ Gagal hapus: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      _showSnackBar("❌ Error: $e", Colors.red);
    }
  }

  Future<void> fetchMessages(int noteId) async {
    isLoadingMessages = true;
    _notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse("$baseUrl/notes/$noteId/messages"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      messages = jsonDecode(response.body);
    } else {
      messages = [];
    }

    isLoadingMessages = false;
    _notifyListeners();
  }


  // Filter Methods
  void setFilter(int index) {
    selectedFilter = index;
    _notifyListeners();
  }

  List<dynamic> get filteredNotes {
    if (selectedFilter == 0) return notes;

    String statusFilter = '';
    switch (selectedFilter) {
      case 1:
        statusFilter = 'menunggu';
        break;
      case 2:
        statusFilter = 'diproses';
        break;
      case 3:
        statusFilter = 'selesai';
        break;
    }

    return notes.where((note) => note['status'] == statusFilter).toList();
  }

  // Statistics Methods
  int get totalNotes => notes.length;

  int get waitingNotes => notes.where((note) => note['status'] == 'menunggu').length;

  int get processingNotes => notes.where((note) => note['status'] == 'diproses').length;

  int get completedNotes => notes.where((note) => note['status'] == 'selesai').length;

  List<StatisticItem> get statistics {
    return [
      StatisticItem(
        count: totalNotes,
        label: 'Total',
        color: const Color(0xFF4361EE),
      ),
      StatisticItem(
        count: waitingNotes,
        label: 'Menunggu',
        color: const Color(0xFF6B7280),
      ),
      StatisticItem(
        count: processingNotes,
        label: 'Diproses',
        color: const Color(0xFFF59E0B),
      ),
      StatisticItem(
        count: completedNotes,
        label: 'Selesai',
        color: const Color(0xFF10B981),
      ),
    ];
  }

  // UI Helper Methods
  Color getStatusColor(String status) {
    switch (status) {
      case "selesai":
        return const Color(0xFF10B981);
      case "diproses":
        return const Color(0xFFF59E0B);
      case "menunggu":
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case "selesai":
        return const Color(0xFFD1FAE5);
      case "diproses":
        return const Color(0xFFFEF3C7);
      case "menunggu":
        return const Color(0xFFF3F4F6);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case "selesai":
        return Icons.check_circle_outline;
      case "diproses":
        return Icons.timelapse_outlined;
      case "menunggu":
        return Icons.schedule_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy • HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String getNoteTitle(dynamic note) {
    return note['title'] ?? 'Tanpa Judul';
  }

  String getNoteContent(dynamic note) {
    return note['content'] ?? 'Tidak ada deskripsi';
  }

  String? getNoteCategory(dynamic note) {
    return note['kategori'];
  }

  String getNoteDate(dynamic note) {
    return formatDate(note['created_at'] ?? note['updated_at'] ?? '');
  }

  // Dialog Methods
  Future<bool> confirmDeleteNote(BuildContext context, dynamic note) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Hapus Catatan",
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          "Apakah kamu yakin ingin menghapus catatan ini?",
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Batal",
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Hapus",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void showNoteDetail(BuildContext context, dynamic note) {

    fetchMessages(note['id']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return NoteDetailBottomSheet(
          note: note,
          controller: this,
        );
      },
    );
  }

  // Helper Methods
  void _showSnackBar(String message, Color color) {
    if (_context != null && _context!.mounted) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
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
    _listeners.clear();
  }
}

// Data Models
class StatisticItem {
  final int count;
  final String label;
  final Color color;

  StatisticItem({
    required this.count,
    required this.label,
    required this.color,
  });
}

// Bottom Sheet Widget (bisa dipindah ke file terpisah jika besar)
class NoteDetailBottomSheet extends StatefulWidget {
  final dynamic note;
  final RiwayatController controller;

  const NoteDetailBottomSheet({
    super.key,
    required this.note,
    required this.controller,
  });

  @override
  State<NoteDetailBottomSheet> createState() =>
      _NoteDetailBottomSheetState();
}

class _NoteDetailBottomSheetState extends State<NoteDetailBottomSheet> {

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final controller = widget.controller;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            // ===== HANDLE =====
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== STATUS =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: controller.getStatusBgColor(note['status']),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.getStatusIcon(note['status']),
                    size: 16,
                    color: controller.getStatusColor(note['status']),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    note['status'].toString().toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: controller.getStatusColor(note['status']),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== JUDUL =====
            Text(
              controller.getNoteTitle(note),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            // ===== TANGGAL =====
            Text(
              controller.getNoteDate(note),
              style: const TextStyle(color: Color(0xFF9CA3AF)),
            ),

            const SizedBox(height: 20),

            // ===== DESKRIPSI =====
            const Text(
              "Deskripsi:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              controller.getNoteContent(note),
              style: const TextStyle(height: 1.5),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // ================= PESAN DARI ADMIN =================
            // =====================================================

            const Text(
              "Pesan dari Admin",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            if (controller.isLoadingMessages)
              const Center(child: CircularProgressIndicator()),

            if (!controller.isLoadingMessages &&
                controller.messages.isEmpty)
              const Text(
                "Belum ada pesan dari admin",
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),

            ...controller.messages.map((msg) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Admin",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4361EE),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(msg['message']),
                  const SizedBox(height: 6),
                  Text(
                    controller.formatDate(msg['created_at']),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 24),

            // ===== BUTTON =====
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tutup"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}