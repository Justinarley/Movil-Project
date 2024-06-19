import 'package:control/ahorro.dart';
import 'package:control/historial.dart';
import 'package:control/inicio.dart';
import 'package:control/paginaPrincipal.dart';
import 'package:control/perfil.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(DashboardApp());
}

class DashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final String usuarioId = 'J4PAHsiqSygRJYkhfrX8'; // Aquí deberías obtener el usuarioId de manera dinámica

  @override
  Widget build(BuildContext context) {
    // Simulación de datos quemados para el dashboard
    double totalComida = 350.0;
    double totalPasajes = 150.0;
    double totalViajes = 200.0;
    double totalGastosDiarios = 100.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PerfilUsuario()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('usuario'); // Limpiar el nombre de usuario al cerrar sesión
              await prefs.remove('usuarioId'); // Limpiar el ID de usuario al cerrar sesión
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PaginaPrincipal()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InicioApp()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Ahorros'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AhorroApp()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardApp()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Historial(usuarioId: '',)),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFF0D1B2A),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.only(bottom: 16.0),
                child: CardRow(
                  totalComida: totalComida,
                  totalPasajes: totalPasajes,
                  totalViajes: totalViajes,
                  totalGastosDiarios: totalGastosDiarios,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 8.0),
                      child: DashboardCard(title: 'Gastos Fijos', value: '250.00', color: Colors.blue),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 8.0),
                      child: DashboardCard(title: 'Gastos Variables', value: '300.00', color: Colors.green),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: DashboardCard(title: 'Ahorros', value: '500.00', color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                child: LineChartSample1(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardRow extends StatelessWidget {
  final double totalComida;
  final double totalPasajes;
  final double totalViajes;
  final double totalGastosDiarios;

  const CardRow({
    required this.totalComida,
    required this.totalPasajes,
    required this.totalViajes,
    required this.totalGastosDiarios,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: DashboardCard(title: 'Comida', value: totalComida.toStringAsFixed(2)),
        ),
        Expanded(
          child: DashboardCard(title: 'Pasajes', value: totalPasajes.toStringAsFixed(2)),
        ),
        Expanded(
          child: DashboardCard(title: 'Viajes', value: totalViajes.toStringAsFixed(2)),
        ),
        Expanded(
          child: DashboardCard(title: 'Gastos diarios', value: totalGastosDiarios.toStringAsFixed(2)),
        ),
      ],
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const DashboardCard({required this.title, required this.value, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '\$$value',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class LineChartSample1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 3),
              FlSpot(1, 4),
              FlSpot(2, 3.5),
              FlSpot(3, 5),
              FlSpot(4, 4),
              FlSpot(5, 6),
            ],
            isCurved: true,
            colors: [Colors.blue],
            barWidth: 4,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (value) {
              return 'Día ${value.toInt() + 1}';
            },
          ),
          leftTitles: SideTitles(showTitles: true),
        ),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
