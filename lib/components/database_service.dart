import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final _supabase = Supabase.instance.client;

  // 1. OBTENER TODO EL PERFIL (Nombre, Foto, etc.)
  // Este es el método que le faltaba a tu HomeScreen
  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    return await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  // 2. OBTENER SOLO EL NOMBRE (Lo mantenemos por compatibilidad)
  Future<String?> getName() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await _supabase
        .from('profiles')
        .select('username')
        .eq('id', userId)
        .maybeSingle();
    return data?['username'];
  }

  // 3. ACTUALIZAR NOMBRE
  Future<void> updateName(String name) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('profiles').upsert({
      'id': userId,
      'username': name,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // 4. BORRAR PERFIL (Limpia nombre y foto)
  Future<void> deleteName() async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('profiles')
        .update({
          'username': null,
          'avatar_url': null, // También limpiamos la foto si borras el perfil
        })
        .eq('id', userId);
  }
}
