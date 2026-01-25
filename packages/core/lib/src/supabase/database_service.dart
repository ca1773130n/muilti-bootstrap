import 'package:supabase_flutter/supabase_flutter.dart';

/// Base class for Supabase database operations.
/// Provides type-safe query builders and common CRUD operations.
///
/// Example usage:
/// ```dart
/// class ProfileService extends SupabaseDatabaseService<Profile> {
///   ProfileService(SupabaseClient client) : super(client, 'profiles');
///
///   @override
///   Profile fromJson(Map<String, dynamic> json) => Profile.fromJson(json);
///
///   @override
///   Map<String, dynamic> toJson(Profile model) => model.toJson();
///
///   Future<Profile?> fetchByUserId(String userId) async {
///     final response = await table.select().eq('user_id', userId).maybeSingle();
///     return response != null ? fromJson(response) : null;
///   }
/// }
/// ```
abstract class SupabaseDatabaseService<T> {
  SupabaseDatabaseService(this._client, this.tableName);

  final SupabaseClient _client;

  /// The name of the Supabase table.
  final String tableName;

  /// Converts a JSON map to a domain model.
  T fromJson(Map<String, dynamic> json);

  /// Converts a domain model to a JSON map.
  Map<String, dynamic> toJson(T model);

  /// Get a reference to the table for building queries.
  SupabaseQueryBuilder get table => _client.from(tableName);

  /// Fetch all records from the table.
  Future<List<T>> fetchAll() async {
    final response = await table.select();
    return (response as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetch a single record by ID.
  Future<T?> fetchById(String id) async {
    final response = await table.select().eq('id', id).maybeSingle();
    return response != null ? fromJson(response) : null;
  }

  /// Insert a new record and return the created model.
  Future<T> insert(T model) async {
    final response = await table.insert(toJson(model)).select().single();
    return fromJson(response);
  }

  /// Update an existing record by ID and return the updated model.
  Future<T> update(String id, T model) async {
    final response = await table.update(toJson(model)).eq('id', id).select().single();
    return fromJson(response);
  }

  /// Delete a record by ID.
  Future<void> delete(String id) async {
    await table.delete().eq('id', id);
  }

  /// Fetch records with a custom filter.
  Future<List<T>> fetchWhere(String column, dynamic value) async {
    final response = await table.select().eq(column, value);
    return (response as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}
