import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../data/usuarios_repository.dart';
import '../models/usuario.dart';

class AuthProvider extends ChangeNotifier {
  final UsuariosRepository _repo;
  List<Usuario> _usuarios = MockData.usuariosIniciales();
  Usuario? _usuarioActual;

  AuthProvider({UsuariosRepository? repo}) : _repo = repo ?? UsuariosRepository();

  /// Carga los usuarios guardados. En el primer arranque guarda los de prueba.
  Future<void> cargar() async {
    final guardados = await _repo.obtenerUsuarios();
    if (guardados != null) {
      _usuarios = guardados;
    } else {
      await _repo.guardarUsuarios(_usuarios);
    }
    notifyListeners();
  }

  void _guardar() => _repo.guardarUsuarios(_usuarios);

  Usuario? get usuarioActual => _usuarioActual;

  String? login(String email, String password) {
    final coincidencias = _usuarios.where(
      (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
    );
    if (coincidencias.isEmpty) {
      return 'Email o contraseña incorrectos';
    }
    _usuarioActual = coincidencias.first;
    notifyListeners();
    return null;
  }

  String? registrarPaciente({
    required String nombre,
    required String apellido,
    required String dni,
    required String telefono,
    required String email,
    required String password,
  }) {
    final yaExiste = _usuarios.any((u) => u.email.toLowerCase() == email.toLowerCase());
    if (yaExiste) {
      return 'Ya existe una cuenta con ese email';
    }
    final nuevo = Usuario(
      id: 'p-${DateTime.now().millisecondsSinceEpoch}',
      nombre: nombre,
      apellido: apellido,
      dni: dni,
      telefono: telefono,
      email: email,
      password: password,
      rol: RolUsuario.paciente,
    );
    _usuarios.add(nuevo);
    _guardar();
    _usuarioActual = nuevo;
    notifyListeners();
    return null;
  }

  void actualizarPerfil(Usuario actualizado) {
    final index = _usuarios.indexWhere((u) => u.id == actualizado.id);
    if (index != -1) {
      _usuarios[index] = actualizado;
      _usuarioActual = actualizado;
      _guardar();
      notifyListeners();
    }
  }

  void logout() {
    _usuarioActual = null;
    notifyListeners();
  }
}
