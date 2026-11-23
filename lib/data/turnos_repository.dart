import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/turno.dart';

/// Guarda y lee los turnos en el almacenamiento local del dispositivo.
/// Los turnos se serializan a JSON usando Turno.toMap() / Turno.fromObject().
class TurnosRepository {
  static const _clave = 'turnos';

  Future<List<Turno>> obtenerTurnos() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_clave);
    if (texto == null) return [];
    try {
      final lista = jsonDecode(texto) as List<dynamic>;
      return lista
          .map((m) => Turno.fromObject(Map<String, dynamic>.from(m as Map)))
          .toList();
    } catch (_) {
      // Si los datos guardados están corruptos, se arranca sin turnos.
      return [];
    }
  }

  Future<void> guardarTurnos(List<Turno> turnos) async {
    final prefs = await SharedPreferences.getInstance();
    final texto = jsonEncode(turnos.map((t) => t.toMap()).toList());
    await prefs.setString(_clave, texto);
  }
}
