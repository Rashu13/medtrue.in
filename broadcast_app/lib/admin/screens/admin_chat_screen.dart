
import 'package:broadcast_app/models/message.dart';
import 'package:broadcast_app/utils/constants.dart';
import 'package:broadcast_app/utils/encryption_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:broadcast_app/controllers/auth_controller.dart';
import 'package:broadcast_app/admin/controllers/admin_messaging_controller.dart';

// -------------------- CONTROLLER --------------------
class AdminChatController extends GetxController {
  final String userId;
  final String userName;
  final String tenantId;

  AdminChatController({
    required this.userId, 
    required this.userName, 
    required this.tenantId
  });

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final AuthController authController = Get.find();
  
  var messages = <Message>[].obs;
  var isLoading = false.obs;
  
  RealtimeChannel? _subscription;
  
  // Admin identification
  String get adminId => authController.currentUser.value?.id ?? '9999999999_shreeapp';
  final String dummyAdminId = '9999999999_shreeapp';

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
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
      await fetchMessages();
      _subscribeToRealtime();
      // Mark existing messages as read when opening
      _markAsRead();
    } catch (e) {
      debugPrint("Error initializing admin chat: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _markAsRead() async {
    try {
      // Find all unread messages sent by THIS user to ADMIN
      // Filter out temp IDs (they don't exist in DB yet)
      final unreadIds = messages
          .where((m) => !m.isRead && m.senderId == userId && !m.id.startsWith('temp_') && m.id.isNotEmpty)
          .map((m) => m.id)
          .toList();

      // Update locally in THIS controller (mark ALL, including temp ones)
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].senderId == userId && !messages[i].isRead) {
          messages[i] = messages[i].copyWith(isRead: true);
        }
      }
      messages.refresh();

      // Update local state in main controller FIRST (so admin panel icon updates immediately)
      final adminMessagingController = Get.find<AdminMessagingController>();
      adminMessagingController.markUserMessagesAsRead(userId);
      debugPrint("Local unread status updated in both controllers");

      // Then update in database (only real IDs)
      if (unreadIds.isNotEmpty) {
        debugPrint("Marking ${unreadIds.length} messages as read in DB for $userId");
        await supabase
            .from('${AppConstants.tablePrefix}tbl_messages')
            .update({'is_read': true})
            .inFilter('id', unreadIds);
        debugPrint("DB update completed for $userId");
      }
    } catch (e) {
      debugPrint("Error marking messages as read: $e");
    }
  }

  Future<void> fetchMessages() async {
    try {
      // Direct messages between this specific user and admin (both real and dummy)
      final filter = 'and(sender_id.eq.$userId,or(receiver_id.eq.$adminId,receiver_id.eq.$dummyAdminId)),and(or(sender_id.eq.$adminId,sender_id.eq.$dummyAdminId),receiver_id.eq.$userId)';
      
      final response = await supabase
          .from('${AppConstants.tablePrefix}tbl_messages')
          .select()
          .or(filter)
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
    final channelName = 'admin_chat_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    _subscription = supabase
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: '${AppConstants.tablePrefix}tbl_messages',
          callback: (payload) {
            try {
              final rawMsg = Message.fromMap(payload.newRecord);
              
              // Filter: involves me and THIS specific user
              final involvesMe = rawMsg.senderId == adminId || rawMsg.senderId == dummyAdminId ||
                                rawMsg.receiverId == adminId || rawMsg.receiverId == dummyAdminId;
              final involvesThisUser = rawMsg.senderId == userId || rawMsg.receiverId == userId;

              if (involvesMe && involvesThisUser) {
                final decryptedMsg = rawMsg.copyWith(content: EncryptionHelper.decrypt(rawMsg.content));
                
                // Avoid duplicates and handle optimistic update sync
                if (messages.any((m) => m.id == decryptedMsg.id)) return;

                final tempIdx = messages.indexWhere((m) => 
                  m.id.startsWith('temp_') && m.senderId == decryptedMsg.senderId && m.content == decryptedMsg.content
                );

                if (tempIdx != -1) {
                  messages[tempIdx] = decryptedMsg;
                } else {
                  messages.add(decryptedMsg);
                  // If we are currently viewing this chat, mark it as read immediately
                  if (decryptedMsg.senderId == userId) {
                    _markAsRead();
                  }
                }
                
                messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                _scrollToBottom();
                
                // Alert the parent controller to refresh its list
                Get.find<AdminMessagingController>().allMessages.refresh();
              }
            } catch (e) {
              debugPrint("Admin realtime error: $e");
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
    if (content.isEmpty) return;

    // 1. Optimistic Update
    final tempMsg = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: adminId,
      receiverId: userId,
      content: content,
      isBroadcast: false,
      createdAt: DateTime.now(),
      tenantId: tenantId,
    );

    messages.add(tempMsg);
    messageController.clear();
    _scrollToBottom();

    // 2. Sync to Supabase
    final encryptedContent = EncryptionHelper.encrypt(content);
    final dbMessage = tempMsg.copyWith(content: encryptedContent, id: '');

    try {
      final response = await supabase
          .from('${AppConstants.tablePrefix}tbl_messages')
          .insert(dbMessage.toMap())
          .select()
          .single();
          
      final savedMsg = Message.fromMap(response);
      final idx = messages.indexOf(tempMsg);
      if (idx != -1) {
        messages[idx] = savedMsg.copyWith(content: content);
      }
    } catch (e) {
      messages.remove(tempMsg);
      Get.snackbar("Error", "Failed to send: $e");
    }
  }
}

// -------------------- VIEW --------------------
class AdminChatScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String tenantId;

  AdminChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.tenantId,
  });

  @override
  Widget build(BuildContext context) {
    // Unique controller per chat to ensure fresh state
    final controller = Get.put(
      AdminChatController(userId: userId, userName: userName, tenantId: tenantId),
      tag: userId, // Tag ensures we can have multiple chat screen instances if needed
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $userName'),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.messages.isEmpty) {
                    return const Center(child: Text("No messages yet."));
                  }
                  return ListView.builder(
                    controller: controller.scrollController,
                    reverse: true,
                    itemCount: controller.messages.length,
                    padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 4),
                    itemBuilder: (context, index) {
                      // Reverse index so newest message is at bottom
                      final reversedIndex = controller.messages.length - 1 - index;
                      final msg = controller.messages[reversedIndex];
                      final isMe = msg.senderId == controller.adminId || msg.senderId == controller.dummyAdminId;
                    
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[600] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                              bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                msg.content,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('hh:mm a').format(msg.createdAt.toLocal()),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: controller.sendMessage,
                      mini: true,
                      child: const Icon(Icons.send, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
