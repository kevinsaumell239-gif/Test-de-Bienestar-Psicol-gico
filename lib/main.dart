import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// URL de tu Apps Script vinculado a Google Sheets
const String webhookGoogle = "https://script.google.com/macros/s/AKfycbw1ah4mIX7pOgdyj7t0mVTMBWULACaMh3PNIl4-2qs8VteWobQN5061DhvqAA1HijtDcA/exec";

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

// --- DATOS GEOGRÁFICOS DE CUBA ---
final Map<String, List<String>> cubaGeo = {
  "Pinar del Río": ["Consolación del Sur", "Guane", "La Palma", "Los Palacios", "Mantua", "Minas de Matahambre", "Pinar del Río", "San Juan y Martínez", "San Luis", "Sandino", "Viñales"],
  "Artemisa": ["Alquízar", "Artemisa", "Bauta", "Caimito", "Guanajay", "Güira de Melena", "Mariel", "San Antonio de los Baños", "Bahía Honda", "San Cristóbal", "Candelaria"],
  "La Habana": ["Arroyo Naranjo", "Boyeros", "Centro Habana", "Cerro", "Cotorro", "Diez de Octubre", "Guanabacoa", "La Habana del Este", "La Habana Vieja", "La Lisa", "Marianao", "Playa", "Plaza de la Revolución", "Regla", "San Miguel del Padrón"],
  "Mayabeque": ["Batabanó", "Bejucal", "Güines", "Jaruco", "Madruga", "Melena del Sur", "Nueva Paz", "Quivicán", "San José de las Lajas", "San Nicolás", "Santa Cruz del Norte"],
  "Matanzas": ["Calimete", "Cárdenas", "Ciénaga de Zapata", "Colón", "Jagüey Grande", "Jovellanos", "Limonar", "Los Arabos", "Martí", "Matanzas", "Pedro Betancourt", "Perico", "Unión de Reyes"],
  "Cienfuegos": ["Abreus", "Aguada de Pasajeros", "Cruces", "Cumanayagua", "Lajas", "Palmira", "Rodas", "Cienfuegos"],
  "Villa Clara": ["Caibarién", "Camajuaní", "Cifuentes", "Corralillo", "Encrucijada", "Manicaragua", "Placetas", "Quemado de Güines", "Ranchuelo", "San Juan de los Remedios", "Sagua la Grande", "Santa Clara", "Santo Domingo"],
  "Sancti Spíritus": ["Cabaiguán", "Fomento", "Jatibonico", "La Sierpe", "Sancti Spíritus", "Taguasco", "Trinidad", "Yaguajay"],
  "Ciego de Ávila": ["Baraguá", "Bolivia", "Chambas", "Ciego de Ávila", "Ciro Redondo", "Florencia", "Majagua", "Morón", "Primero de Enero", "Venezuela"],
  "Camagüey": ["Camagüey", "Carlos Manuel de Céspedes", "Esmeralda", "Florida", "Guáimaro", "Jimaguayú", "Minas", "Najasa", "Nuevitas", "Santa Cruz del Sur", "Sibanicú", "Sierra de Cubitas", "Vertientes"],
  "Las Tunas": ["Amancio", "Colombia", "Jesús Menéndez", "Jobabo", "Majibacoa", "Manatí", "Puerto Padre", "Las Tunas"],
  "Holguín": ["Antilla", "Báguanos", "Banes", "Cacocum", "Calixto García", "Cueto", "Frank País", "Gibara", "Holguín", "Mayarí", "Moa", "Rafael Freyre", "Sagua de Tánamo", "Urbano Noris"],
  "Granma": ["Bartolomé Masó", "Bayamo", "Buey Arriba", "Campechuela", "Cauto Cristo", "Guisa", "Jiguaní", "Manzanillo", "Media Luna", "Niquero", "Pilón", "Río Cauto", "Yara"],
  "Santiago de Cuba": ["Contramaestre", "Guamá", "Mella", "Palma Soriano", "San Luis", "Santiago de Cuba", "Segundo Frente", "Songo - La Maya", "Tercer Frente"],
  "Guantánamo": ["Baracoa", "Caimanera", "El Salvador", "Guantánamo", "Imías", "Maisí", "Manuel Tames", "Niceto Pérez", "San Antonio del Sur", "Yateras"],
  "Municipio Especial Isla de la Juventud": ["Isla de la Juventud"]
};

// --- MODELO DE DATOS ---
class DatosUsuario {
  String nombre;
  int edad;
  String sexo;
  String provincia;
  String municipio;
  String grupo;

  DatosUsuario({
    this.nombre = '',
    this.edad = 15,
    this.sexo = '',
    this.provincia = '',
    this.municipio = '',
    this.grupo = '',
  });
}

// --- ESTRUCTURA DE ÍTEMS (32 + SEGURIDAD) ---
class ItemTest {
  final String codigo;
  final String texto;
  final bool invertido;

  const ItemTest(this.codigo, this.texto, {this.invertido = false});
}

const List<ItemTest> itemsPuntuables = [
  // Esfera A: Bienestar emocional (8 ítems)
  ItemTest('A1', 'Cuando algo imprevisto me altera, logro recuperar la calma en poco tiempo.'),
  ItemTest('A2', 'Cuando tengo un conflicto con otra persona, logro controlar lo que siento.'),
  ItemTest('A3', 'Mis cambios de humor me resultan difíciles de controlar.', invertido: true),
  ItemTest('A4', 'Después de un momento de tensión, me cuesta volver a sentirme bien.', invertido: true),
  ItemTest('A5', 'Disfruto de las cosas que hago en mi día a día.'),
  ItemTest('A6', 'Me siento en paz conmigo mismo/a.'),
  ItemTest('A7', 'Tengo claro lo que siento.'),
  ItemTest('A8', 'Me siento satisfecho/a con la persona en la que me estoy convirtiendo.'),

  // Esfera B: Apoyo social (8 ítems)
  ItemTest('B1', 'Tengo al menos una persona que me entiende de verdad.'),
  ItemTest('B2', 'Cuando necesito ayuda, hay alguien a quien puedo acudir.'),
  ItemTest('B3', 'Puedo hablar de lo que siento con alguien de mi entorno.'),
  ItemTest('B4', 'En mi familia me siento aceptado/a como soy.'),
  ItemTest('B5', 'Me siento parte de al menos un grupo (amistades, estudio, trabajo o comunidad).'),
  ItemTest('B6', 'Siento que las personas cercanas me valoran.'),
  ItemTest('B7', 'Me siento solo/a aunque esté rodeado/a de gente.', invertido: true),
  ItemTest('B8', 'Cuando tengo un problema serio, siento que debo resolverlo completamente solo/a.', invertido: true),

  // Esfera C: Adaptación al contexto (8 ítems)
  ItemTest('C1', 'Cuando fallan los servicios básicos (agua, electricidad, transporte), encuentro alguna manera de seguir con mis actividades.'),
  ItemTest('C2', 'Cuando surgen imprevistos, puedo cambiar mis planes sin sentirme desbordado/a.'),
  ItemTest('C3', 'Logro mantener una rutina diaria a pesar de la incertidumbre.'),
  ItemTest('C4', 'Cuando mis recursos son limitados, busco alternativas para resolver lo que necesito.'),
  ItemTest('C5', 'Sigo adelante con mis estudios o trabajo aunque haya interrupciones.'),
  ItemTest('C6', 'Aprendo cosas nuevas que me ayudan a enfrentar las exigencias actuales.'),
  ItemTest('C7', 'La incertidumbre del día a día me paraliza.', invertido: true),
  ItemTest('C8', 'Las dificultades de mi entorno me hacen sentir que no puedo hacer nada por mejorar mi situación.', invertido: true),

  // Esfera D: Proyección de futuro (8 ítems)
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

const List<String> opciones = ["Nunca", "Rara vez", "A veces", "Frecuentemente", "Siempre"];

// --- PANTALLA 1: BIENVENIDA Y DATOS SOCIODEMOGRÁFICOS ---
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

  final List<String> opcionesSexo = ["Femenino", "Masculino"];

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
                  const Text("Test de Bienestar", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const Text("(EBES-JC)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 15),
                  const Text("Este test ayudará a comprender tu estado emocional actual. Responde con sinceridad.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.black87)),
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
                            decoration: const InputDecoration(labelText: "Nombre (Opcional)", prefixIcon: Icon(Icons.person_outline)),
                            onSaved: (val) => datos.nombre = val?.trim() ?? '',
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: const InputDecoration(labelText: "Edad (15 - 25 años) *", prefixIcon: Icon(Icons.cake_outlined)),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) return "Indique su edad";
                              final n = int.tryParse(val);
                              if (n == null || n < 15 || n > 25) return "Rango válido: 15 a 25 años";
                              return null;
                            },
                            onSaved: (val) => datos.edad = int.parse(val!),
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: "Sexo *", prefixIcon: Icon(Icons.wc_outlined)),
                            items: opcionesSexo.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            validator: (val) => val == null ? "Seleccione sexo" : null,
                            onChanged: (val) => datos.sexo = val ?? '',
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: "Provincia *", prefixIcon: Icon(Icons.map_outlined)),
                            value: provinciaSeleccionada,
                            items: cubaGeo.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                            validator: (val) => val == null ? "Seleccione provincia" : null,
                            onChanged: (val) {
                              setState(() {
                                provinciaSeleccionada = val;
                                datos.provincia = val ?? '';
                                municipiosDisponibles = cubaGeo[val] ?? [];
                                municipioSeleccionado = null;
                                datos.municipio = '';
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: "Municipio *", prefixIcon: Icon(Icons.location_city_outlined)),
                            value: municipioSeleccionado,
                            items: municipiosDisponibles.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                            validator: (val) => val == null ? "Seleccione municipio" : null,
                            onChanged: (val) {
                              setState(() {
                                municipioSeleccionado = val;
                                datos.municipio = val ?? '';
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: const InputDecoration(labelText: "Grupo o Escuela (Opcional)", prefixIcon: Icon(Icons.school_outlined)),
                            onSaved: (val) => datos.grupo = val?.trim() ?? '',
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaTest(datos: datos)));
                      }
                    },
                    child: const Text("Comenzar Test", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

// --- PANTALLA 2: EL TEST (32 ÍTEMS + 2 DE SEGURIDAD) ---
class PantallaTest extends StatefulWidget {
  final DatosUsuario datos;
  const PantallaTest({super.key, required this.datos});

  @override
  State<PantallaTest> createState() => _PantallaTestState();
}

class _PantallaTestState extends State<PantallaTest> {
  int indice = 0;
  List<int> respuestasPuntuables = [];
  List<int> respuestasSeguridad = [];

  @override
  void initState() {
    super.initState();
    respuestasPuntuables = List.filled(itemsPuntuables.length, 0);
    respuestasSeguridad = List.filled(itemsSeguridad.length, 0);
  }

  bool get esModuloSeguridad => indice >= itemsPuntuables.length;

  ItemTest get itemActual {
    if (!esModuloSeguridad) {
      return itemsPuntuables[indice];
    } else {
      return itemsSeguridad[indice - itemsPuntuables.length];
    }
  }

  int get respuestaActual {
    if (!esModuloSeguridad) {
      return respuestasPuntuables[indice];
    } else {
      return respuestasSeguridad[indice - itemsPuntuables.length];
    }
  }

  void responder(int valor) {
    setState(() {
      if (!esModuloSeguridad) {
        respuestasPuntuables[indice] = valor;
      } else {
        respuestasSeguridad[indice - itemsPuntuables.length] = valor;
      }

      int totalItems = itemsPuntuables.length + itemsSeguridad.length;
      if (indice < totalItems - 1) {
        indice++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaResultados(
              datos: widget.datos,
              respuestas: respuestasPuntuables,
              respuestasSeguridad: respuestasSeguridad,
            ),
          ),
        );
      }
    });
  }

  void retroceder() {
    if (indice > 0) {
      setState(() => indice--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = itemsPuntuables.length + itemsSeguridad.length;
    double progreso = (indice + 1) / totalItems;

    return PopScope(
      canPop: indice == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && indice > 0) retroceder();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(esModuloSeguridad 
            ? "Módulo de Apoyo (${indice - itemsPuntuables.length + 1}/${itemsSeguridad.length})" 
            : "Pregunta ${indice + 1}/${itemsPuntuables.length}"),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: retroceder),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(value: progreso, minHeight: 8),
            if (esModuloSeguridad)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.amber.shade100,
                child: const Text(
                  "Estas dos preguntas son de bienestar y seguridad general, no puntúan para el test.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                        child: Text(
                          itemActual.texto,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text("¿Con qué frecuencia ocurre esto?", style: TextStyle(color: Colors.grey, fontSize: 15)),
                    const SizedBox(height: 15),
                    ...List.generate(5, (i) {
                      final valorOpcion = i + 1;
                      final seleccionada = respuestaActual == valorOpcion;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: seleccionada ? Colors.blue.shade100 : null,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: seleccionada ? const Color(0xFF4A90E2) : Colors.blue.shade200,
                                width: seleccionada ? 2.0 : 1.0,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => responder(valorOpcion),
                            child: Text(
                              opciones[i],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: seleccionada ? FontWeight.bold : FontWeight.normal,
                                color: seleccionada ? Colors.blue.shade900 : null,
                              ),
                            ),
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

// --- PANTALLA 3: RESULTADOS, TELEMETRÍA Y APOYO ---
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
  late String diag;
  late Color colorDiag;
  late bool alertaCritica;

  @override
  void initState() {
    super.initState();

    // 1. Aplicar inversión de polaridad (6 - r) para los ítems invertidos (R)
    List<int> respuestasProcesadas = [];
    for (int i = 0; i < widget.respuestas.length; i++) {
      int r = widget.respuestas[i];
      bool invertido = itemsPuntuables[i].invertido;
      respuestasProcesadas.add(invertido ? 6 - r : r);
    }

    // 2. Cálculo de esferas (8 ítems por esfera, normalizadas de 1.0 a 5.0)
    sA = respuestasProcesadas.sublist(0, 8).reduce((a, b) => a + b) / 8.0;
    sB = respuestasProcesadas.sublist(8, 16).reduce((a, b) => a + b) / 8.0;
    sC = respuestasProcesadas.sublist(16, 24).reduce((a, b) => a + b) / 8.0;
    sD = respuestasProcesadas.sublist(24, 32).reduce((a, b) => a + b) / 8.0;

    // 3. Promedio global (32 ítems / 4 esferas)
    promedio = (sA + sB + sC + sD) / 4.0;

    if (promedio < 2.5) {
      diag = "Requiere atención inmediata. Se observa bajo bienestar.";
      colorDiag = Colors.red;
    } else if (promedio < 3.8) {
      diag = "Nivel moderado. Se recomienda fortalecer con redes de apoyo.";
      colorDiag = Colors.orange;
    } else {
      diag = "¡Excelente! Posees un alto nivel de bienestar.";
      colorDiag = Colors.green;
    }

    // 4. Lógica de alerta del Módulo Centinela (S1 >= 3 o S2 > 1)
    int s1 = widget.respuestasSeguridad[0];
    int s2 = widget.respuestasSeguridad[1];
    alertaCritica = (s1 >= 3) || (s2 > 1);

    _enviarAGoogleSheets();
  }

  // Envío a Google Sheets adaptado y compatible con tu script original
  Future<void> _enviarAGoogleSheets() async {
    if (webhookGoogle.contains("TU_SCRIPT")) return;
    try {
      final uri = Uri.parse(webhookGoogle);

      List<int> respuestasProcesadas = [];
      for (int i = 0; i < widget.respuestas.length; i++) {
        int r = widget.respuestas[i];
        respuestasProcesadas.add(itemsPuntuables[i].invertido ? 6 - r : r);
      }

      final List<int> vectorCompleto = [
        ...respuestasProcesadas,
        ...widget.respuestasSeguridad
      ];

      final body = {
        "fecha": DateTime.now().toLocal().toString().split('.')[0],
        "nombre": widget.datos.nombre.isEmpty ? "No proporcionado" : widget.datos.nombre,
        "edad": widget.datos.edad,
        "sexo": widget.datos.sexo,
        "provincia": widget.datos.provincia,
        "municipio": widget.datos.municipio,
        "grupo": widget.datos.grupo.isEmpty ? "N/A" : widget.datos.grupo,
        "promedio": promedio.toStringAsFixed(2),
        "diagnostico": diag,
        "esferaA": sA.toStringAsFixed(2),
        "esferaB": sB.toStringAsFixed(2),
        "esferaC": sC.toStringAsFixed(2),
        "esferaD": sD.toStringAsFixed(2),
        "respuestas": vectorCompleto.join(", ")
      };

      await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
    } catch (e) {
      debugPrint("Error al enviar telemetría: $e");
    }
  }

  String _generarMensajeCompartir() {
    return '''📊 RESULTADOS TEST DE BIENESTAR (EBES-JC)
👤 Nombre: ${widget.datos.nombre.isEmpty ? 'Anónimo' : widget.datos.nombre}
🎂 Edad: ${widget.datos.edad} años | Sexo: ${widget.datos.sexo}
📍 Ubicación: ${widget.datos.municipio}, ${widget.datos.provincia}
🏫 Grupo/Escuela: ${widget.datos.grupo.isEmpty ? 'N/A' : widget.datos.grupo}
⭐ Promedio: ${promedio.toStringAsFixed(2)} / 5.0
📋 Diagnóstico: $diag

📈 Desglose por Esferas:
• Bienestar Emocional (A): ${sA.toStringAsFixed(2)} / 5.0
• Apoyo Social (B): ${sB.toStringAsFixed(2)} / 5.0
• Adaptación al Contexto (C): ${sC.toStringAsFixed(2)} / 5.0
• Proyección Futuro (D): ${sD.toStringAsFixed(2)} / 5.0''';
  }

  Future<void> _compartirWhatsApp() async {
    final msg = Uri.encodeComponent(_generarMensajeCompartir());
    final url = Uri.parse("https://api.whatsapp.com/send?text=$msg");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _compartirTelegram() async {
    final msg = Uri.encodeComponent(_generarMensajeCompartir());
    final url = Uri.parse("https://t.me/share/url?url=&text=$msg");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resultados Oficiales")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.assignment_turned_in, size: 75, color: Color(0xFF4A90E2)),
            const SizedBox(height: 15),
            Text(
              "Tu Promedio: ${promedio.toStringAsFixed(2)} / 5.0",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorDiag.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorDiag, width: 1.5),
              ),
              child: Text(
                diag,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: colorDiag, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Desglose por Esferas:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            _itemResultado("Bienestar Emocional (A)", sA),
            _itemResultado("Apoyo Social (B)", sB),
            _itemResultado("Adaptación al Contexto (C)", sC),
            _itemResultado("Proyección Futuro (D)", sD),
            const SizedBox(height: 20),

            // PANEL DE ALERTA CENTINELA SI SE ACTIVA S1 o S2
            if (alertaCritica) ...[
              Card(
                color: Colors.amber.shade50,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.amber, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.support_agent, color: Colors.deepOrange),
                          SizedBox(width: 8),
                          Text("No estás solo / No estás sola", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Gracias por responder con honestidad. Las respuestas indican que podrías estar atravesando por un momento difícil. No estás siendo juzgado/a y esta app no emite diagnósticos. Te animamos a hablar con una persona de confianza o con un profesional.",
                        style: TextStyle(fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      if (widget.datos.provincia == "La Habana") ...[
                        const Text("Recursos locales en La Habana:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 6),
                        const Text("• CEBPSI Centro de Bienestar Psicológico\nDirección: calle 19 entre calle L y calle K, Vedado, Plaza de La Revolución."),
                        const SizedBox(height: 4),
                        const Text("• Servicio de Psiquiatría Hospital Calixto García\nDirección: esquina J y 27, Vedado, Plaza de La Revolución."),
                      ] else ...[
                        const Text(
                          "Te sugerimos acudir al policlínico u hospital más cercano de tu localidad o contactar con los servicios de salud mental territoriales.",
                          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // BOTONES PARA COMPARTIR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.chat),
                label: const Text("Compartir por WhatsApp", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _compartirWhatsApp,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0088CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.send),
                label: const Text("Compartir por Telegram", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _compartirTelegram,
              ),
            ),

            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PantallaBienvenida()),
              ),
              child: const Text("Reiniciar Test"),
            ),
            const SizedBox(height: 20),

            const Text(
              "Si duda sobre su resultado converse con un profesional de la salud mental. El resultado es orientativo y no constituye un diagnóstico.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemResultado(String titulo, double valor) {
    return ListTile(
      dense: true,
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text("${valor.toStringAsFixed(2)} / 5.0", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
