import 'package:broadcast_app/admin/screens/admin_chat_screen.dart';
import 'package:broadcast_app/admin/controllers/admin_messaging_controller.dart';
import 'package:broadcast_app/admin/repository/admin_repository.dart';
import 'package:broadcast_app/controllers/auth_controller.dart';
import 'package:broadcast_app/models/message.dart';
import 'package:broadcast_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller with the repository for the Admin section
    final controller = Get.put(
      AdminMessagingController(
        repository: AdminRepository(supabase: supabase),
      ),
    );
    final AuthController auth = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'lib/assets/admin.png',
                height: 32,
                width: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Shree Chat Admin'),
          ],
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: () => auth.signOut(),
        //   ),
        // ],
      ),
      body: Obx(() {
        if (controller.isLoadingUsers.value || controller.isLoadingMessages.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Broadcast Button Area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.campaign),
                  label: const Text('BROADCAST MESSAGE TO ALL USERS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Get.to(() => AdminBroadcastScreen(controller: controller));
                  },
                ),
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'All Users',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: controller.tenantUsers.isEmpty
                  ? const Center(child: Text('No users found in this tenant.'))
                    : ListView.builder(
                        itemCount: controller.tenantUsers.length,
                        itemBuilder: (context, index) {
                          final user = controller.tenantUsers[index];
                          final userId = user['id'];
                          final userEmail = user['email'] ?? 'Unknown User';
                          
                          // Wrap each item in Obx to listen for changes to allMessages
                          return Obx(() {
                            // Access messageVersion to force rebuild on new realtime messages
                            final _ = controller.messageVersion.value;
                            final messages = controller.getMessagesWithUser(userId);
                            final unreadCount = messages.where((m) => !m.isRead && m.senderId == userId).length;
                            
                            // Get last message for preview
                            final lastMsg = messages.isNotEmpty ? messages.last : null;
                            final lastMsgText = lastMsg != null 
                                ? (lastMsg.senderId == userId ? lastMsg.content : 'You: ${lastMsg.content}')
                                : 'No messages yet';
                            final lastMsgTime = lastMsg != null 
                                ? DateFormat('hh:mm a').format(lastMsg.createdAt.toLocal())
                                : '';

                            return ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(userEmail),
                              subtitle: Text(
                                lastMsgText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: unreadCount > 0 ? Colors.black87 : Colors.grey,
                                  fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat, 
                                    color: unreadCount > 0 ? Colors.red : Colors.grey
                                  ),
                                  if (unreadCount > 0)
                                    Text(
                                      '$unreadCount new',
                                      style: const TextStyle(color: Colors.red, fontSize: 10),
                                    ),
                                  if (lastMsgTime.isNotEmpty)
                                    Text(
                                      lastMsgTime,
                                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Get.to(() => AdminChatScreen(
                                      userId: userId,
                                      userName: userEmail,
                                      tenantId: controller.currentTenantId,
                                    ));
                              },
                            );
                          });
                        },
                      ),
            ),
          ],
        );
      }),
    );
  }
}

// AdminDirectChatScreen class removed and moved to AdminChatScreen.dart

// -------------------------------------------------------------
// Broadcast Screen for Admin
// -------------------------------------------------------------
class AdminBroadcastScreen extends StatelessWidget {
  final AdminMessagingController controller;

  AdminBroadcastScreen({super.key, required this.controller});
  
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Broadcast Messages')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final broadcastMsgs = controller.broadcastMessages;
              if (broadcastMsgs.isEmpty) {
                return const Center(child: Text("No broadcast messages yet."));
              }
              return ListView.builder(
                controller: scrollController,
                reverse: true,
                itemCount: broadcastMsgs.length,
                itemBuilder: (context, index) {
                  final reversedIndex = broadcastMsgs.length - 1 - index;
                  final msg = broadcastMsgs[reversedIndex];
                  
                  bool showDateSeparator = false;
                  if (reversedIndex == 0) {
                    showDateSeparator = true;
                  } else {
                    final prevMsg = broadcastMsgs[reversedIndex - 1];
                    final currentDate = DateFormat('yyyy-MM-dd').format(msg.createdAt.toLocal());
                    final prevDate = DateFormat('yyyy-MM-dd').format(prevMsg.createdAt.toLocal());
                    if (currentDate != prevDate) showDateSeparator = true;
                  }

                  final bubble = _buildMessageBubble(msg, true);
                  if (showDateSeparator) {
                    return Column(
                      children: [
                        _buildDateHeader(msg.createdAt.toLocal()),
                        bubble,
                      ],
                    );
                  }
                  return bubble;
                },
              );
            }),
          ),
          _buildInputArea(() {
            final text = messageController.text.trim();
            if (text.isNotEmpty) {
              controller.sendBroadcast(text);
              messageController.clear();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    String dateString;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      dateString = 'Today';
    } else if (msgDate == yesterday) {
      dateString = 'Yesterday';
    } else {
      dateString = DateFormat('dd MMM yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dateString,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: msg.isBroadcast ? Border.all(color: Colors.orange) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (msg.isBroadcast)
              const Text('📢 Broadcast', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            Text(msg.content),
            const SizedBox(height: 4),
            Text(DateFormat('hh:mm a').format(msg.createdAt.toLocal()), style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(VoidCallback onSend) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(hintText: 'Type a broadcast message...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Direct Chat Screen for Admin
// -------------------------------------------------------------
class AdminDirectChatScreen extends StatelessWidget {
  final AdminMessagingController controller;
  final String userId;
  final String userName;

  AdminDirectChatScreen({
    super.key,
    required this.controller,
    required this.userId,
    required this.userName,
  });

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Determine adminId. 
    final authId = controller.authController.currentUser.value?.id;

    return Scaffold(
      appBar: AppBar(title: Text('Chat with $userName')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final msgs = controller.getMessagesWithUser(userId);
              if (msgs.isEmpty) {
                return const Center(child: Text("No messages yet."));
              }
              return ListView.builder(
                controller: scrollController,
                itemCount: msgs.length,
                itemBuilder: (context, index) {
                  final msg = msgs[index];
                  // If we are logged in, use authId. Otherwise use the hardcoded test admin id
                  final currentAdminId = authId ?? '9999999999_shreeapp';
                  const dummyAdminId = '9999999999_shreeapp';
                  
                  // A message is "Me" if the sender matches either the current session ID OR the dummy ID
                  final isMe = msg.senderId == currentAdminId || msg.senderId == dummyAdminId;
                  
                  bool showDateSeparator = false;
                  if (index == 0) {
                    showDateSeparator = true;
                  } else {
                    final prevMsg = msgs[index - 1];
                    final currentDate = DateFormat('yyyy-MM-dd').format(msg.createdAt.toLocal());
                    final prevDate = DateFormat('yyyy-MM-dd').format(prevMsg.createdAt.toLocal());
                    if (currentDate != prevDate) showDateSeparator = true;
                  }

                  // Auto scroll when building the latest elements
                  if (index == msgs.length - 1) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (scrollController.hasClients) {
                        scrollController.animateTo(
                          scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }

                  final bubble = _buildMessageBubble(msg, isMe);
                  if (showDateSeparator) {
                    return Column(
                      children: [
                        _buildDateHeader(msg.createdAt.toLocal()),
                        bubble,
                      ],
                    );
                  }
                  return bubble;
                },
              );
            }),
          ),
          _buildInputArea(() {
            final text = messageController.text.trim();
            if (text.isNotEmpty) {
              controller.sendDirectMessage(userId, text);
              messageController.clear();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    String dateString;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      dateString = 'Today';
    } else if (msgDate == yesterday) {
      dateString = 'Yesterday';
    } else {
      dateString = DateFormat('dd MMM yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dateString,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg.content),
            const SizedBox(height: 4),
            Text(DateFormat('hh:mm a').format(msg.createdAt.toLocal()), style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(VoidCallback onSend) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(hintText: 'Type a direct message...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
