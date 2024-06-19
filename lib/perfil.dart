import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart'; // Asegúrate de importar el archivo donde tienes el servicio Firebase

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({Key? key}) : super(key: key);

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();
  String _imageUrl = '';
  String _nombre = '';
  String _apellido = '';
  String _usuario = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuario = prefs.getString('usuario');
    if (usuario != null) {
      Map<String, dynamic>? userData = await getUserData(usuario);
      if (userData != null) {
        setState(() {
          _nombre = userData["nombre"] ?? "";
          _apellido = userData["apellido"] ?? "";
          _usuario = userData["usuario"] ?? "";
          _imageUrl = userData["fotoUrl"] ?? '';
        });
      }
    }
  }

  Future<void> updatePerfil(Map<String, dynamic> dataToUpdate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuario = prefs.getString('usuario');
    if (usuario != null) {
      await updateUserProfile(usuario, dataToUpdate);
      fetchUserData(); // Actualiza los datos mostrados después de guardar
    }
  }

  Future<void> _saveUrl() async {
    if (_urlController.text.isNotEmpty) {
      setState(() {
        _imageUrl = _urlController.text;
      });
      await updatePerfil({'fotoUrl': _imageUrl});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL actualizada con éxito.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa una URL.')),
      );
    }
  }

  void _openUrlEditor() {
    _urlController.text = _imageUrl;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar URL de la imagen'),
          content: TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL de la imagen',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _saveUrl,
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _openProfileEditor() {
    _nombreController.text = _nombre;
    _apellidoController.text = _apellido;
    _usuarioController.text = _usuario;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    setState(() {
      _nombre = _nombreController.text;
      _apellido = _apellidoController.text;
      _usuario = _usuarioController.text;
    });

    await updatePerfil({
      'nombre': _nombre,
      'apellido': _apellido,
      'usuario': _usuario,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado con éxito')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: _openUrlEditor,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: _imageUrl.isNotEmpty
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(_imageUrl),
                            )
                          : null,
                      color: Colors.grey,
                    ),
                    child: _imageUrl.isEmpty
                        ? const Icon(Icons.account_circle, size: 100)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Tooltip(
                    message: 'Editar imagen',
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _openUrlEditor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nombre:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _nombre,
                                    style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _openProfileEditor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Apellido:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _apellido,
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _openProfileEditor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Usuario:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _usuario,
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _openProfileEditor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

