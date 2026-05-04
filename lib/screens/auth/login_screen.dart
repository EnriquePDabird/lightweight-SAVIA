import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Añadimos una variable para controlar el estado de carga
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Creamos la función que se ejecutará al presionar el botón
  void _iniciarSesion() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Hablamos con Firebase Auth
    final user = await AuthService().signInWithEmailAndPassword(
      email,
      password,
    );

    if (user != null) {
      // 2. Si el login fue exitoso, buscamos sus datos en Firestore
      final userData = await FirestoreService().getUserDataByEmail(user.email!);

      setState(() {
        _isLoading = false;
      });

      if (userData != null) {
        // Tenemos los datos Leemos si está activo y su rol
        final bool isActive =
            userData['active'] == "true"; // Según tu BD es un String
        final String role = userData['role'] ?? 'sin_rol';

        if (isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Has iniciado sesión con permisos: $role'),
              backgroundColor: Colors.green,
            ),
          );

          // 1. Extraemos el ID de la campaña de los datos que trajimos de Firestore
          final String campaignId = userData['campaignId'] ?? '';

          if (campaignId.isNotEmpty) {
            // 2. Por seguridad en Flutter, al usar 'await' debemos confirmar que la pantalla sigue activa
            if (!mounted) return;

            // 3. Navegamos al Home pasándole el ID. Usamos "pushReplacement" para destruir
            // la pantalla de Login y que el usuario no pueda volver pulsando "Atrás".
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(campaignId: campaignId),
              ),
            );
          } else {
            // Si el usuario está activo pero por algún motivo no tiene campaña
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tu usuario no tiene ninguna campaña asignada.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tu cuenta está desactivada.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se encontraro  n datos del usuario.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Falló el login en Auth
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Revisa tus credenciales'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '¡Bienvenido de nuevo!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Actualizamos el botón
                ElevatedButton(
                  // Si está cargando, deshabilitamos el botón (onPressed: null)
                  onPressed: _isLoading ? null : _iniciarSesion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  // Si está cargando, mostramos la ruedita, si no, el texto
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
