import 'package:latlong2/latlong.dart';

class MapsController {
  LatLng? _selectedPoint;
  LatLng? _initialCenter;

  MapsController({LatLng? initialCenter})
      : _initialCenter = initialCenter ?? const LatLng(-7.982298, 112.630539);

  // Getters
  LatLng? get selectedPoint => _selectedPoint;
  LatLng get initialCenter => _initialCenter!;

  // Actions
  void selectPoint(LatLng point) {
    _selectedPoint = point;
  }

  void clearSelection() {
    _selectedPoint = null;
  }

  bool get hasSelectedPoint => _selectedPoint != null;

  // Validation
  String? validateSelection() {
    if (_selectedPoint == null) {
      return "Klik pada peta untuk pilih lokasi";
    }
    return null;
  }
}