import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://vyhnpfccrwnokmakayfn.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5aG5wZmNjcndub2ttYWtheWZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU0NTkyOTUsImV4cCI6MjA4MTAzNTI5NX0.sivgHUJ1w4bU0dk6DprNVw-Pp9ewtjqz5xrG_oWT2mw';

  static SupabaseClient? _client;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    _client = Supabase.instance.client;
  }

  // Get Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase has not been initialized. Call initialize() first.');
    }
    return _client!;
  }

  // Sign In
  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return {'error': 'Sign in failed'};
      }

      // DEBUG: Log session info
      print('✅ Sign in successful');
      print('✅ User: ${response.user!.email}');
      print('✅ Access Token: ${response.session?.accessToken?.substring(0, 20)}...');

      return {
        'user': {
          'email': response.user!.email,
          'id': response.user!.id,
        },
        'session': response.session,
      };
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      return {'error': e.message};
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {'error': 'An unexpected error occurred: $e'};
    }
  }

  // Sign Up
  static Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return {'error': 'Sign up failed'};
      }

      return {
        'user': {
          'email': response.user!.email,
          'id': response.user!.id,
        },
      };
    } on AuthException catch (e) {
      return {'error': e.message};
    } catch (e) {
      return {'error': 'An unexpected error occurred: $e'};
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Get Profile
  static Future<Map<String, dynamic>?> getProfile(String email) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('email', email)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // Create Profile
  static Future<Map<String, dynamic>> createProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await client
          .from('profiles')
          .insert(profileData)
          .select()
          .single();

      return {'success': true, 'data': response};
    } catch (e) {
      return {'error': 'Failed to create profile: $e'};
    }
  }

  // Update Profile
  static Future<Map<String, dynamic>> updateProfile(String email, Map<String, dynamic> updates) async {
    try {
      final response = await client
          .from('profiles')
          .update(updates)
          .eq('email', email)
          .select()
          .single();

      return {'success': true, 'data': response};
    } catch (e) {
      return {'error': 'Failed to update profile: $e'};
    }
  }

  // Get data from any table
  static Future<List<Map<String, dynamic>>> getTableData(
    String tableName, {
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      if (orderBy != null) {
        final response = await client
            .from(tableName)
            .select()
            .order(orderBy, ascending: ascending);
        return List<Map<String, dynamic>>.from(response);
      } else {
        final response = await client.from(tableName).select();
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print('Error fetching data from $tableName: $e');
      return [];
    }
  }

  // Insert data into any table
  static Future<Map<String, dynamic>> insertData(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client
          .from(tableName)
          .insert(data)
          .select()
          .single();

      print('✅ Insert success: $response');
      return {'success': true, 'data': response};
    } catch (e) {
      print('❌ Insert error: $e');
      return {'error': 'Failed to insert data: $e'};
    }
  }

  // Update data in any table
  static Future<Map<String, dynamic>> updateData(
    String tableName,
    Map<String, dynamic> data,
    String column,
    dynamic value,
  ) async {
    try {
      final response = await client
          .from(tableName)
          .update(data)
          .eq(column, value)
          .select()
          .single();

      print('✅ Update success: $response');
      return {'success': true, 'data': response};
    } catch (e) {
      print('❌ Update error: $e');
      return {'error': 'Failed to update data: $e'};
    }
  }

  // Delete data from any table
  static Future<Map<String, dynamic>> deleteData(
    String tableName,
    String column,
    dynamic value,
  ) async {
    try {
      await client.from(tableName).delete().eq(column, value);

      print('✅ Delete success');
      return {'success': true};
    } catch (e) {
      print('❌ Delete error: $e');
      return {'error': 'Failed to delete data: $e'};
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return client.auth.currentUser;
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return client.auth.currentUser != null;
  }
}