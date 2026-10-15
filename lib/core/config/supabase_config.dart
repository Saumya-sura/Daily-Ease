/// ==============================================================================
/// SUPABASE CREDENTIALS & LIVE BACKEND CONFIGURATION
/// ==============================================================================
library;

class SupabaseConfig {
  /// Live Supabase Project URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cbqdvrqvaykodclvxonv.supabase.co',
  );

  /// Live Supabase Anon / Publishable Key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNicWR2cnF2YXlrb2RjbHZ4b252Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE4OTY5NzgsImV4cCI6MjEwNzQ3Mjk3OH0.X92Qln_tZ7IGgSbGBHafk00S0mLMmGeEc0I_Cq1v9fs',
  );

  /// Automatically validates live Supabase connection configuration
  static bool get isLiveConfigured =>
      supabaseUrl == 'https://cbqdvrqvaykodclvxonv.supabase.co' ||
      (supabaseUrl != 'https://placeholder.supabase.co' &&
          supabaseAnonKey != 'unconfigured_key' &&
          supabaseUrl.startsWith('https://'));
}
