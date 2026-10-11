import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// 🔴 COLOCA AQUÍ TU ENLACE DE GOOGLE APPS SCRIPT
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
                  const Text(
                    "Test de Bienestar",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                  ),
                  const Text(
                    "(EBES-JC)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Este test ayudará a comprender tu estado emocional actual. Responde con sinceridad.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 25),

                  // FORMULARIO
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Nombre (Opcional)",
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            onSaved: (val) => datos.nombre = val?.trim() ?? '',
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Edad (15 - 25 años) *",
                              prefixIcon: Icon(Icons.cake_outlined),
                            ),
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
                            decoration: const InputDecoration(
                              labelText: "Sexo *",
                              prefixIcon: Icon(Icons.wc_outlined),
                            ),
                            items: opcionesSexo.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            validator: (val) => val == null ? "Seleccione sexo" : null,
                            onChanged: (val) => datos.sexo = val ?? '',
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Provincia *",
                              prefixIcon: Icon(Icons.map_outlined),
                            ),
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
                            decoration: const InputDecoration(
                              labelText: "Municipio *",
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
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
                            decoration: const InputDecoration(
                              labelText: "Grupo o Escuela (Opcional)",
                              prefixIcon: Icon(Icons.school_outlined),
                            ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PantallaTest(datos: datos)),
                        );
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

// --- PANTALLA 2: EL TEST (20 PREGUNTAS) ---
class PantallaTest extends StatefulWidget {
  final DatosUsuario datos;
  const PantallaTest({super.key, required this.datos});

  @override
  State<PantallaTest> createState() => _PantallaTestState();
}

class _PantallaTestState extends State<PantallaTest> {
  int indice = 0;
  List<int> respuestas = [];

  final List<String> preguntas = [
    "Logro mantener la calma y la estabilidad emocional ante los cambios imprevistos del día.",
    "Me siento capaz de gestionar mis emociones de manera constructiva cuando surgen conflictos.",
    "Disfruto de actividades cotidianas que me brindan una sensación de paz y satisfacción.",
    "Mantengo un interés activo y entusiasta por las actividades que realizo.",
    "Poseo la capacidad de recuperar mi equilibrio emocional tras un momento de tensión.",
    "Siento que cuento con una red de amigos o familiares que me comprenden profundamente.",
    "Mis relaciones interpersonales me hacen sentir parte de un grupo o comunidad.",
    "Tengo personas de confianza en quienes puedo apoyarme ante cualquier dificultad.",
    "Siento que mi familia me brinda un ambiente de aceptación.",
    "Mis amigos me motivan a ser una mejor persona.",
    "Encuentro formas creativas de resolver mis necesidades a pesar de las limitaciones de servicios (agua, luz, etc.).",
    "Me siento capaz de organizar mis estudios o proyectos aun con las dificultades del entorno.",
    "Soy capaz de administrar mis recursos (dinero, comida, tiempo) con éxito.",
    "Puedo ajustar mis planes cuando surgen imprevistos en los servicios.",
    "Me siento capaz de lidiar con la incertidumbre del día a día.",
    "Tengo metas claras que me motivan a seguir adelante cada día.",
    "Me siento con la energía necesaria para trabajar por el futuro que deseo construir.",
    "Siento que mis esfuerzos actuales tienen un propósito valioso para mi futuro.",
    "Creo que mi esfuerzo actual dará frutos en el futuro.",
    "Veo un camino posible para alcanzar la estabilidad que deseo.",
  ];

  final List<String> opciones = ["Nunca", "Rara vez", "A veces", "Frecuentemente", "Siempre"];

  @override
  void initState() {
    super.initState();
    respuestas = List.filled(preguntas.length, 0);
  }

  void responder(int valor) {
    setState(() {
      respuestas[indice] = valor;
      if (indice < preguntas.length - 1) {
        indice++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PantallaResultados(datos: widget.datos, respuestas: respuestas)),
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
    double progreso = (indice + 1) / preguntas.length;

    return PopScope(
      canPop: indice == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && indice > 0) retroceder();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Pregunta ${indice + 1}/${preguntas.length}"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: retroceder,
          ),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(value: progreso, minHeight: 8),
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
                          preguntas[indice],
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
                      final seleccionada = respuestas[indice] == valorOpcion;

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

// --- PANTALLA 3: RESULTADOS, GOOGLE SHEETS & COMPARTIR ---
class PantallaResultados extends StatefulWidget {
  final DatosUsuario datos;
  final List<int> respuestas;

  const PantallaResultados({super.key, required this.datos, required this.respuestas});

  @override
  State<PantallaResultados> createState() => _PantallaResultadosState();
}

class _PantallaResultadosState extends State<PantallaResultados> {
  late double sA, sB, sC, sD, promedio;
  late String diag;
  late Color colorDiag;

  @override
  void initState() {
    super.initState();
    // Cálculo de esferas
    sA = widget.respuestas.sublist(0, 5).reduce((a, b) => a + b).toDouble();
    sB = widget.respuestas.sublist(5, 10).reduce((a, b) => a + b).toDouble();
    sC = widget.respuestas.sublist(10, 15).reduce((a, b) => a + b).toDouble();
    sD = widget.respuestas.sublist(15, 20).reduce((a, b) => a + b).toDouble();
    promedio = (sA + sB + sC + sD) / 20;

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

    _enviarAGoogleSheets();
  }

  // Envío a Google Sheets en segundo plano
  Future<void> _enviarAGoogleSheets() async {
    if (webhookGoogle.contains("TU_SCRIPT")) return;
    try {
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
        "esferaA": sA.toStringAsFixed(1),
        "esferaB": sB.toStringAsFixed(1),
        "esferaC": sC.toStringAsFixed(1),
        "esferaD": sD.toStringAsFixed(1),
        "respuestas": widget.respuestas.join(", ")
      };

      await http.post(
        Uri.parse(webhookGoogle),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
    } catch (_) {}
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
• Bienestar Emocional (A): ${sA.toStringAsFixed(1)}/25
• Apoyo Social (B): ${sB.toStringAsFixed(1)}/25
• Adaptación al Contexto (C): ${sC.toStringAsFixed(1)}/25
• Proyección Futuro (D): ${sD.toStringAsFixed(1)}/25''';
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
      appBar: AppBar(title: const Text("Resultados")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.assignment_turned_in, size: 75, color: Color(0xFF4A90E2)),
            const SizedBox(height: 15),
            Text(
              "Tu Promedio: ${promedio.toStringAsFixed(2)}",
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
            _itemResultado("Bienestar Emocional", sA),
            _itemResultado("Apoyo Social", sB),
            _itemResultado("Adaptación al Contexto", sC),
            _itemResultado("Proyección Futuro", sD),
            const SizedBox(height: 25),

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

            // AVISO LEGAL
            const Text(
              "Si duda sobre su resultado converse con un profesional de la salud mental. El resultado es orientativo y no constituye un diagnóstico.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
      trailing: Text(valor.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
