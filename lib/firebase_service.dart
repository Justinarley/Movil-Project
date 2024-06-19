import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<Map<String, dynamic>?> getUserData(String usuario) async {
  try {
    QuerySnapshot querySnapshot = await db
        .collection('Usuarios')
        .where('usuario', isEqualTo: usuario)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data() as Map<String, dynamic>?;
    }
  } catch (e) {
    print('Error al obtener datos del usuario: $e');
  }
  return null;
}

Future<void> crearUsuario(String nombre, String usuario, String apellido, String contrasena, String fotoUrl) async {
  DocumentReference docRef = FirebaseFirestore.instance.collection('Usuarios').doc();
  String uid = docRef.id;
  try {
    print('Creando usuario con los siguientes datos:');
    print('UID: $uid');
    print('Nombre: $nombre');
    print('Usuario: $usuario');
    print('Apellido: $apellido');
    print('Contraseña: $contrasena');
    print('Foto URL: $fotoUrl');

    await docRef.set({
      'uid': uid,
      'nombre': nombre,
      'usuario': usuario,
      'apellido': apellido,
      'contrasena': contrasena,
      'fotoUrl': fotoUrl,
    });

    print("Usuario creado correctamente con ID: $uid");
  } catch (e) {
    print('Error al agregar el usuario: $e');
    rethrow;
  }
}

Future<void> updateUserProfile(String usuario, Map<String, dynamic> dataToUpdate) async {
  try {
    QuerySnapshot snapshot = await db
        .collection('Usuarios')
        .where('usuario', isEqualTo: usuario)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String docId = snapshot.docs.first.id;
      await db.collection('Usuarios').doc(docId).update(dataToUpdate);
      print('Perfil actualizado correctamente.');
    } else {
      print('Usuario no encontrado.');
    }
  } catch (e) {
    print('Error al actualizar el perfil: $e');
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearGasto(String usuarioId, Map<String, dynamic> gastoData) async {
    try {
      await _firestore.collection('Gastos').add({
        ...gastoData,
        'usuarioId': usuarioId,
        'fecha': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error al crear gasto: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getHistorial(String usuarioId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Gastos')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('fecha', descending: true)
          .get();

      List<Map<String, dynamic>> historial = [];

      querySnapshot.docs.forEach((documento) {
        Map<String, dynamic>? data = documento.data() as Map<String, dynamic>?;

        if (data != null) {
          historial.add(data);
        }
      });

      return historial;
    } catch (e) {
      throw Exception('Error al obtener el historial de gastos: $e');
    }
  }
   Future<double> getTotalGastosFijos(String usuarioId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Gastos')
          .where('usuarioId', isEqualTo: usuarioId)
          .where('tipo', isEqualTo: 'fijo')
          .get();

      double total = 0;

      querySnapshot.docs.forEach((documento) {
        Map<String, dynamic>? data = documento.data() as Map<String, dynamic>?;

        if (data != null) {
          double? valor = (data['valor'] as num?)?.toDouble();
          if (valor != null) {
            total += valor;
          }
        }
      });

      return total;
    } catch (e) {
      throw Exception('Error al obtener el total de gastos fijos: $e');
    }
  }

  Future<double> getTotalGastosVariables(String usuarioId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Gastos')
          .where('usuarioId', isEqualTo: usuarioId)
          .where('tipo', isEqualTo: 'variable')
          .get();

      double total = 0;

      querySnapshot.docs.forEach((documento) {
        Map<String, dynamic>? data = documento.data() as Map<String, dynamic>?;

        if (data != null) {
          double? valor = (data['valor'] as num?)?.toDouble();
          if (valor != null) {
            total += valor;
          }
        }
      });

      return total;
    } catch (e) {
      throw Exception('Error al obtener el total de gastos variables: $e');
    }
  }

  Future<double> getTotalAhorros(String usuarioId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Gastos')
          .where('usuarioId', isEqualTo: usuarioId)
          .where('tipo', isEqualTo: 'ahorro')
          .get();

      double total = 0;

      querySnapshot.docs.forEach((documento) {
        Map<String, dynamic>? data = documento.data() as Map<String, dynamic>?;

        if (data != null) {
          double? valor = (data['valor'] as num?)?.toDouble();
          if (valor != null) {
            total += valor;
          }
        }
      });

      return total;
    } catch (e) {
      throw Exception('Error al obtener el total de ahorros: $e');
    }
  }
}

