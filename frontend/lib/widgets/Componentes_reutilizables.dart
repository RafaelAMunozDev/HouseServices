import 'package:flutter/material.dart';
import '../widgets/TextoEscalable.dart';

// utilidades para crear componentes con estilo consistente
class Componentes_reutilizables {
  // colores para el tema de la aplicacion
  static const Color colorTituloSeccion = Color(0xFF4A4B8F);
  static const Color colorTextoElemento = Colors.black;
  static const Color colorDivisor = Color(0x42000000);

  // crea titulo de seccion para pantallas
  static Widget construirSeccion(String titulo, {bool usarTextoEscalable = true}) {
    final Widget tituloWidget = usarTextoEscalable
        ? TextoEscalable(
      texto: titulo,
      estilo: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorTituloSeccion),
    )
        : Text(titulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorTituloSeccion));

    return Padding(padding: EdgeInsets.only(top: 24, bottom: 12), child: tituloWidget);
  }

  // crea titulo de seccion con icono
  static Widget construirSeccionConIcono(String titulo, IconData icono) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Icon(icono, color: colorTituloSeccion, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: TextoEscalable(
              texto: titulo,
              estilo: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorTituloSeccion),
            ),
          ),
        ],
      ),
    );
  }

  // navegacion con transicion estandar
  static void navegarConTransicion(
      BuildContext context,
      Widget destino, {
        bool reemplazar = false,
        int duracionMs = 400,
      }) {
    final route = PageRouteBuilder(
      transitionDuration: Duration(milliseconds: duracionMs),
      pageBuilder: (context, animation, secondaryAnimation) => destino,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );

    if (reemplazar) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  // crea elemento de configuracion individual
  static Widget construirElemento(
      String titulo, {
        Widget? trailing,
        VoidCallback? onTap,
        bool usarTextoEscalable = true,
        EdgeInsetsGeometry? contentPadding,
      }) {
    final Widget tituloWidget = usarTextoEscalable
        ? TextoEscalable(
      texto: titulo,
      estilo: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorTextoElemento),
    )
        : Text(titulo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorTextoElemento));

    return Column(
      children: [
        ListTile(
          title: tituloWidget,
          trailing: trailing,
          contentPadding: contentPadding ?? EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          onTap: onTap,
        ),
        Divider(height: 1, color: colorDivisor),
      ],
    );
  }

  // crea interruptor para opciones
  static Switch crearInterruptor({
    required bool valor,
    required ValueChanged<bool>? onChanged,
    Color? colorActivo,
  }) {
    return Switch(
      value: valor,
      onChanged: onChanged,
      activeColor: colorActivo ?? const Color(0xFF616281),
      inactiveThumbColor: const Color(0xFF757575),
      inactiveTrackColor: Colors.grey[300],
    );
  }

  // construye campo de texto generico
  static Widget construirCampoTexto({
    required TextEditingController controlador,
    required String etiqueta,
    required IconData icono,
    bool habilitado = true,
    String? infoTooltip,
    TextInputType? tipoTeclado,
    String? Function(String?)? validador,
    bool esOculto = false,
    Function()? alPulsar,
    bool soloLectura = false,
    int? maxLength,
  }) {
    return Container(
      width: 330,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controlador,
        enabled: habilitado,
        keyboardType: tipoTeclado,
        obscureText: esOculto,
        readOnly: soloLectura || alPulsar != null,
        maxLength: maxLength,
        validator: validador,
        onTap: alPulsar,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: Icon(icono),
          suffixIcon: infoTooltip != null ? Tooltip(message: infoTooltip, child: Icon(Icons.info_outline)) : null,
          filled: true,
          fillColor: habilitado ? Colors.white : Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Color(0xFF49454F))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Color(0xFFAAADFF), width: 2)),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey)),
          counterText: "",
        ),
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  // campo especifico para fechas
  static Widget construirCampoFecha({
    required TextEditingController controlador,
    required BuildContext context,
    String etiqueta = 'FECHA',
    IconData icono = Icons.calendar_today,
    DateTime? fechaMinima,
    DateTime? fechaMaxima,
    Function(DateTime)? alCambiar,
  }) {
    return construirCampoTexto(
      controlador: controlador,
      etiqueta: etiqueta,
      icono: icono,
      soloLectura: true,
      alPulsar: () async {
        DateTime fechaInicial = DateTime.now();
        if (controlador.text.isNotEmpty) {
          try {
            List<String> partes = controlador.text.split('/');
            if (partes.length == 3) {
              fechaInicial = DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
            }
          } catch (e) {
            // error en parseo de fecha
          }
        }

        DateTime? fechaSeleccionada = await showDatePicker(
          context: context,
          initialDate: fechaInicial,
          firstDate: fechaMinima ?? DateTime(1900),
          lastDate: fechaMaxima ?? DateTime.now(),
        );

        if (fechaSeleccionada != null) {
          String fechaFormateada = "${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}";
          controlador.text = fechaFormateada;
          if (alCambiar != null) alCambiar(fechaSeleccionada);
        }
      },
    );
  }

  // construye botones estilizados
  static Widget construirBoton({
    required String texto,
    required Function() alPulsar,
    Color colorFondo = const Color(0xFF616281),
    Color colorTexto = Colors.white,
    double ancho = 220,
    double alto = 52,
    double tamanoFuente = 20,
    FontWeight grosorFuente = FontWeight.w700,
    bool habilitado = true,
  }) {
    return GestureDetector(
      onTap: habilitado ? alPulsar : null,
      child: Opacity(
        opacity: habilitado ? 1.0 : 0.5,
        child: Container(
          width: ancho,
          height: alto,
          decoration: ShapeDecoration(
            color: colorFondo,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
          child: Center(
            child: TextoEscalable(
              texto: texto,
              estilo: TextStyle(color: colorTexto, fontSize: tamanoFuente, fontFamily: 'Roboto', fontWeight: grosorFuente),
            ),
          ),
        ),
      ),
    );
  }

  // construye encabezados con titulo y subtitulo
  static Widget construirEncabezado({
    required String titulo,
    String? subtitulo,
    double? anchoTitulo,
    double altoTitulo = 52,
    double tamanoTitulo = 33,
    double tamanoSubtitulo = 15,
    EdgeInsets margen = const EdgeInsets.only(top: 10, bottom: 20),
    TextAlign alineacionSubtitulo = TextAlign.justify,
    BuildContext? context,
  }) {
    final double anchoReal = anchoTitulo ?? 276;

    return Column(
      children: [
        Container(
          width: anchoReal,
          height: altoTitulo,
          child: TextoEscalable(
            texto: titulo,
            estilo: TextStyle(
              color: Colors.black,
              fontSize: tamanoTitulo,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
            alineacion: TextAlign.center,
          ),
        ),
        if (subtitulo != null)
          Container(
            width: anchoReal,
            margin: margen,
            child: TextoEscalable(
              texto: subtitulo,
              estilo: TextStyle(color: Color(0xFF49454F), fontSize: tamanoSubtitulo, fontFamily: 'Roboto', fontWeight: FontWeight.w500),
              alineacion: alineacionSubtitulo,
            ),
          ),
      ],
    );
  }

  // construye avatar de usuario
  static Widget construirAvatar({
    String? urlImagen,
    double radio = 50,
    Color colorFondo = const Color(0xFFAAADFF),
    Color colorIcono = Colors.white,
    double tamanoIcono = 50,
  }) {
    return CircleAvatar(
      radius: radio,
      backgroundColor: colorFondo,
      backgroundImage: urlImagen != null ? NetworkImage(urlImagen) : null,
      child: urlImagen == null ? Icon(Icons.person, size: tamanoIcono, color: colorIcono) : null,
    );
  }

  // construye contenedor principal de una pagina
  static Widget construirContenedorPrincipal({
    required Widget contenido,
    Color colorFondo = const Color(0xFFD2D4F1),
    bool mostrarLogo = true,
    String? rutaLogo = 'assets/logotipo.png',
    double anchoLogo = 280,
    double altoLogo = 160,
  }) {
    return Column(
      children: [
        if (mostrarLogo && rutaLogo != null)
          SizedBox(width: anchoLogo, height: altoLogo, child: Image.asset(rutaLogo, fit: BoxFit.contain)),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colorFondo,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: contenido,
          ),
        ),
      ],
    );
  }

  // construye campo de contrasena con visibilidad
  static Widget construirCampoContrasena({
    required TextEditingController controlador,
    required String etiqueta,
    required bool esOculto,
    required Function(bool) cambiarVisibilidad,
    IconData icono = Icons.lock,
    bool habilitado = true,
  }) {
    return Container(
      width: 330,
      child: TextFormField(
        controller: controlador,
        obscureText: esOculto,
        enabled: habilitado,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: Icon(icono),
          suffixIcon: IconButton(
            icon: Icon(esOculto ? Icons.visibility_off : Icons.visibility),
            onPressed: () => cambiarVisibilidad(!esOculto),
          ),
          filled: true,
          fillColor: habilitado ? Colors.white : Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Color(0xFF49454F))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Color(0xFFAAADFF), width: 2)),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey)),
        ),
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  // construye grupo de iconos de redes sociales
  static Widget construirGrupoIconosSociales() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      width: 178,
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // iconos de redes sociales con estilo consistente
          _construirIconoSocial('assets/google_icon.png'),
          SizedBox(width: 15),
          _construirIconoSocial('assets/facebook_icon.png'),
          SizedBox(width: 15),
          _construirIconoSocial('assets/apple_icon.png'),
        ],
      ),
    );
  }

  // construye icono social individual
  static Widget _construirIconoSocial(String rutaAsset) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: Offset(0, 1))],
      ),
      child: ClipOval(child: Image.asset(rutaAsset, fit: BoxFit.cover)),
    );
  }

  // construye enlace de autenticacion
  static Widget construirEnlaceAutenticacion({
    required String textoInfo,
    required String textoEnlace,
    required Function() alPulsar,
    Color colorEnlace = const Color(0xFFB25DE6),
  }) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(textoInfo, style: TextStyle(color: Colors.black, fontSize: 17, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          SizedBox(width: 5),
          GestureDetector(
            onTap: () async {
              await Future.delayed(const Duration(milliseconds: 150));
              alPulsar();
            },
            child: Text(textoEnlace, style: TextStyle(color: colorEnlace, fontSize: 17, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // construye texto de cabecera para opciones de autenticacion
  static Widget construirTextoOpcionAutenticacion({
    required String texto,
    double ancho = 250,
    double alto = 28,
    EdgeInsets margen = const EdgeInsets.only(top: 20),
  }) {
    return Container(
      margin: margen,
      child: Column(
        children: [
          SizedBox(
            width: ancho,
            height: alto,
            child: Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // menu moderno para servicios
  static void mostrarMenuOpcionesServicio({
    required BuildContext context,
    required VoidCallback onEditar,
    required VoidCallback onEliminar,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text('Opciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _construirOpcionMenu(context, Icons.edit, 'Editar servicio', Color(0xFF616281), onEditar),
            _construirOpcionMenu(context, Icons.delete, 'Eliminar servicio', Colors.red, onEliminar),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // menu moderno para imagenes
  static void mostrarMenuOpcionesImagen({
    required BuildContext context,
    required VoidCallback onGaleria,
    required VoidCallback onCamara,
    VoidCallback? onEliminar,
    bool mostrarEliminar = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text('Seleccionar imagen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _construirOpcionMenu(context, Icons.photo_library, 'Galeria', Color(0xFF616281), onGaleria),
            _construirOpcionMenu(context, Icons.camera_alt, 'Camara', Colors.blue, onCamara),
            if (mostrarEliminar && onEliminar != null)
              _construirOpcionMenu(context, Icons.delete, 'Eliminar imagen', Colors.red, onEliminar),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // construye opcion de menu individual
  static Widget _construirOpcionMenu(BuildContext context, IconData icono, String titulo, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icono, color: color),
      ),
      title: Text(titulo),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}