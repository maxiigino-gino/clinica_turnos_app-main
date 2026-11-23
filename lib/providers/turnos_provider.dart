import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../data/turnos_repository.dart';
import '../models/especialista.dart';
import '../models/turno.dart';

class TurnosProvider extends ChangeNotifier {
  final TurnosRepository _repo;
  final List<Especialista> _especialistas = MockData.especialistasIniciales();
  List<Turno> _turnos = [];

  TurnosProvider({TurnosRepository? repo}) : _repo = repo ?? TurnosRepository();

  /// Carga los turnos guardados en el dispositivo (se llama al iniciar la app).
  Future<void> cargar() async {
    _turnos = await _repo.obtenerTurnos();
    notifyListeners();
  }

  void _guardar() => _repo.guardarTurnos(_turnos);

  /// Un turno cancelado no ocupa el horario ni aparece en la agenda.
  bool _activo(Turno t) => t.estado != EstadoTurno.cancelado;

  /// Cancela el turno: cambia su estado, guarda y avisa a la UI.
  void cancelarTurno(String id) {
    final i = _turnos.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _turnos[i] = _turnos[i].copyWith(estado: EstadoTurno.cancelado);
    _guardar();
    notifyListeners();
  }

  List<String> get especialidades =>
      _especialistas.map((e) => e.especialidad).toSet().toList();

  List<Especialista> especialistasPorEspecialidad(String especialidad) =>
      _especialistas.where((e) => e.especialidad == especialidad).toList();

  /// Turnos cargados para el día de hoy.
  List<Turno> turnosDeHoy() {
    final hoy = DateTime.now();
    final deHoy = _turnos.where((t) =>
        _activo(t) &&
        t.fecha.year == hoy.year &&
        t.fecha.month == hoy.month &&
        t.fecha.day == hoy.day).toList();
    deHoy.sort((a, b) => a.horario.compareTo(b.horario));
    return deHoy;
  }

  /// Turnos del paciente logueado, ordenados por fecha + horario.
  List<Turno> turnosDePaciente(String nombrePaciente) {
    final lista = _turnos.where((t) => t.pacienteNombre == nombrePaciente).toList();
    lista.sort((a, b) {
      final cmp = a.fecha.compareTo(b.fecha);
      if (cmp != 0) return cmp;
      return a.horario.compareTo(b.horario);
    });
    return lista;
  }

  /// Todos los turnos, ordenados.
  List<Turno> get todosLosTurnos {
    final lista = [..._turnos];
    lista.sort((a, b) {
      final cmp = a.fecha.compareTo(b.fecha);
      if (cmp != 0) return cmp;
      return a.horario.compareTo(b.horario);
    });
    return lista;
  }

  /// Agrupa los turnos próximos por especialidad (hoy en adelante).
  Map<String, List<Turno>> turnosProximosPorEspecialidad() {
    final hoy = DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final proximos = _turnos.where((t) => _activo(t) && !t.fecha.isBefore(inicioHoy)).toList();

    proximos.sort((a, b) {
      final cmp = a.fecha.compareTo(b.fecha);
      if (cmp != 0) return cmp;
      return a.horario.compareTo(b.horario);
    });

    final Map<String, List<Turno>> agrupados = {};
    for (final t in proximos) {
      agrupados.putIfAbsent(t.especialidad, () => []).add(t);
    }
    return agrupados;
  }

  /// Devuelve true si el especialista atiende ese día de la semana (1=lunes, 7=domingo).
  bool especialistaAtiende(Especialista e, DateTime fecha) =>
      e.diasAtencion.contains(fecha.weekday);

  /// Devuelve los horarios del especialista que todavía están libres en esa fecha.
  List<String> horariosLibres(Especialista e, DateTime fecha) {
    final ocupados = _turnos
        .where((t) =>
            _activo(t) &&
            t.especialistaId == e.id &&
            t.fecha.year == fecha.year &&
            t.fecha.month == fecha.month &&
            t.fecha.day == fecha.day)
        .map((t) => t.horario)
        .toSet();
    return e.horariosDisponibles.where((h) => !ocupados.contains(h)).toList();
  }

  /// Agrega un turno en una fecha específica.
  Turno agregarTurnoEnFecha({
    required String pacienteNombre,
    required Especialista especialista,
    required DateTime fecha,
    required String horario,
  }) {
    final turno = Turno(
      id: 't-${DateTime.now().millisecondsSinceEpoch}',
      pacienteNombre: pacienteNombre,
      especialistaId: especialista.id,
      especialistaNombre: especialista.nombre,
      especialidad: especialista.especialidad,
      fecha: fecha,
      horario: horario,
    );
    _turnos.add(turno);
    _guardar();
    notifyListeners();
    return turno;
  }

  /// [Mantiene compatibilidad] Agrega un turno para hoy.
  Turno agregarTurno({
    required String pacienteNombre,
    required Especialista especialista,
    required String horario,
  }) {
    return agregarTurnoEnFecha(
      pacienteNombre: pacienteNombre,
      especialista: especialista,
      fecha: DateTime.now(),
      horario: horario,
    );
  }
}
