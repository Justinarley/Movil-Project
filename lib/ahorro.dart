import 'package:control/dashboard.dart';
import 'package:control/firebase_service.dart';
import 'package:control/historial.dart';
import 'package:control/inicio.dart';
import 'package:control/paginaPrincipal.dart';
import 'package:control/perfil.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Gasto {
  final String nombre;
  final double cantidad;
  final String tipo;
  final String descripcion;
  final double valor;

  Gasto({
    required this.nombre,
    required this.cantidad,
    required this.tipo,
    required this.descripcion,
    required this.valor,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cantidad': cantidad,
      'tipo': tipo,
      'descripcion': descripcion,
      'valor': valor,
    };
  }
}

class AhorroApp extends StatefulWidget {
  @override
  _AhorroAppState createState() => _AhorroAppState();
}

class _AhorroAppState extends State<AhorroApp> {
  final TextEditingController _saldoMensualController = TextEditingController();
  final TextEditingController _gastoFijoDescripcionController = TextEditingController();
  final TextEditingController _gastoFijoValorController = TextEditingController();
  final TextEditingController _gastoVariableDescripcionController = TextEditingController();
  final TextEditingController _gastoVariableValorController = TextEditingController();
  final TextEditingController _ahorroDescripcionController = TextEditingController();
  final TextEditingController _ahorroValorController = TextEditingController();

  double saldoMensual = 0;
  double gastosFijos = 0;
  double gastosVariables = 0;
  double ahorros = 0;

  List<Gasto> gastosFijosList = [];
  List<Gasto> gastosVariablesList = [];
  List<Gasto> ahorrosList = [];

  final String _usuarioId = 'J4PAHsiqSygRJYkhfrX8'; // Aquí deberías obtener el ID del usuario actual

  final FirebaseService _firebaseService = FirebaseService();

  Future<void> agregarGasto(Gasto gasto) async {
    try {
      switch (gasto.tipo) {
        case 'fijo':
          gastosFijosList.add(gasto);
          break;
        case 'variable':
          gastosVariablesList.add(gasto);
          break;
        case 'ahorro':
          ahorrosList.add(gasto);
          break;
        default:
          throw Exception('Tipo de gasto no reconocido: ${gasto.tipo}');
      }

      await _firebaseService.crearGasto(_usuarioId, gasto.toMap());

      setState(() {
        switch (gasto.tipo) {
          case 'fijo':
            gastosFijos += gasto.valor;
            _gastoFijoDescripcionController.clear();
            _gastoFijoValorController.clear();
            break;
          case 'variable':
            gastosVariables += gasto.valor;
            _gastoVariableDescripcionController.clear();
            _gastoVariableValorController.clear();
            break;
          case 'ahorro':
            ahorros += gasto.valor;
            _ahorroDescripcionController.clear();
            _ahorroValorController.clear();
            break;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gasto agregado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar gasto: $e')),
      );
    }
  }

  void handleAgregarGasto(String tipo) {
    double cantidad = 0;
    TextEditingController descripcionController = TextEditingController();
    TextEditingController valorController = TextEditingController();

    switch (tipo) {
      case 'fijo':
        cantidad = double.tryParse(_gastoFijoValorController.text) ?? 0;
        descripcionController = _gastoFijoDescripcionController;
        valorController = _gastoFijoValorController;
        break;
      case 'variable':
        cantidad = double.tryParse(_gastoVariableValorController.text) ?? 0;
        descripcionController = _gastoVariableDescripcionController;
        valorController = _gastoVariableValorController;
        break;
      case 'ahorro':
        cantidad = double.tryParse(_ahorroValorController.text) ?? 0;
        descripcionController = _ahorroDescripcionController;
        valorController = _ahorroValorController;
        break;
    }

    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El valor debe ser mayor que cero')),
      );
      return;
    }

    if (cantidad > saldoMensual) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("¡Tu saldo mensual no es suficiente para este gasto!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final nuevoGasto = Gasto(
      nombre: tipo,
      cantidad: cantidad,
      tipo: tipo,
      descripcion: descripcionController.text,
      valor: double.parse(valorController.text),
    );

    agregarGasto(nuevoGasto);
  }

  void actualizarSaldoMensual() {
    setState(() {
      saldoMensual = double.tryParse(_saldoMensualController.text) ?? 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saldo mensual actualizado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ahorro App'),
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
                MaterialPageRoute(
                    builder: (context) => const PaginaPrincipal()),
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
                    MaterialPageRoute(builder: (context) => Historial(usuarioId:'')),
                  );
                },
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B0C10),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: const Color(0xFF1F2833),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ahorro App',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _saldoMensualController,
                                  decoration: InputDecoration(
                                    labelText: 'Saldo Mensual',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  actualizarSaldoMensual();
                                },
                                child: Text('Actualizar'),
                                style: ElevatedButton.styleFrom(
                                  textStyle: TextStyle(color: Colors.white), 
                                  backgroundColor: Color.fromARGB(255, 74, 168, 244),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _gastoFijoDescripcionController,
                                  decoration: InputDecoration(
                                    labelText: 'Descripción Gasto Fijo',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _gastoFijoValorController,
                                  decoration: InputDecoration(
                                    labelText: 'Valor Gasto Fijo',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  handleAgregarGasto('fijo');
                                },
                                child: Text('Agregar'),
                                style: ElevatedButton.styleFrom(
                                  textStyle: TextStyle(color: Colors.white), 
                                  backgroundColor: Color.fromARGB(255, 237, 129, 129),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _gastoVariableDescripcionController,
                                  decoration: InputDecoration(
                                    labelText: 'Descripción Gasto Variable',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _gastoVariableValorController,
                                  decoration: InputDecoration(
                                    labelText: 'Valor Gasto Variable',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  handleAgregarGasto('variable');
                                },
                                child: Text('Agregar'),
                                style: ElevatedButton.styleFrom(
                                  textStyle: TextStyle(color: Colors.white), 
                                  backgroundColor: Color.fromARGB(255, 238, 188, 127),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _ahorroDescripcionController,
                                  decoration: InputDecoration(
                                    labelText: 'Descripción Ahorro',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _ahorroValorController,
                                  decoration: InputDecoration(
                                    labelText: 'Valor Ahorro',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  handleAgregarGasto('ahorro');
                                },
                                child: Text('Agregar'),
                                style: ElevatedButton.styleFrom(
                                  textStyle: TextStyle(color: Colors.white), 
                                  backgroundColor: Color.fromARGB(255, 86, 223, 123),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: const Color(0xFF1F2833),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resumen',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Saldo Mensual: \$${saldoMensual.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Gastos Fijos: \$${gastosFijos.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Gastos Variables: \$${gastosVariables.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Ahorros: \$${ahorros.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Divider(color: Colors.white),
                          const SizedBox(height: 10),
                          Text(
                            'Saldo Total: \$${(saldoMensual - gastosFijos - gastosVariables - ahorros).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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

void main() {
  runApp(AhorroApp());
}
