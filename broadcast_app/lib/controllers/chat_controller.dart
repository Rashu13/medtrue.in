import 'package:broadcast_app/controllers/auth_controller.dart';
import 'package:broadcast_app/models/message.dart';
import 'package:broadcast_app/utils/constants.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatController extends GetxController {
  final AuthController authController = Get.find();
  RxList<Message> messages = <Message>[].obs;
  RxBool isLoading = false.obs;
  RxnString adminId = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
    fetchAdminId();
    _subscribeToRealtime();
  }

  void fetchAdminId() async {
    try {
      // Fetch the first user with role 'admin'
      final response = await supabase
          .from('tbl_profiles')
          .select('id')
          .eq('role', 'admin')
          .limit(1)
          .maybeSingle();
      
      if (response != null) {
        adminId.value = response['id'] as String;
      } else {
        print('Warning: No admin found in tbl_profiles.');
      }
    } catch (e) {
      print('Error fetching admin ID: $e');
    }
  }

  void fetchMessages() async {
    isLoading.value = true;
    try {
      final response = await supabase
          .from('tbl_messages')
          .select()
          .order('created_at', ascending: true);

      final data = response as List<dynamic>;
      messages.value = data.map((e) => Message.fromMap(e)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Error fetching messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _subscribeToRealtime() {
    supabase
        .channel('public:tbl_messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'tbl_messages',
          callback: (payload) {
            final newMessage = Message.fromMap(payload.newRecord);
            messages.add(newMessage);
          },
        )
        .subscribe();
  }

  Future<void> sendMessage(String content, {String? receiverId}) async {
    // If receiverId is null, it's a broadcast (Admin only check should happen in UI or RLS)
    // Actually, our RLS allows insert if sender is auth user. 
    // We should ensure client logic is correct.
    
    final userId = authController.currentUser.value?.id;
    if (userId == null) return;

    final isBroadcast = receiverId == null;

    final message = Message(
      id: '', // Supabase generates this
      senderId: userId,
      receiverId: receiverId,
      content: content,
      isBroadcast: isBroadcast,
      createdAt: DateTime.now(),
    );

    try {
      await supabase.from('tbl_messages').insert(message.toMap());
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    }
  }
}
