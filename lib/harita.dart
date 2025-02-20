import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HaritaEkrani extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<HaritaEkrani> {
  LatLng? selectedLocation;

  void _onTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      selectedLocation = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Konum Seç")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(37.7648, 30.5566), // Isparta, Türkiye
          initialZoom: 13.0,
          onTap: _onTap,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all &
                ~InteractiveFlag.rotate, // Dönmeyi engelle
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          if (selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: selectedLocation!,
                  width: 40.0,
                  height: 40.0,
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        focusColor: Colors.white,
        foregroundColor: Colors.white,
        onPressed: () {
          if (selectedLocation != null) {
            Navigator.pop(context, selectedLocation);
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
