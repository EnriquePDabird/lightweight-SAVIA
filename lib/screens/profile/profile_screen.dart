import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../theme/savia_colors.dart';
import '../../widgets/savia_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userLastName;
  final String organization;
  final String email;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userLastName,
    required this.organization,
    required this.email,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String get _fullName {
    if (widget.userName.isEmpty && widget.userLastName.isEmpty) {
      return 'Usuario';
    }
    return '${widget.userName} ${widget.userLastName}'.trim();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await AuthService().updatePassword(
        currentPassword: _currentPassword.text,
        newPassword: _newPassword.text,
      );
      if (!mounted) return;
      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada correctamente.'),
          backgroundColor: SaviaColors.success,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'wrong-password' || 'invalid-credential' =>
          'La contraseña actual no es correcta.',
        'weak-password' => 'La nueva contraseña es demasiado débil.',
        _ => 'No se pudo cambiar la contraseña: ${e.message ?? e.code}',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: SaviaColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: SaviaColors.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: SaviaColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: SaviaColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaviaColors.background,
      appBar: const SaviaAppBar(title: 'Mi perfil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: SaviaColors.primary.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.person,
                    size: 44,
                    color: SaviaColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SaviaSectionCard(
                icon: Icons.badge_outlined,
                title: 'Datos de la cuenta',
                children: [
                  _infoRow('Nombre', _fullName, Icons.person_outline),
                  _infoRow(
                    'Organización',
                    widget.organization,
                    Icons.business_outlined,
                  ),
                  _infoRow(
                    'Correo',
                    widget.email.isNotEmpty ? widget.email : '—',
                    Icons.email_outlined,
                  ),
                ],
              ),
              SaviaSectionCard(
                icon: Icons.lock_outline,
                title: 'Cambiar contraseña',
                children: [
                  const SaviaFieldLabel('Contraseña actual'),
                  TextFormField(
                    controller: _currentPassword,
                    obscureText: _obscureCurrent,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Introduce tu contraseña actual' : null,
                  ),
                  const SizedBox(height: 12),
                  const SaviaFieldLabel('Nueva contraseña'),
                  TextFormField(
                    controller: _newPassword,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const SaviaFieldLabel('Confirmar nueva contraseña'),
                  TextFormField(
                    controller: _confirmPassword,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v != _newPassword.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SaviaPrimaryButton(
                    label: 'Actualizar contraseña',
                    loading: _saving,
                    onPressed: _changePassword,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
