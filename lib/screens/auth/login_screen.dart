import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../theme/savia_colors.dart';
import '../../widgets/savia_widgets.dart';
import '../home/main_shell_screen.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberSession = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _iniciarSesion() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final user = await AuthService().signInWithEmailAndPassword(email, password);

    if (user != null) {
      final userData = await FirestoreService().getUserDataById(user.uid);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (userData != null) {
        final bool isActive = userData['active'] == true;

        if (isActive) {
          final String org = (userData['organization'] ?? '').toString().trim();
          final String firstName = userData['name'] ?? '';
          final String lastName = userData['lastName'] ?? '';
          final String userRole = userData['role'] ?? '';

          if (org.isNotEmpty) {
            final email = user.email ?? AuthService().currentUserEmail ?? '';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainShellScreen(
                  userId: user.uid,
                  organization: org,
                  userName: firstName,
                  userLastName: lastName,
                  userRole: userRole,
                  userEmail: email,
                ),
              ),
            );
          } else {
            _showSnack(
              'Tu usuario no tiene organización asignada en Firestore.',
              SaviaColors.primary,
            );
          }
        } else {
          _showSnack('Tu cuenta está desactivada.', SaviaColors.primary);
        }
      } else {
        _showSnack('Error: No se encontraron datos del usuario.', SaviaColors.error);
      }
    } else {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Error: Revisa tus credenciales', SaviaColors.error);
    }
  }

  void _showSnack(String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bg),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaviaColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Center(child: SaviaLogo()),
                  const SizedBox(height: 40),
                  Text(
                    '¡Bienvenido de nuevo!',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accede a tu panel de gestión de campañas',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  const SaviaFieldLabel('Correo electrónico'),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: SaviaColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'nombre@empresa.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SaviaFieldLabel('Contraseña'),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Contacta con tu administrador.'),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '¿Lo olvidaste?',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: SaviaColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberSession,
                          onChanged: (v) =>
                              setState(() => _rememberSession = v ?? false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Mantener sesión iniciada',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SaviaPrimaryButton(
                    label: 'Iniciar Sesión',
                    loading: _isLoading,
                    trailingIcon: Icons.arrow_forward,
                    onPressed: _iniciarSesion,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    '© 2024 SAVIA - Consultoría para la sostenibilidad ambiental',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: SaviaColors.textMuted,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
