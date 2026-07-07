import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase clientni ishga tushirish va global holda ulashish uchun singleton
class SupabaseService {
  SupabaseService._();

  // TODO: O'zingizning Supabase loyihangiz ma'lumotlarini kiriting.
  // Supabase Dashboard -> Project Settings -> API bo'limidan olinadi.
  static const String supabaseUrl = 'https://yhyalcsgkicklczqjtcu.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InloeWFsY3Nna2lja2xjenFqdGN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI4NzI2NjMsImV4cCI6MjA5ODQ0ODY2M30.ypJRaJgrtWFmf2V6A5EMIu89moeBu7WYnv0ctO2mtn4';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
