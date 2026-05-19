import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/savia_colors.dart';
import '../utils/receiver_coordinates.dart';
import 'receiver_summary_popup.dart';

/// Mapa oscuro con marcadores naranja por receptor (usa [parseReceiverLatLng]).
class ReceiversMapView extends StatefulWidget {
  final List<Map<String, dynamic>> receivers;

  const ReceiversMapView({super.key, required this.receivers});

  @override
  State<ReceiversMapView> createState() => ReceiversMapViewState();
}

class ReceiversMapViewState extends State<ReceiversMapView> {
  final MapController _mapController = MapController();

  static const double _minZoom = 3;
  static const double _maxZoom = 18;

  bool _mapReady = false;
  int _fitGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => recenter());
  }

  /// Recentra la cámara en los marcadores (p. ej. al mostrar la pestaña Mapa).
  void recenter() {
    _scheduleFitToMarkers();
  }

  void _scheduleFitToMarkers({int attempt = 0}) {
    final gen = ++_fitGeneration;
    final points = receiverPointsWithCoords(widget.receivers);

    void runFit() {
      if (!mounted || gen != _fitGeneration) return;
      if (points.isEmpty) return;
      if (!_mapReady && attempt < 12) {
        Future<void>.delayed(Duration(milliseconds: 40 * (attempt + 1)), () {
          if (mounted && gen == _fitGeneration) {
            _scheduleFitToMarkers(attempt: attempt + 1);
          }
        });
        return;
      }
      _fitToMarkers(points);
      // En web, un segundo movimiento fuerza el repintado de teselas.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || gen != _fitGeneration || !_mapReady) return;
        final c = _mapController.camera;
        _mapController.move(c.center, c.zoom);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => runFit());
  }

  void _fitToMarkers(List<LatLng> points) {
    if (!mounted || points.isEmpty) return;
    try {
      if (points.length == 1) {
        _mapController.move(points.first, 14);
        return;
      }
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
      );
    } catch (_) {
      // El controlador puede no estar listo aún; lo reintenta _scheduleFitToMarkers.
    }
  }

  void _zoomBy(double delta) {
    if (!mounted || !_mapReady) return;
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
      _scheduleFitToMarkers();
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
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SaviaColors.mapMarkerGlow,
                    boxShadow: [
                      BoxShadow(
                        color: SaviaColors.mapMarker.withValues(alpha: 0.55),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: SaviaColors.mapMarker,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SaviaColors.onPrimary,
                          width: 2,
                        ),
                      ),
                    ),
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
            style: const TextStyle(color: SaviaColors.textSecondary),
          ),
        ),
      );
    }

    final center = LatLng(
      points.map((e) => e.latitude).reduce((a, b) => a + b) / points.length,
      points.map((e) => e.longitude).reduce((a, b) => a + b) / points.length,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SaviaColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: points.length == 1 ? 14 : 10,
                      minZoom: _minZoom,
                      maxZoom: _maxZoom,
                      backgroundColor: SaviaColors.background,
                      onMapReady: () {
                        _mapReady = true;
                        _scheduleFitToMarkers();
                      },
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                        scrollWheelVelocity: 0.04,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'savia_lightweight',
                        panBuffer: 2,
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  color: SaviaColors.surface,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Acercar',
                        icon: const Icon(Icons.add, color: SaviaColors.textPrimary),
                        onPressed: () => _zoomBy(1),
                      ),
                      const Divider(height: 1, color: SaviaColors.border),
                      IconButton(
                        tooltip: 'Alejar',
                        icon: const Icon(Icons.remove, color: SaviaColors.textPrimary),
                        onPressed: () => _zoomBy(-1),
                      ),
                      const Divider(height: 1, color: SaviaColors.border),
                      IconButton(
                        tooltip: 'Ver todos los puntos',
                        icon: const Icon(
                          Icons.fit_screen,
                          color: SaviaColors.textPrimary,
                        ),
                        onPressed: recenter,
                      ),
                    ],
                  ),
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }
}
