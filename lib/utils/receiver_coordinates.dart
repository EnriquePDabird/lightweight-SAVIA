import 'package:latlong2/latlong.dart';

double? parseCoordinate(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString().trim().replaceAll(',', '.');
  if (s.isEmpty) return null;
  return double.tryParse(s);
}

/// Lee [latitud]/[longitud] en raíz, o [location.coordenadas] (lat/lng), o lat/lng en raíz.
LatLng? parseReceiverLatLng(Map<String, dynamic> r) {
  double? lat = parseCoordinate(r['latitud']);
  double? lng = parseCoordinate(r['longitud']);

  final loc = r['location'];
  if (loc is Map) {
    final m = Map<String, dynamic>.from(loc);
    final c = m['coordenadas'];
    if (c is Map) {
      final cm = Map<String, dynamic>.from(c);
      lat ??= parseCoordinate(cm['lat']) ?? parseCoordinate(cm['latitude']);
      lng ??=
          parseCoordinate(cm['lng']) ??
          parseCoordinate(cm['longitude']) ??
          parseCoordinate(cm['lon']);
    }
  }

  lat ??= parseCoordinate(r['lat']) ?? parseCoordinate(r['latitude']);
  lng ??=
      parseCoordinate(r['lng']) ??
      parseCoordinate(r['longitude']) ??
      parseCoordinate(r['lon']);

  if (lat == null || lng == null) return null;
  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
  return LatLng(lat, lng);
}

List<LatLng> receiverPointsWithCoords(List<Map<String, dynamic>> receivers) {
  final out = <LatLng>[];
  for (final r in receivers) {
    final p = parseReceiverLatLng(r);
    if (p != null) out.add(p);
  }
  return out;
}
