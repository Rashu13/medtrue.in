import 'package:broadcast_app/controllers/admin_controller.dart';
import 'package:broadcast_app/controllers/auth_controller.dart';

import 'package:broadcast_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController adminController = Get.put(AdminController());
    final AuthController auth = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.campaign),
                label: const Text('BROADCAST MESSAGE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Get.to(
                    () => ChatScreen(
                      title: 'Broadcast to All',
                      currentUserId: auth.currentUser.value!.id,
                      currentUserRole: auth.userRole.value,
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('User List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Expanded(
            child: Obx(() {
              if (adminController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (adminController.users.isEmpty) {
                return const Center(child: Text('No users found.'));
              }
              return ListView.builder(
                itemCount: adminController.users.length,
                itemBuilder: (context, index) {
                  final user = adminController.users[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user['email'] ?? 'Unknown'),
                    subtitle: Text('ID: ${user['id']}'),
                    onTap: () {
                      Get.to(
                        () => ChatScreen(
                          otherUserId: user['id'],
                          title: 'Chat with ${user['email']}',
                          currentUserId: auth.currentUser.value!.id,
                          currentUserRole: auth.userRole.value,
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find();
    // ChatController is now lazy loaded

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.signOut(),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            // Lazy load chat
            Get.to(
              () => ChatScreen(
                title: 'Support Chat',
                currentUserId: auth.currentUser.value!.id,
                currentUserRole: auth.userRole.value,
              ),
            );
          },
          icon: const Icon(Icons.support_agent),
          label: const Text("Contact Support"),
        ),
      ),
    );
  }
}
