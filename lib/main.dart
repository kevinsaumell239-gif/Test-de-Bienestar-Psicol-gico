import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Sustituye esta URL si cambia la implementación de Apps Script.
const String webhookGoogle =
    'script.google.com/macros/s/AKfycbw1ah4mIX7pOgdyj7t0mVTMBWULACaMh3PNIl4-2qs8VteWobQN5061DhvqAA1HijtDcA/exec';

void main() {
  runApp(const TestPsicologicoApp());
}

class TestPsicologicoApp extends StatelessWidget {
  const TestPsicologicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test de Bienestar (EBES-JC)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          brightness: Brightness.light,
        ),
      ),
      home: const PantallaBienvenida(),
    );
  }
}

// Datos geográficos conservados del código enviado.
final Map<String, List<String>> cubaGeo = {
  'Pinar del Río': ['Consolación del Sur', 'Guane', 'La Palma', 'Los Palacios', 'Mantua', 'Minas de Matahambre', 'Pinar del Río', 'San Juan y Martínez', 'San Luis', 'Sandino', 'Viñales'],
  'Artemisa': ['Alquízar', 'Artemisa', 'Bauta', 'Caimito', 'Guanajay', 'Güira de Melena', 'Mariel', 'San Antonio de los Baños', 'Bahía Honda', 'San Cristóbal', 'Candelaria'],
  'La Habana': ['Arroyo Naranjo', 'Boyeros', 'Centro Habana', 'Cerro', 'Cotorro', 'Diez de Octubre', 'Guanabacoa', 'La Habana del Este', 'La Habana Vieja', 'La Lisa', 'Marianao', 'Playa', 'Plaza de la Revolución', 'Regla', 'San Miguel del Padrón'],
  'Mayabeque': ['Batabanó', 'Bejucal', 'Güines', 'Jaruco', 'Madruga', 'Melena del Sur', 'Nueva Paz', 'Quivicán', 'San José de las Lajas', 'San Nicolás', 'Santa Cruz del Norte'],
  'Matanzas': ['Calimete', 'Cárdenas', 'Ciénaga de Zapata', 'Colón', 'Jagüey Grande', 'Jovellanos', 'Limonar', 'Los Arabos', 'Martí', 'Matanzas', 'Pedro Betancourt', 'Perico', 'Unión de Reyes'],
  'Cienfuegos': ['Abreus', 'Aguada de Pasajeros', 'Cruces', 'Cumanayagua', 'Lajas', 'Palmira', 'Rodas', 'Cienfuegos'],
  'Villa Clara': ['Caibarién', 'Camajuaní', 'Cifuentes', 'Corralillo', 'Encrucijada', 'Manicaragua', 'Placetas', 'Quemado de Güines', 'Ranchuelo', 'San Juan de los Remedios', 'Sagua la Grande', 'Santa Clara', 'Santo Domingo'],
  'Sancti Spíritus': ['Cabaiguán', 'Fomento', 'Jatibonico', 'La Sierpe', 'Sancti Spíritus', 'Taguasco', 'Trinidad', 'Yaguajay'],
  'Ciego de Ávila': ['Baraguá', 'Bolivia', 'Chambas', 'Ciego de Ávila', 'Ciro Redondo', 'Florencia', 'Majagua', 'Morón', 'Primero de Enero', 'Venezuela'],
  'Camagüey': ['Camagüey', 'Carlos Manuel de Céspedes', 'Esmeralda', 'Florida', 'Guáimaro', 'Jimaguayú', 'Minas', 'Najasa', 'Nuevitas', 'Santa Cruz del Sur', 'Sibanicú', 'Sierra de Cubitas', 'Vertientes'],
  'Las Tunas': ['Amancio', 'Colombia', 'Jesús Menéndez', 'Jobabo', 'Majibacoa', 'Manatí', 'Puerto Padre', 'Las Tunas'],
  'Holguín': ['Antilla', 'Báguanos', 'Banes', 'Cacocum', 'Calixto García', 'Cueto', 'Frank País', 'Gibara', 'Holguín', 'Mayarí', 'Moa', 'Rafael Freyre', 'Sagua de Tánamo', 'Urbano Noris'],
  'Granma': ['Bartolomé Masó', 'Bayamo', 'Buey Arriba', 'Campechuela', 'Cauto Cristo', 'Guisa', 'Jiguaní', 'Manzanillo', 'Media Luna', 'Niquero', 'Pilón', 'Río Cauto', 'Yara'],
  'Santiago de Cuba': ['Contramaestre', 'Guamá', 'Mella', 'Palma Soriano', 'San Luis', 'Santiago de Cuba', 'Segundo Frente', 'Songo - La Maya', 'Tercer Frente'],
  'Guantánamo': ['Baracoa', 'Caimanera', 'El Salvador', 'Guantánamo', 'Imías', 'Maisí', 'Manuel Tames', 'Niceto Pérez', 'San Antonio del Sur', 'Yateras'],
  'Municipio Especial Isla de la Juventud': ['Isla de la Juventud'],
};

class DatosUsuario {
  String nombre = '';
  int edad = 15;
  String sexo = '';
  String provincia = '';
  String municipio = '';
  String grupo = '';
}

class ItemTest {
  final String codigo;
  final String texto;
  final bool invertido;

  const ItemTest(this.codigo, this.texto, {this.invertido = false});
}

const List<ItemTest> itemsPuntuables = [
  // Esfera A: Bienestar emocional
  ItemTest('A1', 'Cuando algo imprevisto me altera, logro recuperar la calma en poco tiempo.'),
  ItemTest('A2', 'Cuando tengo un conflicto con otra persona, logro controlar lo que siento.'),
  ItemTest('A3', 'Mis cambios de humor me resultan difíciles de controlar.', invertido: true),
  ItemTest('A4', 'Después de un momento de tensión, me cuesta volver a sentirme bien.', invertido: true),
  ItemTest('A5', 'Disfruto de las cosas que hago en mi día a día.'),
  ItemTest('A6', 'Me siento en paz conmigo mismo/a.'),
  ItemTest('A7', 'Tengo claro lo que siento.'),
  ItemTest('A8', 'Me siento satisfecho/a con la persona en la que me estoy convirtiendo.'),
  // Esfera B: Apoyo social
  ItemTest('B1', 'Tengo al menos una persona que me entiende de verdad.'),
  ItemTest('B2', 'Cuando necesito ayuda, hay alguien a quien puedo acudir.'),
  ItemTest('B3', 'Puedo hablar de lo que siento con alguien de mi entorno.'),
  ItemTest('B4', 'En mi familia me siento aceptado/a como soy.'),
  ItemTest('B5', 'Me siento parte de al menos un grupo (amistades, estudio, trabajo o comunidad).'),
  ItemTest('B6', 'Siento que las personas cercanas me valoran.'),
  ItemTest('B7', 'Me siento solo/a aunque esté rodeado/a de gente.', invertido: true),
  ItemTest('B8', 'Cuando tengo un problema serio, siento que debo resolverlo completamente solo/a.', invertido: true),
  // Esfera C: Adaptación al contexto
  ItemTest('C1', 'Cuando fallan los servicios básicos (agua, electricidad, transporte), encuentro alguna manera de seguir con mis actividades.'),
  ItemTest('C2', 'Cuando surgen imprevistos, puedo cambiar mis planes sin sentirme desbordado/a.'),
  ItemTest('C3', 'Logro mantener una rutina diaria a pesar de la incertidumbre.'),
  ItemTest('C4', 'Cuando mis recursos son limitados, busco alternativas para resolver lo que necesito.'),
  ItemTest('C5', 'Sigo adelante con mis estudios o trabajo aunque haya interrupciones.'),
  ItemTest('C6', 'Aprendo cosas nuevas que me ayudan a enfrentar las exigencias actuales.'),
  ItemTest('C7', 'La incertidumbre del día a día me paraliza.', invertido: true),
  ItemTest('C8', 'Las dificultades de mi entorno me hacen sentir que no puedo hacer nada por mejorar mi situación.', invertido: true),
  // Esfera D: Proyección de futuro
  ItemTest('D1', 'Tengo metas que me motivan a seguir adelante.'),
  ItemTest('D2', 'Imagino oportunidades de progreso para mí en los próximos años.'),
  ItemTest('D3', 'Siento que lo que hago hoy tiene sentido para mi futuro.'),
  ItemTest('D4', 'Tengo proyectos que me ilusionan.'),
  ItemTest('D5', 'A pesar de las limitaciones, siento que puedo influir en el rumbo de mi vida.'),
  ItemTest('D6', 'Tengo energía para trabajar por lo que quiero lograr.'),
  ItemTest('D7', 'Siento que, haga lo que haga, mi futuro no va a mejorar.', invertido: true),
  ItemTest('D8', 'Me cuesta imaginar cómo será mi vida dentro de un par de años.', invertido: true),
];

const List<ItemTest> itemsSeguridad = [
  ItemTest('S1', 'En las últimas dos semanas, he sentido que la vida no vale la pena.'),
  ItemTest('S2', 'En las últimas dos semanas, he pensado en hacerme daño o en quitarme la vida.'),
];

const List<String> opcionesLikert = [
  'Nunca',
  'Rara vez',
  'A veces',
  'Frecuentemente',
  'Siempre',
];

class PantallaBienvenida extends StatefulWidget {
  const PantallaBienvenida({super.key});

  @override
  State<PantallaBienvenida> createState() => _PantallaBienvenidaState();
}

class _PantallaBienvenidaState extends State<PantallaBienvenida> {
  final _formKey = GlobalKey<FormState>();
  final DatosUsuario datos = DatosUsuario();
  String? provinciaSeleccionada;
  String? municipioSeleccionado;
  List<String> municipiosDisponibles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.psychology_alt, size: 80, color: Color(0xFF4A90E2)),
                  const SizedBox(height: 10),
                  const Text('Test de Bienestar', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const Text('(EBES-JC)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 15),
                  const Text('Este test ayudará a comprender tu estado emocional actual. Responde con sinceridad.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.black87)),
                  const SizedBox(height: 25),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Nombre (Opcional)', prefixIcon: Icon(Icons.person_outline)),
                            onSaved: (value) => datos.nombre = value?.trim() ?? '',
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Edad (15 - 25 años) *', prefixIcon: Icon(Icons.cake_outlined)),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final edad = int.tryParse(value ?? '');
                              if (edad == null || edad < 15 || edad > 25) return 'Rango válido: 15 a 25 años';
                              return null;
                            },
                            onSaved: (value) => datos.edad = int.parse(value!),
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Sexo *', prefixIcon: Icon(Icons.wc_outlined)),
                            items: const [
                              DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                              DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                            ],
                            validator: (value) => value == null ? 'Seleccione sexo' : null,
                            onChanged: (value) => datos.sexo = value ?? '',
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Provincia *', prefixIcon: Icon(Icons.map_outlined)),
                            items: cubaGeo.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                            validator: (value) => value == null ? 'Seleccione provincia o municipio especial' : null,
                            onChanged: (value) {
                              setState(() {
                                provinciaSeleccionada = value;
                                municipioSeleccionado = null;
                                municipiosDisponibles = cubaGeo[value] ?? [];
                                datos.provincia = value ?? '';
                                datos.municipio = '';
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            key: ValueKey(provinciaSeleccionada),
                            decoration: const InputDecoration(labelText: 'Municipio *', prefixIcon: Icon(Icons.location_city_outlined)),
                            items: municipiosDisponibles.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                            validator: (value) => value == null ? 'Seleccione municipio' : null,
                            onChanged: (value) {
                              setState(() {
                                municipioSeleccionado = value;
                                datos.municipio = value ?? '';
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Grupo o Escuela (Opcional)', prefixIcon: Icon(Icons.school_outlined)),
                            onSaved: (value) => datos.grupo = value?.trim() ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaTest(datos: datos)));
                      }
                    },
                    child: const Text('Comenzar Test', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Este instrumento es orientativo y no emite diagnósticos. Las respuestas del módulo final son sensibles y se utilizan para ofrecer orientación de apoyo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
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

class PantallaTest extends StatefulWidget {
  final DatosUsuario datos;
  const PantallaTest({super.key, required this.datos});

  @override
  State<PantallaTest> createState() => _PantallaTestState();
}

class _PantallaTestState extends State<PantallaTest> {
  int indice = 0;
  late List<int> respuestas;
  bool mostrandoSeguridad = false;

  @override
  void initState() {
    super.initState();
    respuestas = List<int>.filled(itemsPuntuables.length, 0);
  }

  ItemTest get itemActual => mostrandoSeguridad
      ? itemsSeguridad[indice - itemsPuntuables.length]
      : itemsPuntuables[indice];

  int? get respuestaActual => mostrandoSeguridad
      ? _respuestasSeguridad[indice - itemsPuntuables.length]
      : respuestas[indice];

  final List<int> _respuestasSeguridad = [0, 0];

  void responder(int valor) {
    setState(() {
      if (mostrandoSeguridad) {
        _respuestasSeguridad[indice - itemsPuntuables.length] = valor;
      } else {
        respuestas[indice] = valor;
      }

      if (indice < itemsPuntuables.length + itemsSeguridad.length - 1) {
        indice++;
        mostrandoSeguridad = indice >= itemsPuntuables.length;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PantallaResultados(
              datos: widget.datos,
              respuestas: List<int>.from(respuestas),
              respuestasSeguridad: List<int>.from(_respuestasSeguridad),
            ),
          ),
        );
      }
    });
  }

  void retroceder() {
    if (indice > 0) {
      setState(() {
        indice--;
        mostrandoSeguridad = indice >= itemsPuntuables.length;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = itemsPuntuables.length + itemsSeguridad.length;
    final progreso = (indice + 1) / totalItems;

    return PopScope(
      canPop: indice == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && indice > 0) retroceder();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(mostrandoSeguridad
              ? 'Módulo de seguridad ${indice - itemsPuntuables.length + 1}/${itemsSeguridad.length}'
              : 'Ítem ${indice + 1}/${itemsPuntuables.length}'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: retroceder),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(value: progreso, minHeight: 8),
            if (mostrandoSeguridad)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Text(
                  'Estas dos preguntas no forman parte de la puntuación. Si alguna respuesta indica que estás pasando por un momento difícil, te mostraremos opciones de apoyo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.deepOrange),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Text(itemActual.texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text('¿Con qué frecuencia ocurre esto?', style: TextStyle(color: Colors.grey, fontSize: 15)),
                    const SizedBox(height: 15),
                    ...List.generate(5, (i) {
                      final valor = i + 1;
                      final seleccionada = respuestaActual == valor;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: seleccionada ? Colors.blue.shade100 : null,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: seleccionada ? const Color(0xFF4A90E2) : Colors.blue.shade200, width: seleccionada ? 2 : 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => responder(valor),
                            child: Text(opcionesLikert[i], style: TextStyle(fontSize: 16, fontWeight: seleccionada ? FontWeight.bold : FontWeight.normal, color: seleccionada ? Colors.blue.shade900 : null)),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PantallaResultados extends StatefulWidget {
  final DatosUsuario datos;
  final List<int> respuestas;
  final List<int> respuestasSeguridad;

  const PantallaResultados({
    super.key,
    required this.datos,
    required this.respuestas,
    required this.respuestasSeguridad,
  });

  @override
  State<PantallaResultados> createState() => _PantallaResultadosState();
}

class _PantallaResultadosState extends State<PantallaResultados> {
  late double sA, sB, sC, sD, promedio;
  late String nivelOrientativo;
  late Color colorNivel;
  late bool alertaSeguridad;

  @override
  void initState() {
    super.initState();
    sA = _promedioEsfera(0, 8);
    sB = _promedioEsfera(8, 16);
    sC = _promedioEsfera(16, 24);
    sD = _promedioEsfera(24, 32);
    promedio = (sA + sB + sC + sD) / 4;

    final s1 = widget.respuestasSeguridad[0];
    final s2 = widget.respuestasSeguridad[1];
    // Umbral solicitado: cualquier respuesta distinta de Nunca en S2,
    // o A veces (3) o más en S1.
    alertaSeguridad = s2 > 1 || s1 >= 3;

    if (promedio >= 3.8) {
      nivelOrientativo = 'Bienestar alto';
      colorNivel = Colors.green;
    } else if (promedio >= 2.5) {
      nivelOrientativo = 'Bienestar moderado';
      colorNivel = Colors.orange;
    } else {
      nivelOrientativo = 'Bienestar bajo';
      colorNivel = Colors.red;
    }

    _enviarAGoogleSheets();
  }

  double _promedioEsfera(int inicio, int fin) {
    final valores = <int>[];
    for (var i = inicio; i < fin; i++) {
      final item = itemsPuntuables[i];
      final respuesta = widget.respuestas[i];
      valores.add(item.invertido ? 6 - respuesta : respuesta);
    }
    return valores.reduce((a, b) => a + b) / valores.length;
  }

    // Envío a Google Sheets robusto para Android
  Future<void> _enviarAGoogleSheets() async {
    if (webhookGoogle.contains("TU_SCRIPT")) return;
    try {
      final uri = Uri.parse(webhookGoogle);
      
      final body = {
        "fecha": DateTime.now().toLocal().toString().split('.')[0],
        "nombre": widget.datos.nombre.isEmpty ? "Anónimo" : widget.datos.nombre,
        "edad": widget.datos.edad,
        "sexo": widget.datos.sexo,
        "provincia": widget.datos.provincia,
        "municipio": widget.datos.municipio,
        "grupo": widget.datos.grupo.isEmpty ? "N/A" : widget.datos.grupo,
        "promedio": promedio.toStringAsFixed(2),
        "nivel_orientativo": nivelOrientativo,
        "esferaA": sA.toStringAsFixed(2),
        "esferaB": sB.toStringAsFixed(2),
        "esferaC": sC.toStringAsFixed(2),
        "esferaD": sD.toStringAsFixed(2),
        "seguridad_s1": widget.respuestasSeguridad[0],
        "seguridad_s2": widget.respuestasSeguridad[1],
        "alerta_seguridad": alertaSeguridad ? "CRITICA_ACTIVADA" : "NORMAL",
        "respuestas": [...widget.respuestas, ...widget.respuestasSeguridad].join(",")
      };

      // Usamos un cliente HTTP con seguimiento explícito o POST estándar
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      // Si Google Apps Script responde con una redirección típica (302) o éxito (200/201)
      if (response.statusCode == 200 || response.statusCode == 302 || response.statusCode == 303) {
        debugPrint("Telemetría enviada con éxito desde Android.");
      } else {
        debugPrint("Fallo en telemetría Android: Código ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Excepción al enviar telemetría en Android: $e");
    }
  }


  String _generarMensajeCompartir() {
    return '''RESULTADOS TEST DE BIENESTAR (EBES-JC)
Nombre: ${widget.datos.nombre.isEmpty ? 'Anónimo' : widget.datos.nombre}
Edad: ${widget.datos.edad} años | Sexo: ${widget.datos.sexo}
Ubicación: ${widget.datos.municipio}, ${widget.datos.provincia}
Grupo/Escuela: ${widget.datos.grupo.isEmpty ? 'N/A' : widget.datos.grupo}
Promedio orientativo: ${promedio.toStringAsFixed(2)} / 5.0
Nivel orientativo: $nivelOrientativo

Desglose por esferas (promedios 1-5):
Bienestar emocional (A): ${sA.toStringAsFixed(2)}
Apoyo social (B): ${sB.toStringAsFixed(2)}
Adaptación al contexto (C): ${sC.toStringAsFixed(2)}
Proyección de futuro (D): ${sD.toStringAsFixed(2)}

El resultado es orientativo y no constituye un diagnóstico.''';
  }

  Future<void> _compartirWhatsApp() async {
    final uri = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(_generarMensajeCompartir())}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir WhatsApp.')));
    }
  }

  Future<void> _compartirTelegram() async {
    final uri = Uri.parse('https://t.me/share/url?url=&text=${Uri.encodeComponent(_generarMensajeCompartir())}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir Telegram.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados orientativos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.assignment_turned_in, size: 75, color: Color(0xFF4A90E2)),
            const SizedBox(height: 15),
            Text('Promedio orientativo: ${promedio.toStringAsFixed(2)} / 5.0', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: colorNivel.withAlpha(25), borderRadius: BorderRadius.circular(14), border: Border.all(color: colorNivel, width: 1.5)),
              child: Text(nivelOrientativo, textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: colorNivel, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text('Promedio por esferas (1-5):', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
            _itemResultado('Bienestar emocional (A)', sA),
            _itemResultado('Apoyo social (B)', sB),
            _itemResultado('Adaptación al contexto (C)', sC),
            _itemResultado('Proyección de futuro (D)', sD),
            if (alertaSeguridad) ...[
              const SizedBox(height: 16),
              _panelApoyo(),
            ],
            const SizedBox(height: 20),
            const Text(
              'Este resultado es orientativo y no constituye un diagnóstico. Si tienes dudas o malestar, conversa con un profesional de la salud mental.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: const Icon(Icons.chat),
                label: const Text('Compartir por WhatsApp'),
                onPressed: _compartirWhatsApp,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0088CC), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: const Icon(Icons.send),
                label: const Text('Compartir por Telegram'),
                onPressed: _compartirTelegram,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const PantallaBienvenida()), (route) => false),
              child: const Text('Reiniciar Test'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _panelApoyo() {
    final esLaHabana = widget.datos.provincia == 'La Habana';
    return Card(
      color: const Color(0xFFFFF7ED),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFF59E0B))),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.favorite_outline, color: Color(0xFFB45309)),
                SizedBox(width: 8),
                Expanded(child: Text('No tienes que afrontar esto a solas', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF7C2D12)))),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Gracias por responder. Tus respuestas indican que podrías estar pasando por un momento difícil. No estás siendo juzgado/a y esta aplicación no emite diagnósticos. Si puedes, habla ahora con una persona de confianza o con un profesional de la salud.',
              style: TextStyle(fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 12),
            if (esLaHabana) ...[
              const Text('Recursos de La Habana proporcionados para esta aplicación:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('• CEBPSI Centro de Bienestar Psicológico\nDirección: calle 19 entre calle L y calle K, Vedado, Plaza de la Revolución.'),
              const SizedBox(height: 8),
              const Text('• Servicio de Psiquiatría, Hospital Calixto García\nDirección: esquina J y 27, Vedado, Plaza de la Revolución.'),
              const SizedBox(height: 10),
              const Text('Confirma horarios y disponibilidad antes de trasladarte. Si existe peligro inmediato, busca acompañamiento y acude al servicio de urgencias más cercano.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ] else ...[
              const Text(
                'No disponemos en esta aplicación de un directorio local verificado para tu territorio. Puedes hablar con una persona de confianza, contactar a un profesional de salud o acudir a tu policlínico u hospital más cercano. Si sientes que podrías hacerte daño ahora, busca compañía inmediata y acude a urgencias.',
                style: TextStyle(fontSize: 14, height: 1.45),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _itemResultado(String titulo, double valor) {
    return ListTile(
      dense: true,
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(valor.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
