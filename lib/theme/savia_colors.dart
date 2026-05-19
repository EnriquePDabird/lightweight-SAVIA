import 'package:flutter/material.dart';

/// Paleta SAVIA — tema oscuro minimalista.
abstract final class SaviaColors {
  static const background = Color(0xFF121F21);
  static const surface = Color(0xFF1A2C2F);
  static const surfaceElevated = Color(0xFF243638);
  static const inputFill = Color(0xFF0D1618);
  static const border = Color(0xFF2E4548);
  static const borderLight = Color(0xFF3D5659);

  static const primary = Color(0xFFE85D04);
  static const primaryHover = Color(0xFFF07020);
  static const onPrimary = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0BEC5);
  static const textMuted = Color(0xFF78909C);
  static const textHint = Color(0xFF607D8B);

  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE57373);

  /// Marcadores en el mapa (acento naranja de la app).
  static const mapMarker = primary;
  static const mapMarkerGlow = Color(0x66E85D04);

  static const bottomNavBg = Color(0xFF1A2C2F);
}
