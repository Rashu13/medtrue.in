import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:broadcast_app/admin/repository/admin_repository.dart';
import 'package:broadcast_app/controllers/auth_controller.dart';
import 'package:broadcast_app/models/message.dart';
import 'package:broadcast_app/utils/constants.dart';
import 'package:broadcast_app/utils/encryption_helper.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMessagingController extends GetxController {
  final IAdminRepository repository;
  final AuthController authController = Get.find();
  
  // For now, let's just use 'shreeapp' since the user provided 'shreeapp' in their dummy data.
  // In a full production app, you would fetch this from the current admin's profile.
  String get currentTenantId => 'shreeapp'; 
  
  RxList<Map<String, dynamic>> tenantUsers = <Map<String, dynamic>>[].obs;
  RxList<Message> allMessages = <Message>[].obs;
  
  RxBool isLoadingUsers = false.obs;
  RxBool isLoadingMessages = false.obs;
  
  // This counter forces Obx to rebuild when messages change
  RxInt messageVersion = 0.obs;
  
  RealtimeChannel? _subscription;
  Timer? _pollTimer;

  AdminMessagingController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    fetchAllMessages();
  }

  @override
  void onReady() {
    super.onReady();
    _subscribeToRealtimeUpdates();
    // Polling fallback - refresh every 5 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _silentRefresh();
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    try {
      _subscription?.unsubscribe();
    } catch (_) {}
    super.onClose();
  }

  /// Silent refresh - fetches new messages without showing loading
  Future<void> _silentRefresh() async {
    try {
      final messages = await repository.fetchAllTenantMessages(currentTenantId);
      final decryptedMessages = messages.map((msg) {
        try {
          return msg.copyWith(content: EncryptionHelper.decrypt(msg.content));
        } catch (e) {
          return msg;
        }
      }).toList();
      
      if (decryptedMessages.length != allMessages.length) {
        allMessages.value = decryptedMessages;
        messageVersion.value++;
      }
    } catch (_) {}
  }

  Future<void> fetchUsers() async {
    isLoadingUsers.value = true;
    try {
      final data = await repository.fetchTenantUsers(currentTenantId);
      tenantUsers.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tenant users: $e');
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> fetchAllMessages() async {
    isLoadingMessages.value = true;
    try {
      final messages = await repository.fetchAllTenantMessages(currentTenantId);

      // Decrypt the messages
      final decryptedMessages = messages.map((msg) {
        try {
          return msg.copyWith(content: EncryptionHelper.decrypt(msg.content));
        } catch (e) {
          return msg;
        }
      }).toList();

      allMessages.value = decryptedMessages;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch messages: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  void _subscribeToRealtimeUpdates() {
    // Unique channel to avoid collisions with old instances
    final channelName = 'admin_realtime_${DateTime.now().millisecondsSinceEpoch}';
    
    // Cleanup old subscription safely
    try {
      _subscription?.unsubscribe();
    } catch (_) {}

    _subscription = supabase
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: '${AppConstants.tablePrefix}tbl_messages',
          callback: (payload) {
            debugPrint("Admin Realtime Message: ${payload.newRecord}");
            try {
              final newMessage = Message.fromMap(payload.newRecord);
              
              if (newMessage.tenantId != null && 
                  newMessage.tenantId!.isNotEmpty && 
                  newMessage.tenantId != currentTenantId) {
                return;
              }

              final decryptedMsg = newMessage.copyWith(
                  content: EncryptionHelper.decrypt(newMessage.content));
              
              if (allMessages.any((m) => m.id == decryptedMsg.id)) return;

              final tempIdx = allMessages.indexWhere((m) => 
                m.id.startsWith('temp_') && m.senderId == decryptedMsg.senderId && m.content == decryptedMsg.content
              );

              if (tempIdx != -1) {
                allMessages[tempIdx] = decryptedMsg;
              } else {
                allMessages.add(decryptedMsg);
              }

              allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              allMessages.refresh();
              messageVersion.value++;
            } catch (e) {
              debugPrint("Error in admin realtime: $e");
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: '${AppConstants.tablePrefix}tbl_profiles',
          callback: (payload) {
            debugPrint("Admin Realtime Profile: ${payload.newRecord}");
            final newProfile = payload.newRecord;
            if (newProfile['role'] == 'user' &&
                (newProfile['tenant_id'] == currentTenantId || newProfile['tenant_id'] == null || newProfile['tenant_id'] == "")) {
              if (!tenantUsers.any((u) => u['id'] == newProfile['id'])) {
                tenantUsers.add(Map<String, dynamic>.from(newProfile));
                tenantUsers.refresh();
              }
            }
          },
        )
        .subscribe((status, [error]) {
          debugPrint("=== Admin Realtime Status ($channelName): $status ===");
          if (error != null) debugPrint("=== Admin Realtime Error: $error ===");
        });
  }

  Future<void> sendBroadcast(String content) async {
    final senderId = authController.currentUser.value?.id ?? '9999999999_shreeapp';
    
    // 1. Optimistic Update: Add to local list immediately
    final tempMsg = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: null,
      content: content,
      isBroadcast: true,
      createdAt: DateTime.now(),
      tenantId: currentTenantId,
    );
    
    allMessages.add(tempMsg);
    allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    allMessages.refresh();

    // 2. Encrypt and send to DB
    final encryptedContent = EncryptionHelper.encrypt(content);

    try {
      await repository.sendBroadcastMessage(
        senderId: senderId,
        content: encryptedContent,
        tenantId: currentTenantId,
      );
      // Success snackbar is optional but good for feedback
    } catch (e) {
      allMessages.remove(tempMsg);
      Get.snackbar('Error', 'Failed to send broadcast: $e');
    }
  }

  Future<void> sendDirectMessage(String receiverId, String content) async {
    final senderId = authController.currentUser.value?.id ?? '9999999999_shreeapp';
    
    // Create an optimistic message to show immediately
    final optimisticMsg = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      content: content, // Logic stores decrypted/plain text locally
      isBroadcast: false,
      createdAt: DateTime.now(),
      tenantId: currentTenantId,
    );

    // Add locally first
    allMessages.add(optimisticMsg);
    allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Encrypt content before sending to DB
    final encryptedContent = EncryptionHelper.encrypt(content);

    try {
      await repository.sendIndividualMessage(
        senderId: senderId,
        receiverId: receiverId,
        content: encryptedContent,
        tenantId: currentTenantId,
      );
      // Realtime insertion will replace the temp ID later via 'id' uniqueness check in callback
    } catch (e) {
      allMessages.remove(optimisticMsg);
      Get.snackbar('Error', 'Failed to send message: $e');
    }
  }

  // Derived state to get messages specific to a chat
  List<Message> getMessagesWithUser(String userId) {
    final authId = authController.currentUser.value?.id;
    const dummyAdminId = '9999999999_shreeapp';

    return allMessages.where((msg) {
      if (msg.isBroadcast) return false;
      
      // Match current logged-in admin
      bool matchAuth = false;
      if (authId != null) {
        matchAuth = (msg.senderId == authId && msg.receiverId == userId) ||
                    (msg.senderId == userId && msg.receiverId == authId);
      }
      
      // Match dummy admin ID
      bool matchDummy = (msg.senderId == dummyAdminId && msg.receiverId == userId) ||
                        (msg.senderId == userId && msg.receiverId == dummyAdminId);
      
      return matchAuth || matchDummy;
    }).toList();
  }

  List<Message> get broadcastMessages {
    return allMessages.where((msg) => msg.isBroadcast).toList();
  }

  void markUserMessagesAsRead(String userId) {
    // Locally update the status of messages for this user
    for (int i = 0; i < allMessages.length; i++) {
      if (allMessages[i].senderId == userId && !allMessages[i].isRead) {
        allMessages[i] = allMessages[i].copyWith(isRead: true);
      }
    }
    allMessages.refresh();
  }
}
