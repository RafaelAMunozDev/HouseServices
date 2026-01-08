import 'package:flutter/material.dart';
import '../../../../widgets/TextoEscalable.dart';
import '../../../../controllers/main/pages_configuracion/TerminoPoliticaController.dart';

class TerminosServicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextoEscalable(
          texto: 'Terminos de Servicio',
          estilo: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFAAADFF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFAAADFF),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD2D4F1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              TerminoPoliticaController.construirSeccion(
                'Aceptacion de los terminos',
                'Al acceder y utilizar la aplicacion HouseService, aceptas estos Terminos de Servicio y acuerdas cumplir con ellos. Si no estas de acuerdo con alguna parte de estos terminos, no deberias usar nuestra aplicacion.\n\nEstos Terminos se aplican a todos los visitantes, usuarios y otras personas que accedan o utilicen el Servicio.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Cambios en los terminos',
                'Nos reservamos el derecho, a nuestra sola discrecion, de modificar o reemplazar estos Terminos en cualquier momento. Si una revision es material, haremos todos los esfuerzos razonables para proporcionar al menos 30 dias de aviso antes de que entren en vigor los nuevos terminos. Lo que constituye un cambio material sera determinado a nuestra sola discrecion.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Cuentas',
                'Cuando creas una cuenta con nosotros, debes proporcionar informacion precisa, completa y actualizada en todo momento. El incumplimiento de lo anterior constituye un incumplimiento de los Terminos, que puede resultar en la terminacion inmediata de tu cuenta en nuestro Servicio.\n\nEres responsable de salvaguardar la contraseña que utilizas para acceder al Servicio y de cualquier actividad o accion bajo tu contraseña. Te comprometes a no revelar tu contraseña a terceros.\n\nDebes notificarnos inmediatamente de cualquier violacion de seguridad o uso no autorizado de tu cuenta.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Contratacion de servicios',
                'HouseService actua como intermediario entre los usuarios y los proveedores de servicios independientes. No somos proveedores de servicios ni empleadores de los profesionales que ofrecen servicios a traves de nuestra plataforma.\n\nAl solicitar un servicio, estas estableciendo una relacion contractual directa con el proveedor de servicios, no con HouseService. Sin embargo, como facilitadores de esta relacion, establecemos ciertas reglas y estandares para ambas partes.\n\nNos esforzamos por verificar a todos los proveedores de servicios, pero no podemos garantizar la calidad, seguridad o legalidad de los servicios ofrecidos.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Pagos y tarifas',
                'Al utilizar nuestros servicios, aceptas pagar todas las tarifas aplicables. HouseService cobra una comision por cada servicio contratado a traves de nuestra plataforma.\n\nLos precios de los servicios se muestran en la aplicacion y pueden variar segun la ubicacion, el tipo de servicio y otros factores. Siempre veras el precio total antes de confirmar un servicio.\n\nLas cancelaciones pueden estar sujetas a cargos segun nuestra politica de cancelacion, que varia dependiendo del tiempo previo a la cita programada.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Propiedad intelectual',
                'El Servicio y su contenido original, caracteristicas y funcionalidad son y seguiran siendo propiedad exclusiva de HouseService y sus licenciantes. El Servicio esta protegido por derechos de autor, marcas registradas y otras leyes de España y otros paises.\n\nNuestras marcas registradas y nuestro aspecto comercial no pueden ser utilizados en relacion con ningun producto o servicio sin el consentimiento previo por escrito de HouseService.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Terminacion',
                'Podemos terminar o suspender tu cuenta inmediatamente, sin previo aviso o responsabilidad, por cualquier motivo, incluyendo, sin limitacion, si incumples los Terminos.\n\nAl terminar tu cuenta, tu derecho a utilizar el Servicio cesara inmediatamente. Si deseas terminar tu cuenta, simplemente puedes dejar de usar el Servicio.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Limitacion de responsabilidad',
                'En ningun caso HouseService, ni sus directores, empleados, socios, agentes, proveedores o afiliados, seran responsables por cualquier daño indirecto, incidental, especial, consecuente o punitivo, incluyendo, sin limitacion, perdida de beneficios, datos, uso, buena voluntad, u otras perdidas intangibles, resultantes de (i) tu acceso o uso o incapacidad para acceder o usar el Servicio; (ii) cualquier conducta o contenido de terceros en el Servicio; (iii) cualquier contenido obtenido del Servicio; y (iv) acceso no autorizado, uso o alteracion de tus transmisiones o contenido.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Ley aplicable',
                'Estos Terminos se regiran e interpretaran de acuerdo con las leyes de España, sin tener en cuenta sus disposiciones sobre conflictos de leyes.\n\nNuestra falta de hacer cumplir cualquier derecho o disposicion de estos Terminos no se considerara una renuncia a esos derechos. Si alguna disposicion de estos Terminos es considerada invalida o inaplicable por un tribunal, las disposiciones restantes de estos Terminos permaneceran en vigor.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Contacto',
                'Para cualquier pregunta sobre estos Terminos, contactanos en:\n\n'
                    'Email: ejemplo@ejemplo.com\n'
                    'Direccion: Calle Inventada 15 Localidad Provincia',
              ),
              SizedBox(height: 20),
              Center(
                child: TextoEscalable(
                  texto: 'Ultima actualizacion: 10 de mayo de 2025',
                  estilo: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}