import 'package:flutter/material.dart';
import 'database_service.dart';
import 'auth_service.dart';
import 'profile_service.dart'; // Importamos el servicio de la foto

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dbService = DatabaseService();
  final _profileService = ProfileService(); // Instancia del servicio de foto
  final _nameController = TextEditingController();

  String? _avatarUrl; // Variable para guardar la URL de la foto
  bool _isLoading = true;
  bool _isUploading = false; // Para mostrar un loader mientras sube la foto

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Cargamos nombre y foto al iniciar
  void _loadProfileData() async {
    final name = await _dbService.getName();
    // Suponiendo que tienes un método en database_service para traer la URL
    // o puedes obtenerla directamente de la tabla profiles aquí.
    final userData = await _dbService.getUserProfile();

    if (name != null) _nameController.text = name;
    if (userData != null) _avatarUrl = userData['avatar_url'];

    setState(() => _isLoading = false);
  }

  // Función para subir la foto
  Future<void> _changePhoto() async {
    setState(() => _isUploading = true);

    final newUrl = await _profileService.uploadAndSaveAvatar();

    if (newUrl != null) {
      setState(() {
        // Agregamos un parámetro al final para engañar al caché de Flutter
        // Esto hará que la URL se vea como: ...image.png?v=123456789
        _avatarUrl = "$newUrl?v=${DateTime.now().millisecondsSinceEpoch}";
      });
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // --- SECCIÓN DE LA FOTO ---
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _avatarUrl != null
                              ? NetworkImage(_avatarUrl!)
                              : null,
                          child: _avatarUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        if (_isUploading)
                          const Positioned.fill(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                              onPressed: _isUploading ? null : _changePhoto,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- CAMPOS DE TEXTO ---
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tu nombre completo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await _dbService.updateName(_nameController.text);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Perfil actualizado!'),
                              ),
                            );
                          }
                        },
                        child: const Text('Guardar Cambios'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _dbService.deleteName();
                          _nameController.clear();
                          setState(() => _avatarUrl = null);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Borrar Perfil'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
