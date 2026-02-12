
import 'package:broadcast_app/utils/constants.dart';
import 'package:broadcast_app/utils/encryption_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// -------------------- MODEL --------------------
class ChatMessage {
  final String id;
  final String senderId;
  final String? receiverId;
  final String content;
  final bool isBroadcast;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    this.receiverId,
    required this.content,
    required this.isBroadcast,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['sender_id'] ?? '',
      receiverId: map['receiver_id'],
      content: map['content'] ?? '',
      isBroadcast: map['is_broadcast'] ?? false,
      createdAt: DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'is_broadcast': isBroadcast,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    bool? isBroadcast,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      isBroadcast: isBroadcast ?? this.isBroadcast,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// -------------------- CONTROLLER --------------------
class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  var messages = <ChatMessage>[].obs;
  var isLoading = false.obs;
  var targetAdminId = RxnString();
  
  late String phoneNumber = '';
  late String appId = '';
  
  // Realtime subscription handle
  RealtimeChannel? _subscription;
  
  // Composite ID for unique chat per App ID + Phone combination
  String get chatUserId => '${phoneNumber}_${appId}';

  @override
  void onInit() {
    super.onInit();
    // Retrieve arguments passed via Get.to() or constructor parameters
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      phoneNumber = args['phoneNumber'] ?? '';
      appId = args['appId'] ?? '';
      if (args['adminId'] != null) {
        targetAdminId.value = args['adminId'];
      }
    }
    
    // If not in args, try parameters (for named routes like /chat?id=...)
    if (appId.isEmpty) appId = Get.parameters['appId'] ?? '';
    if (phoneNumber.isEmpty) phoneNumber = Get.parameters['phoneNumber'] ?? '';
    
    // If we have data, start. If not, wait for manual set (legacy constructor support)
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

      if (targetAdminId.value != null) {
        await fetchMessages();
        _subscribeToRealtime();
      } else {
        Get.snackbar("Error", "Admin not found. Cannot start chat.", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.redAccent, 
          colorText: Colors.white
        );
      }
    } catch (e) {
      debugPrint("Error initializing chat: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _syncProfile() async {
    try {
      // Use composite chatUserId as the unique ID
      final existingUser = await supabase
          .from('tbl_profiles')
          .select('role')
          .eq('id', chatUserId) 
          .maybeSingle();

      String role = 'user';
      if (existingUser != null && existingUser['role'] == 'admin') {
        role = 'admin';
      }

      await supabase.from('tbl_profiles').upsert({
        'id': chatUserId,      // Unique: Phone_AppID
        'email': phoneNumber,  // Storing Phone Number in email for reference
        'role': role,
      });

      final box = GetStorage();
      box.write('phone', phoneNumber);
      box.write('appId', appId);
      
    } catch (e) {
      debugPrint('Failed to sync profile: $e');
    }
  }

  Future<void> _fetchAdminId() async {
    try {
      final response = await supabase
          .from('tbl_profiles')
          .select('id')
          .eq('role', 'admin')
          .limit(1)
          .maybeSingle();

      if (response != null) {
        targetAdminId.value = response['id'] as String;
      }
    } catch (e) {
      debugPrint('Error fetching admin ID: $e');
    }
  }

  Future<void> fetchMessages() async {
    if (targetAdminId.value == null) return;
    
    try {
      // Filter using chatUserId
      final filter = 'and(sender_id.eq.$chatUserId,receiver_id.eq.${targetAdminId.value}),and(sender_id.eq.${targetAdminId.value},receiver_id.eq.$chatUserId)';
      
      final response = await supabase
          .from('tbl_messages')
          .select()
          .or(filter)
          .order('created_at', ascending: true);

      final data = response as List<dynamic>;
      
      final loadedMessages = data.map((e) {
        final msg = ChatMessage.fromMap(e);
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
    _subscription = supabase
        .channel('public:tbl_messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'tbl_messages',
          callback: (payload) {
            final rawMsg = ChatMessage.fromMap(payload.newRecord);
            
            // Filter logic using chatUserId
            final isMyMessage = (rawMsg.senderId == chatUserId && rawMsg.receiverId == targetAdminId.value);
            final isForMe = (rawMsg.senderId == targetAdminId.value && rawMsg.receiverId == chatUserId);

            if (isMyMessage || isForMe) {
               final decryptedMsg = rawMsg.copyWith(content: EncryptionHelper.decrypt(rawMsg.content));
               messages.add(decryptedMsg);
               _scrollToBottom();
            }
          },
        )
        .subscribe();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty || targetAdminId.value == null) return;

    final encryptedContent = EncryptionHelper.encrypt(content);

    final message = ChatMessage(
      id: '', 
      senderId: chatUserId, // User ID is Composite (Phone_AppID)
      receiverId: targetAdminId.value,
      content: encryptedContent,
      isBroadcast: false,
      createdAt: DateTime.now(),
    );

    try {
      await supabase.from('tbl_messages').insert(message.toMap());
      messageController.clear();
    } catch (e) {
      Get.snackbar("Error", "Failed to send: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }
}

// -------------------- BINDING --------------------
class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}

// -------------------- VIEW --------------------
class SimpleChatScreen extends StatelessWidget {
  final String? phoneNumber;
  final String? appId;
  final String? adminId;

  // Kept for backward compatibility, but logic moved to controller
  SimpleChatScreen({
    super.key,
    this.phoneNumber,
    this.appId,
    this.adminId,
  }) {
    // If navigated via standard Get.to without binding, or legacy Navigator
    // we ensure controller is present and updated.
    if (!Get.isRegistered<ChatController>()) {
      final ctrl = Get.put(ChatController());
      _updateController(ctrl);
    } else {
      // If already registered (e.g. singleton or kept alive), update params
      // WARNING: If using Get.lazyPut and navigated back and forth, 
      // check if we need to reset or update params.
      // Ideally, a unique tag per chat would be best, but for now assuming single chat instance use.
      _updateController(Get.find<ChatController>());
    }
  }

  void _updateController(ChatController ctrl) {
    if (phoneNumber != null && phoneNumber!.isNotEmpty) ctrl.phoneNumber = phoneNumber!;
    if (appId != null && appId!.isNotEmpty) ctrl.appId = appId!;
    if (adminId != null) ctrl.targetAdminId.value = adminId;
    
    // Trigger init if valid data
    if (ctrl.appId.isNotEmpty) {
      ctrl._initializeChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using Get.find locally to access controller
    final controller = Get.find<ChatController>();

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
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.messages.isEmpty) {
                return const Center(child: Text("Start a conversation..."));
              }
              return ListView.builder(
                controller: controller.scrollController,
                itemCount: controller.messages.length,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMe = msg.senderId == controller.chatUserId; // Compare with chatUserId
                  
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
          Padding(
            padding: const EdgeInsets.all(8.0),
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
    );
  }
}
