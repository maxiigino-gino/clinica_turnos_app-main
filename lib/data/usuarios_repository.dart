import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

/// Guarda y lee los usuarios (pacientes y recepción) en el almacenamiento local.
class UsuariosRepository {
  static const _clave = 'usuarios';

  /// Devuelve null si todavía no se guardó nada (primer arranque de la app).
  Future<List<Usuario>?> obtenerUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_clave);
    if (texto == null) return null;
    try {
      final lista = jsonDecode(texto) as List<dynamic>;
      return lista
          .map((m) => Usuario.fromObject(Map<String, dynamic>.from(m as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> guardarUsuarios(List<Usuario> usuarios) async {
    final prefs = await SharedPreferences.getInstance();
    final texto = jsonEncode(usuarios.map((u) => u.toMap()).toList());
    await prefs.setString(_clave, texto);
  }
}
