import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  // Función principal para actualizar la foto
  Future<String?> uploadAndSaveAvatar() async {
    final picker = ImagePicker();
    final user = supabase.auth.currentUser;

    if (user == null) {
      print("No hay un usuario autenticado");
      return null;
    }

    try {
      // 1. Seleccionar la imagen de la galería
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality:
            50, // Comprimimos un poco para ahorrar espacio en Supabase
      );

      if (pickedFile == null) return null; // El usuario canceló la selección

      final File imageFile = File(pickedFile.path);

      // 2. Definir la ruta en el Storage (usamos el ID del usuario)
      // Asegúrate de haber creado el bucket 'avatars' en Supabase
      final String filePath = 'public/${user.id}.png';

      // 3. Subir al Storage (Bucket: 'avatars')
      await supabase.storage
          .from('avatars')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              upsert: true,
            ), // Actualiza si ya existe
          );

      // 4. Obtener la URL Pública
      final String publicUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // 5. Guardar la URL en la tabla 'profiles' en la columna 'avatar_url'
      await supabase
          .from('profiles')
          .update({
            'avatar_url': publicUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      print("Foto de perfil actualizada: $publicUrl");
      return publicUrl;
    } catch (e) {
      print("Error al subir la foto: $e");
      return null;
    }
  }
}
