import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  final _supabase = Supabase.instance.client;
  final _fcm = FirebaseMessaging.instance; // Tu variable se llama _fcm

  Future<void> initNotifications() async {
    try {
      print("--- INICIANDO FIREBASE MESSAGING ---");

      // 1. Solicitar permisos usando la variable correcta (_fcm)
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print("Estado de permisos: ${settings.authorizationStatus}");

      // 2. Obtener el token
      String? token = await _fcm.getToken();

      if (token != null) {
        print("************************************************");
        print("TOKEN ENCONTRADO:");
        print(token);
        print("************************************************");

        // 3. ¡IMPORTANTE! Llamar a la función para guardar en Supabase
        await _saveTokenToSupabase(token);
      } else {
        print("No se pudo generar el token (es nulo).");
      }
    } catch (e) {
      print("ERROR AL OBTENER TOKEN: $e");
    }
  }

  // Guardar el token en la tabla de Supabase
  Future<void> _saveTokenToSupabase(String token) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      print("❌ ERROR: No hay un usuario autenticado. El token no se guardará.");
      return;
    }

    try {
      print("Attempting to save token for user: ${user.id}");

      await _supabase.from('notifications').upsert({
        'user_id': user.id,
        'fcm_token': token,
      });

      print("✅ EXITÓ: Token guardado en la tabla 'notifications'");
    } catch (e) {
      print("❌ ERROR DE SUPABASE: $e");
    }
  }
}
