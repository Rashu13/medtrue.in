import 'package:broadcast_app/models/message.dart';
import 'package:broadcast_app/utils/constants.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String? otherUserId; // If null, it's a User viewing Admin chat (or Broadcast view)
  final String title;
  final String currentUserId;
  final String currentUserRole;

  const ChatScreen({
    super.key,
    this.otherUserId,
    required this.title,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  List<Message> messages = [];
  bool isLoading = false;
  String? targetId;
  RealtimeChannel? _subscription;

  @override
  void initState() {
    super.initState();
    targetId = widget.otherUserId;
    _initializeChat();
  }

  @override
  void dispose() {
    messageController.dispose();
    _subscription?.unsubscribe();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    setState(() => isLoading = true);

    // If user is not admin and no target specified, finding admin ID
    if (targetId == null && widget.currentUserRole != 'admin') {
      await _fetchAdminId();
    }

    await fetchMessages();
    _subscribeToRealtime();
    
    if (mounted) {
      setState(() => isLoading = false);
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

      if (response != null && mounted) {
        setState(() {
          targetId = response['id'] as String;
        });
      }
    } catch (e) {
      print('Error fetching admin ID: $e');
    }
  }

  Future<void> fetchMessages() async {
    try {
      final response = await supabase
          .from('tbl_messages')
          .select()
          .order('created_at', ascending: true);

      final data = response as List<dynamic>;
      if (mounted) {
        setState(() {
          messages = data.map((e) => Message.fromMap(e)).toList();
        });
      }
    } catch (e) {
      print('Error fetching messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching messages: $e')));
      }
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
            final newMessage = Message.fromMap(payload.newRecord);
            if (mounted) {
              setState(() {
                messages.add(newMessage);
              });
            }
          },
        )
        .subscribe();
  }

  Future<void> sendMessage(String? content) async {
    if (content == null || content.isEmpty) return;

    final isBroadcast = targetId == null;

    final message = Message(
      id: '', // Supabase generates this
      senderId: widget.currentUserId,
      receiverId: targetId,
      content: content,
      isBroadcast: isBroadcast,
      createdAt: DateTime.now(),
    );

    try {
      await supabase.from('tbl_messages').insert(message.toMap());
      messageController.clear();
    } catch (e) {
      print('Failed to send message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Builder(builder: (context) {
                    // Filter messages locally
                    final filteredMessages = messages.where((msg) {
                      if (targetId != null) {
                        // DM Logic
                        final isDM = (msg.senderId == widget.currentUserId && msg.receiverId == targetId) ||
                                     (msg.senderId == targetId && msg.receiverId == widget.currentUserId);
                        
                        // User sees broadcasts mixed in
                        if (widget.currentUserRole != 'admin' && msg.isBroadcast) {
                          return true;
                        }
                        return isDM;
                      } else {
                        // Broadcast Logic (Admin View)
                        if (widget.currentUserRole == 'admin') {
                          return msg.isBroadcast;
                        }
                        return true;
                      }
                    }).toList();

                    // Sort (already sorted by query but good to ensure)
                    filteredMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

                    if (filteredMessages.isEmpty) {
                      return const Center(child: Text("No messages yet."));
                    }

                    return ListView.builder(
                      itemCount: filteredMessages.length,
                      itemBuilder: (context, index) {
                        final msg = filteredMessages[index];
                        final isMe = msg.senderId == widget.currentUserId;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[100] : (msg.isBroadcast ? Colors.orange[100] : Colors.grey[200]),
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
                    controller: messageController,
                    decoration: const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(messageController.text.trim()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
