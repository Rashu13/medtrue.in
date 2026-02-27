import 'package:broadcast_app/models/message.dart';
import 'package:broadcast_app/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAdminRepository {
  Future<List<Map<String, dynamic>>> fetchTenantUsers(String tenantId);
  Future<List<Message>> fetchAllTenantMessages(String tenantId);
  Future<List<Message>> fetchChatWithUser(String adminId, String userId);
  Future<void> sendIndividualMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? tenantId,
  });
  Future<void> sendBroadcastMessage({
    required String senderId,
    required String content,
    String? tenantId,
  });
}

class AdminRepository implements IAdminRepository {
  final SupabaseClient supabase;

  AdminRepository({required this.supabase});

  @override
  Future<List<Map<String, dynamic>>> fetchTenantUsers(String tenantId) async {
    final response = await supabase
        .from('${AppConstants.tablePrefix}tbl_profiles')
        .select('id, email, role')
        .eq('role', 'user')
        .or('tenant_id.eq.$tenantId,tenant_id.is.null'); // Fallback for users with no tenant_id

    final data = response as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<List<Message>> fetchAllTenantMessages(String tenantId) async {
    final response = await supabase
        .from('${AppConstants.tablePrefix}tbl_messages')
        .select()
        .or('tenant_id.eq.$tenantId,tenant_id.is.null') // Include messages with no tenant_id
        .order('created_at', ascending: true);

    final data = response as List<dynamic>;
    return data.map((e) => Message.fromMap(e)).toList();
  }

  @override
  Future<List<Message>> fetchChatWithUser(String adminId, String userId) async {
    // Both sent to user and received from user
    final response = await supabase
        .from('${AppConstants.tablePrefix}tbl_messages')
        .select()
        .or('and(sender_id.eq.$adminId,receiver_id.eq.$userId),and(sender_id.eq.$userId,receiver_id.eq.$adminId)')
        .order('created_at', ascending: true);

    final data = response as List<dynamic>;
    return data.map((e) => Message.fromMap(e)).toList();
  }

  @override
  Future<void> sendIndividualMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? tenantId,
  }) async {
    final message = Message(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      isBroadcast: false,
      createdAt: DateTime.now(),
      tenantId: tenantId,
    );

    await supabase.from('${AppConstants.tablePrefix}tbl_messages').insert(message.toMap());
  }

  @override
  Future<void> sendBroadcastMessage({
    required String senderId,
    required String content,
    String? tenantId,
  }) async {
    final message = Message(
      id: '',
      senderId: senderId,
      receiverId: null, // Null means broadcast
      content: content,
      isBroadcast: true,
      createdAt: DateTime.now(),
      tenantId: tenantId,
    );

    await supabase.from('${AppConstants.tablePrefix}tbl_messages').insert(message.toMap());
  }
}
