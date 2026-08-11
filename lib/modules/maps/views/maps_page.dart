import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/maps_controller.dart';

class MapsPage extends StatefulWidget {
  final LatLng? initialLocation;

  const MapsPage({
    super.key,
    this.initialLocation,
  });

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late MapsController _controller;

  @override
  void initState() {
    super.initState();

    _controller = MapsController(
      initialCenter: widget.initialLocation,
    );
  }

  void _handleMapTap(
      TapPosition tapPosition,
      LatLng point,
      ) {
    setState(() {
      _controller.selectPoint(point);
    });
  }

  void _handleConfirmSelection() {
    final error = _controller.validateSelection();

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    } else {
      Navigator.pop(
        context,
        _controller.selectedPoint,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Lokasi"),
        actions: [
          if (_controller.hasSelectedPoint)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _controller.clearSelection();
                });
              },
              tooltip: "Hapus pilihan",
            ),
        ],
      ),

      body: FlutterMap(
        options: MapOptions(
          initialCenter: _controller.initialCenter,
          initialZoom: 13,
          onTap: _handleMapTap,
        ),

        children: [
          TileLayer(
            urlTemplate:
            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

            // Identitas aplikasi ketika meminta tile OSM
            userAgentPackageName: 'com.example.fix_malang',

            // Attribution untuk OpenStreetMap
            tileProvider: NetworkTileProvider(),
          ),

          if (_controller.hasSelectedPoint)
            MarkerLayer(
              markers: [
                Marker(
                  point: _controller.selectedPoint!,
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),

          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor:
        _controller.hasSelectedPoint
            ? Colors.green
            : Colors.grey,

        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),

        onPressed: _handleConfirmSelection,
      ),
    );
  }
}