// funciones para validar datos de usuario
class Validadores {

  // valida dni español (8 numeros + 1 letra)
  static bool validarDNI(String dni) {
    if (dni.isEmpty) return true; // campo opcional

    RegExp dniRegex = RegExp(r'^[0-9]{8}[A-Za-z]$');
    if (!dniRegex.hasMatch(dni)) {
      return false;
    }

    // algoritmo para validar letra del dni
    String numero = dni.substring(0, 8);
    String letra = dni.substring(8, 9).toUpperCase();
    String letrasValidas = 'TRWAGMYFPDXBNJZSQVHLCKE';
    int modulo = int.parse(numero) % 23;

    return letra == letrasValidas[modulo];
  }

  // valida que sea mayor de 18 años
  static bool validarMayorDeEdad(String fechaNacimiento) {
    if (fechaNacimiento.isEmpty) return true;

    try {
      List<String> partesFecha = fechaNacimiento.split('/');
      if (partesFecha.length != 3) {
        return false;
      }

      DateTime fecha = DateTime(
        int.parse(partesFecha[2]), // año
        int.parse(partesFecha[1]), // mes
        int.parse(partesFecha[0]), // dia
      );

      DateTime hoy = DateTime.now();
      int edad = hoy.year - fecha.year;

      // ajusta si aun no ha cumplido años
      if (hoy.month < fecha.month ||
          (hoy.month == fecha.month && hoy.day < fecha.day)) {
        edad--;
      }

      return edad >= 18;
    } catch (e) {
      return false;
    }
  }

  // valida telefono movil español
  static bool validarTelefonoMovil(String telefono) {
    if (telefono.isEmpty) return true;

    RegExp telefonoRegex = RegExp(r'^[67][0-9]{8}$');
    return telefonoRegex.hasMatch(telefono);
  }

  // valida formato de correo electronico
  static bool validarCorreo(String correo) {
    if (correo.isEmpty) return false;

    RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(correo);
  }

  // valida contraseña minimo 6 caracteres
  static bool validarContrasena(String contrasena) {
    if (contrasena.isEmpty) return false;
    return contrasena.length >= 6;
  }

  // valida que las contraseñas coincidan
  static bool validarContrasenaCoinciden(String contrasena, String confirmarContrasena) {
    return contrasena == confirmarContrasena;
  }

  // formatea fecha de dd/mm/yyyy a yyyy-mm-dd
  static String formatearFecha(String fechaInput) {
    if (fechaInput.isEmpty) return '';

    List<String> partes = fechaInput.split('/');
    if (partes.length != 3) return fechaInput;

    return '${partes[2]}-${partes[1].padLeft(2, '0')}-${partes[0].padLeft(2, '0')}';
  }

  // valida precio por hora
  static bool validarPrecio(String precio) {
    if (precio.isEmpty) return false;

    try {
      final precioDouble = double.parse(precio);
      return precioDouble > 0 && precioDouble <= 999;
    } catch (e) {
      return false;
    }
  }

  // valida descripcion del servicio
  static bool validarDescripcionServicio(String descripcion) {
    if (descripcion.isEmpty) return false;
    return descripcion.trim().length >= 10;
  }

  // valida observaciones opcionales
  static bool validarObservaciones(String observaciones) {
    if (observaciones.isEmpty) return true;
    return observaciones.length <= 500;
  }

  // valida seleccion de tipo de servicio
  static bool validarTipoServicio(int? servicioId) {
    return servicioId != null && servicioId > 0;
  }
}