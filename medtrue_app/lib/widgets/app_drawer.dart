import 'package:flutter/material.dart';
import '../screens/masters/company_list_screen.dart';
import '../screens/products/product_list_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("MedTrue Admin"),
            accountEmail: Text("admin@medtrue.in"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("MT", style: TextStyle(fontSize: 24, color: Colors.teal)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Companies'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CompanyListScreen()));
            },
          ),
          // Placeholder for other screens
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductListScreen()));
            },
          ),
        ],
      ),
    );
  }
}
