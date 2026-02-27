import 'package:broadcast_app/admin/screens/admin_panel_screen.dart';
import 'package:broadcast_app/controllers/auth_controller.dart';
import 'package:broadcast_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // We navigate directly to the new Multi-Tenant Admin Panel
    // which implements the Repository pattern.
    return const AdminPanelScreen();
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
