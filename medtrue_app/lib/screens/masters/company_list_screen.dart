import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/master_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../models/master_models.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MasterProvider>(context, listen: false).fetchMasters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Companies")),
      drawer: const AppDrawer(),
      body: Consumer<MasterProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.companies.isEmpty) {
            return const Center(child: Text("No companies found. Add one!"));
          }

          return ListView.builder(
            itemCount: provider.companies.length,
            itemBuilder: (context, index) {
              final company = provider.companies[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(company.name[0])),
                  title: Text(company.name),
                  subtitle: Text(company.address ?? "No Address"),
                  trailing: company.isActive 
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.cancel, color: Colors.red),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCompanyDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCompanyDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Company"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: "Address")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newCompany = Company(
                  companyId: 0, // Backend assigns ID
                  name: nameController.text,
                  address: addressController.text,
                  isActive: true,
                );
                Provider.of<MasterProvider>(context, listen: false).addCompany(newCompany);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
