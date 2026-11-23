import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../providers/auth_provider.dart';
import 'paciente/home_paciente_screen.dart';
import 'recepcion/home_recepcion_screen.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const verdeOscuro = Color(0xFF1F5F5B);
  static const verdeClaro = Color(0xFF2A7D6F);
  static const crema = Color(0xFFF5F1E8);
  static const bordeCampo = Color(0xFFE0DAD0);
  static const textoOscuro = Color(0xFF1A2E2C);

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _verPassword = false;
  String? _error;

  void _ingresar() {
    final auth = context.read<AuthProvider>();
    final error = auth.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final rol = auth.usuarioActual!.rol;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            rol == RolUsuario.recepcion ? const HomeRecepcionScreen() : const HomePacienteScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decoracionCampo(String hint, {Widget? sufijo}) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: bordeCampo),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      filled: true,
      fillColor: crema,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: borde,
      enabledBorder: borde,
      focusedBorder: borde.copyWith(
        borderSide: const BorderSide(color: verdeOscuro, width: 1.4),
      ),
      suffixIcon: sufijo,
    );
  }

  Widget _etiqueta(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textoOscuro,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // "Volver" solo aparece si hay una pantalla anterior a la que volver
              if (Navigator.canPop(context))
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left, color: Colors.black54),
                    label: const Text(
                      'Volver',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ),
                )
              else
                const SizedBox(height: 48),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Ingresá a tu cuenta',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Usá tu correo y contraseña para continuar',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 28),
                    _etiqueta('Correo electrónico'),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _decoracionCampo('Ej: nombre@correo.com'),
                    ),
                    const SizedBox(height: 20),
                    _etiqueta('Contraseña'),
                    TextField(
                      controller: _passCtrl,
                      obscureText: !_verPassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _ingresar(),
                      decoration: _decoracionCampo(
                        'Tu contraseña',
                        sufijo: IconButton(
                          icon: Icon(
                            _verPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.black38,
                          ),
                          onPressed: () => setState(() => _verPassword = !_verPassword),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Color(0xFFC0392B))),
                    ],
                    const SizedBox(height: 24),
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [verdeClaro, verdeOscuro],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: InkWell(
                          onTap: _ingresar,
                          child: const SizedBox(
                            height: 56,
                            child: Center(
                              child: Text(
                                'Ingresar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿No tenés cuenta? ',
                          style: TextStyle(color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const RegistroScreen()),
                          ),
                          child: const Text(
                            'Registrate',
                            style: TextStyle(
                              color: verdeOscuro,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cuentas de prueba:\nmartin.gutierrez@email.com / 1234\nrecepcion@clinica.com / 1234',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
