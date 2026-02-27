
import 'package:broadcast_app/models/message.dart';
import 'package:broadcast_app/utils/constants.dart';
import 'package:broadcast_app/utils/encryption_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// -------------------- CONTROLLER --------------------
class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  var messages = <Message>[].obs;
  var isLoading = false.obs;
  var targetAdminId = RxnString();
  
  late String phoneNumber = '';
  late String appId = '';
  late String tenantId = '';
  
  RealtimeChannel? _subscription;
  
  String get chatUserId => '${phoneNumber}_${appId}';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      phoneNumber = args['phoneNumber'] ?? '';
      appId = args['appId'] ?? '';
      tenantId = args['tenantId'] ?? '';
      if (args['adminId'] != null) targetAdminId.value = args['adminId'];
    }
    
    if (appId.isEmpty) appId = Get.parameters['appId'] ?? '';
    if (phoneNumber.isEmpty) phoneNumber = Get.parameters['phoneNumber'] ?? '';
    if (tenantId.isEmpty) tenantId = Get.parameters['tenantId'] ?? '';
  }

  @override
  void onReady() {
    super.onReady();
    if (appId.isNotEmpty) {
      _initializeChat();
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    _subscription?.unsubscribe();
    super.onClose();
  }

  Future<void> _initializeChat() async {
    isLoading.value = true;
    try {
      if (phoneNumber.isNotEmpty && appId.isNotEmpty) {
        await _syncProfile();
      }
      
      if (targetAdminId.value == null) {
        await _fetchAdminId();
      }

      // Hardcode fallback
      if (targetAdminId.value == null) {
        targetAdminId.value = '9999999999_shreeapp';
      }

      await fetchMessages();
      _subscribeToRealtime();
    } catch (e) {
      debugPrint("Error initializing chat: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _syncProfile() async {
    try {
      final existingUser = await supabase
          .from('${AppConstants.tablePrefix}tbl_profiles')
          .select('role')
          .eq('id', chatUserId) 
          .maybeSingle();

      String role = 'user';
      if (existingUser != null && existingUser['role'] == 'admin') {
        role = 'admin';
      }

      await supabase.from('${AppConstants.tablePrefix}tbl_profiles').upsert({
        'id': chatUserId,
        'email': phoneNumber,
        'role': role,
        if (tenantId.isNotEmpty) 'tenant_id': tenantId,
      });

      final box = GetStorage();
      box.write('phone', phoneNumber);
      box.write('appId', appId);
      box.write('tenantId', tenantId);
    } catch (e) {
      debugPrint('Failed to sync profile: $e');
    }
  }

  Future<void> _fetchAdminId() async {
    try {
      var query = supabase
          .from('${AppConstants.tablePrefix}tbl_profiles')
          .select('id')
          .ilike('role', 'admin');
          
      if (tenantId.isNotEmpty) {
        query = query.eq('tenant_id', tenantId);
      }

      final response = await query.limit(1).maybeSingle();
      if (response != null) {
        targetAdminId.value = response['id'] as String;
      }
    } catch (e) {
      debugPrint('Error fetching admin ID: $e');
    }
  }

  Future<void> fetchMessages() async {
    final adminId = targetAdminId.value ?? '9999999999_shreeapp';
    const dummyAdminId = '9999999999_shreeapp';
    
    try {
      final directFilter = 'and(sender_id.eq.$chatUserId,or(receiver_id.eq.$adminId,receiver_id.eq.$dummyAdminId)),and(or(sender_id.eq.$adminId,sender_id.eq.$dummyAdminId),receiver_id.eq.$chatUserId)';
      final broadcastFilter = 'and(is_broadcast.eq.true,or(tenant_id.eq.$tenantId,tenant_id.is.null))';
      
      final response = await supabase
          .from('${AppConstants.tablePrefix}tbl_messages')
          .select()
          .or('$directFilter,$broadcastFilter')
          .order('created_at', ascending: true);

      final data = response as List<dynamic>;
      final loadedMessages = data.map((e) {
        final msg = Message.fromMap(e);
        try {
          return msg.copyWith(content: EncryptionHelper.decrypt(msg.content));
        } catch (e) {
          return msg;
        }
      }).toList();

      messages.assignAll(loadedMessages);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
  }

  void _subscribeToRealtime() {
    final channelName = 'user_chat_${chatUserId}_${DateTime.now().millisecondsSinceEpoch}';
    _subscription = supabase
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: '${AppConstants.tablePrefix}tbl_messages',
          callback: (payload) {
            try {
              final rawMsg = Message.fromMap(payload.newRecord);
              const dummyAdminId = '9999999999_shreeapp';
              final adminId = targetAdminId.value ?? dummyAdminId;

              final sentByMe = rawMsg.senderId == chatUserId;
              final sentToMe = rawMsg.receiverId == chatUserId;
              
              // Correct Broadcast Logic: Show if it matches tenant OR if no tenant is specified
              final isBroadcastForMe = rawMsg.isBroadcast && 
                                       (rawMsg.tenantId == tenantId || 
                                        rawMsg.tenantId == null || 
                                        rawMsg.tenantId!.isEmpty || 
                                        tenantId.isEmpty);
              
              final involvesAdmin = rawMsg.senderId == adminId || 
                                   rawMsg.senderId == dummyAdminId ||
                                   rawMsg.receiverId == adminId || 
                                   rawMsg.receiverId == dummyAdminId;

              if (sentByMe || sentToMe || isBroadcastForMe || (involvesAdmin && sentToMe)) {
                String decryptedContent = rawMsg.content;
                try {
                  decryptedContent = EncryptionHelper.decrypt(rawMsg.content);
                } catch (_) {}
                
                final finalMsg = rawMsg.copyWith(content: decryptedContent);
                if (messages.any((m) => m.id == finalMsg.id)) return;

                final tempIdx = messages.indexWhere((m) => 
                   m.id.startsWith('temp_') && m.senderId == finalMsg.senderId && m.content == finalMsg.content
                );

                if (tempIdx != -1) {
                  messages[tempIdx] = finalMsg;
                } else {
                  messages.add(finalMsg);
                }

                messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                _scrollToBottom();
              }
            } catch (e) {
              debugPrint("Error in user realtime chat: $e");
            }
          },
        )
        .subscribe();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty || targetAdminId.value == null) return;

    final tempMsg = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: chatUserId,
      receiverId: targetAdminId.value,
      content: content,
      isBroadcast: false,
      createdAt: DateTime.now(),
      tenantId: tenantId,
    );

    messages.add(tempMsg);
    messageController.clear();
    _scrollToBottom();

    final encryptedContent = EncryptionHelper.encrypt(content);
    final dbMessage = tempMsg.copyWith(content: encryptedContent, id: '');

    try {
      final response = await supabase.from('${AppConstants.tablePrefix}tbl_messages').insert(dbMessage.toMap()).select().single();
      final savedMsg = Message.fromMap(response);
      final index = messages.indexOf(tempMsg);
      if (index != -1) {
        messages[index] = savedMsg.copyWith(content: content);
      }
    } catch (e) {
      messages.remove(tempMsg);
      Get.snackbar("Error", "Failed to send: $e");
    }
  }
}

// -------------------- VIEW --------------------
class SimpleChatScreen extends StatelessWidget {
  final String? phoneNumber;
  final String? appId;
  final String? adminId;
  final String? tenantId;

  SimpleChatScreen({
    super.key,
    this.phoneNumber,
    this.appId,
    this.adminId,
    this.tenantId,
  });

  @override
  Widget build(BuildContext context) {
    // Unique controller per instance if using multiple chats
    final controller = Get.put(ChatController(), tag: phoneNumber ?? 'default');
    
    // Explicitly update values to ensure they are set even if controller was reused
    if (phoneNumber != null) controller.phoneNumber = phoneNumber!;
    if (appId != null) controller.appId = appId!;
    if (tenantId != null) controller.tenantId = tenantId!;
    if (adminId != null) controller.targetAdminId.value = adminId;
    
    // Re-initialize if parameters have changed
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (controller.appId.isNotEmpty) controller._initializeChat();
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Support Chat', style: TextStyle(fontSize: 16)),
            Text('Phone: ${controller.phoneNumber}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                if (controller.messages.isEmpty) return const Center(child: Text("Start a conversation..."));
                
                return ListView.builder(
                  controller: controller.scrollController,
                  reverse: true,
                  itemCount: controller.messages.length,
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 4),
                  itemBuilder: (context, index) {
                    final reversedIndex = controller.messages.length - 1 - index;
                    final msg = controller.messages[reversedIndex];
                    final isMe = msg.senderId == controller.chatUserId;
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[600] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15).copyWith(
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(15),
                            bottomLeft: isMe ? const Radius.circular(15) : const Radius.circular(0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (msg.isBroadcast)
                              const Text('📢 Broadcast', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                            Text(msg.content, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('hh:mm a').format(msg.createdAt.toLocal()),
                              style: TextStyle(fontSize: 9, color: isMe ? Colors.white70 : Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24))),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: controller.sendMessage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
