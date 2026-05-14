import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../utils/receiver_coordinates.dart';
import 'receiver_summary_popup.dart';

/// Mapa OSM con puntos rojos por receptor (usa [parseReceiverLatLng]).
class ReceiversMapView extends StatefulWidget {
  final List<Map<String, dynamic>> receivers;

  const ReceiversMapView({super.key, required this.receivers});

  @override
  State<ReceiversMapView> createState() => _ReceiversMapViewState();
}

class _ReceiversMapViewState extends State<ReceiversMapView> {
  final MapController _mapController = MapController();

  static const LatLng _defaultCenter = LatLng(40.4168, -3.7038);
  static const double _minZoom = 3;
  static const double _maxZoom = 18;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitToMarkers(receiverPointsWithCoords(widget.receivers));
    });
  }

  void _fitToMarkers(List<LatLng> points) {
    if (!mounted || points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 14);
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
  }

  void _zoomBy(double delta) {
    if (!mounted) return;
    final cam = _mapController.camera;
    final z = (cam.zoom + delta).clamp(_minZoom, _maxZoom);
    if (z != cam.zoom) {
      _mapController.move(cam.center, z);
    }
  }

  @override
  void didUpdateWidget(covariant ReceiversMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.receivers != widget.receivers) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final pts = receiverPointsWithCoords(widget.receivers);
        _fitToMarkers(pts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = receiverPointsWithCoords(widget.receivers);
    final markers = <Marker>[];
    for (final r in widget.receivers) {
      final p = parseReceiverLatLng(r);
      if (p == null) continue;
      final name = r['name']?.toString().trim();
      markers.add(
        Marker(
          point: p,
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => showReceiverEssentialPopup(context, r),
            child: Tooltip(
              message: (name != null && name.isNotEmpty) ? name : 'Receptor',
              child: Center(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.receivers.isEmpty) {
      return const Center(
        child: Text('No hay receptores para mostrar en el mapa.'),
      );
    }

    if (markers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Ningún receptor tiene latitud y longitud válidas '
            '(usa los campos latitud/longitud o coordenadas en ubicación).',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade800),
          ),
        ),
      );
    }

    final center = points.isNotEmpty
        ? LatLng(
            points.map((e) => e.latitude).reduce((a, b) => a + b) /
                points.length,
            points.map((e) => e.longitude).reduce((a, b) => a + b) /
                points.length,
          )
        : _defaultCenter;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: points.length == 1 ? 14 : 10,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
                // Rueda del ratón / trackpad más notoria (por defecto es muy lenta)
                scrollWheelVelocity: 0.04,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'savia_lightweight',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Acercar',
                    icon: const Icon(Icons.add, color: Colors.black87),
                    onPressed: () => _zoomBy(1),
                  ),
                  const Divider(height: 1),
                  IconButton(
                    tooltip: 'Alejar',
                    icon: const Icon(Icons.remove, color: Colors.black87),
                    onPressed: () => _zoomBy(-1),
                  ),
                  const Divider(height: 1),
                  IconButton(
                    tooltip: 'Ver todos los puntos',
                    icon: const Icon(Icons.fit_screen, color: Colors.black87),
                    onPressed: () => _fitToMarkers(
                      receiverPointsWithCoords(widget.receivers),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
