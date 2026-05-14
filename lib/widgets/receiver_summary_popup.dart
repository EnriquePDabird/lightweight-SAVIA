import 'package:flutter/material.dart';

import '../utils/receiver_coordinates.dart';

String _disp(dynamic v) {
  if (v == null) return '—';
  final s = v.toString().trim();
  return s.isEmpty ? '—' : s;
}

String _locationLine(Map<String, dynamic> r) {
  final parts = <String>[];
  void add(String? s) {
    if (s != null && s.trim().isNotEmpty) parts.add(s.trim());
  }

  add(r['municipality']?.toString());
  add(r['province']?.toString());
  add(r['region']?.toString());
  add(r['country']?.toString());

  final loc = r['location'];
  if (loc is Map) {
    final m = Map<String, dynamic>.from(loc);
    if (parts.isEmpty) {
      add(m['municipality']?.toString());
      add(m['province']?.toString());
      add(m['country']?.toString());
    }
  }

  return parts.isEmpty ? '—' : parts.join(', ');
}

String _coordsLine(Map<String, dynamic> r) {
  final ll = parseReceiverLatLng(r);
  if (ll == null) return '—';
  return '${ll.latitude.toStringAsFixed(5)}, ${ll.longitude.toStringAsFixed(5)}';
}

Widget _row(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Pop-up compacto con datos esenciales del receptor (lista o mapa).
void showReceiverEssentialPopup(
  BuildContext context,
  Map<String, dynamic> receiver,
) {
  final name = _disp(receiver['name']);
  final displayName = name == '—' ? 'Sin nombre' : name;
  final active = receiver['active'] == true;

  showDialog<void>(
    context: context,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blueAccent.shade100,
                      child: const Icon(Icons.person, color: Colors.blueAccent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(active ? 'Activo' : 'Inactivo'),
                    backgroundColor: active
                        ? Colors.green.shade50
                        : Colors.grey.shade200,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: active
                          ? Colors.green.shade800
                          : Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(height: 24),
                _row(Icons.phone, 'Teléfono', _disp(receiver['phone'])),
                _row(Icons.email_outlined, 'Email', _disp(receiver['email'])),
                _row(
                  Icons.business_outlined,
                  'Organización',
                  _disp(receiver['organization']),
                ),
                _row(Icons.group_outlined, 'Grupo', _disp(receiver['group'])),
                _row(Icons.wc_outlined, 'Sexo', _disp(receiver['sex'])),
                _row(
                  Icons.place_outlined,
                  'Ubicación',
                  _locationLine(receiver),
                ),
                _row(
                  Icons.my_location,
                  'Latitud / longitud',
                  _coordsLine(receiver),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
