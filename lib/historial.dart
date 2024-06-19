import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Historial extends StatelessWidget {
  final String usuarioId;

  Historial({Key? key, required this.usuarioId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Datos quemados para simular un historial
    List<Map<String, dynamic>> historial = [
      {
        'ingresos': [
          {
            'descripcion': 'Compra de víveres',
            'tipo': 'Alimentación',
            'valor': 100.00,
            'fecha': DateTime.now(),
          },
          {
            'descripcion': 'Gasolina',
            'tipo': 'Transporte',
            'valor': 50.00,
            'fecha': DateTime.now().subtract(Duration(days: 2)),
          },
        ],
      },
      {
        'ingresos': [
          {
            'descripcion': 'Cine con amigos',
            'tipo': 'Entretenimiento',
            'valor': 25.00,
            'fecha': DateTime.now().subtract(Duration(days: 5)),
          },
        ],
      },
      {
        'ingresos': [
          {
            'descripcion': 'Alquiler',
            'tipo': 'Fijo',
            'valor': 250.00,
            'fecha': DateTime.now(),
          },
        ],
      },
      {
        'ingresos': [
          {
            'descripcion': 'Empleados',
            'tipo': 'Variable',
            'valor': 450.00,
            'fecha': DateTime.now(),
          },
        ],
      },
      {
        'ingresos': [
          {
            'descripcion': 'Fondos',
            'tipo': 'Ahorro',
            'valor': 100.00,
            'fecha': DateTime.now(),
          },
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Gastos'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Descripción')),
            DataColumn(label: Text('Tipo')),
            DataColumn(label: Text('Valor')),
            DataColumn(label: Text('Fecha')),
          ],
          rows: historial.expand((entradaHistorial) {
            List<dynamic> ingresos = entradaHistorial['ingresos'];
            return ingresos.map((ingreso) {
              DateTime fecha = ingreso['fecha'];
              String formattedDate = DateFormat.yMMMMd().format(fecha);

              return DataRow(cells: [
                DataCell(Text(ingreso['descripcion'])),
                DataCell(Text(ingreso['tipo'])),
                DataCell(Text('\$${ingreso['valor']}')),
                DataCell(Text(formattedDate)),
              ]);
            }).toList();
          }).toList(),
        ),
      ),
    );
  }
}
