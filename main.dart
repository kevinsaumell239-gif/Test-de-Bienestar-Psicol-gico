import 'package:flutter/material.dart';

void main() {
  runApp(const TestPsicologicoApp());
}

class TestPsicologicoApp extends StatelessWidget {
  const TestPsicologicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test de Bienestar Emocional y Social',
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

// --- LÓGICA DE NEGOCIO (MODELOS) ---

class Resultados {
  final double esferaA, esferaB, esferaC, esferaD, promedio;
  final String diagnostico;
  Resultados(this.esferaA, this.esferaB, this.esferaC, this.esferaD, this.promedio, this.diagnostico);
}

// --- PANTALLA 1: BIENVENIDA ---

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade50],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology_alt, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "Evaluación de Bienestar Emocional y Social",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                "Este test ayudará a comprender tu estado emocional actual. Responde con sinceridad.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaTest()),
              ),
              child: const Text("Comenzar Test", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA 2: EL TEST ---

class PantallaTest extends StatefulWidget {
  const PantallaTest({super.key});

  @override
  State<PantallaTest> createState() => _PantallaTestState();
}

class _PantallaTestState extends State<PantallaTest> {
  int indicePregunta = 0;
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
    "Encuentro formas creativas de resolver mis necesidades a pesar de las limitaciones de servicios (agua, electricidad, etc.).",
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

  final List<String> escalaTexto = ["Nunca", "Rara vez", "A veces", "Frecuentemente", "Siempre"];

  @override
  void initState() {
    super.initState();
    respuestas = List.filled(preguntas.length, 0);
  }

  void responder(int valor) {
    setState(() {
      respuestas[indicePregunta] = valor;
      if (indicePregunta < preguntas.length - 1) {
        indicePregunta++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PantallaResultados(respuestas: respuestas)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double progreso = (indicePregunta + 1) / preguntas.length;

    return Scaffold(
      appBar: AppBar(
        title: Text("Pregunta ${indicePregunta + 1}/${preguntas.length}"),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progreso, minHeight: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Text(
                        preguntas[indicePregunta],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text("¿Con qué frecuencia esto ocurre?", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ...List.generate(5, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.blue.shade200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => responder(index + 1),
                          child: Text(escalaTexto[index], style: const TextStyle(fontSize: 16)),
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
    );
  }
}

// --- PANTALLA 3: RESULTADOS ---

class PantallaResultados extends StatelessWidget {
  final List<int> respuestas;
  const PantallaResultados({super.key, required this.respuestas});

  @override
  Widget build(BuildContext context) {
    double sA = (respuestas[0] + respuestas[1] + respuestas[2] + respuestas[3] + respuestas[4]).toDouble();
    double sB = (respuestas[5] + respuestas[6] + respuestas[7] + respuestas[8] + respuestas[9]).toDouble();
    double sC = (respuestas[10] + respuestas[11] + respuestas[12] + respuestas[13] + respuestas[14]).toDouble();
    double sD = (respuestas[15] + respuestas[16] + respuestas[17] + respuestas[18] + respuestas[19]).toDouble();

    double promedio = (sA + sB + sC + sD) / 20;

    String diag = "";
    Color colorDiag = Colors.green;
    if (promedio < 2.5) {
      diag = "Requiere atención inmediata. Se observa baja resiliencia.";
      colorDiag = Colors.red;
    } else if (promedio < 3.8) {
      diag = "Nivel moderado. Se recomienda fortalecer redes de apoyo.";
      colorDiag = Colors.orange;
    } else {
      diag = "¡Excelente! Posees una alta capacidad de adaptación.";
      colorDiag = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Resultados")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.assignment_turned_in, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text("Tu Promedio: ${promedio.toStringAsFixed(2)}", 
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorDiag.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: colorDiag),
              ),
              child: Text(diag, 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: colorDiag, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            const Text("Desglose por Esferas:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _itemResultado("Bienestar Emocional", sA),
            _itemResultado("Apoyo Social", sB),
            _itemResultado("Adaptación al Contexto", sC),
            _itemResultado("Proyección Futuro", sD),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const PantallaBienvenida()),
              ),
              child: const Text("Reiniciar Test"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemResultado(String titulo, double valor) {
    return ListTile(
      title: Text(titulo),
      trailing: Text(valor.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
