import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_drawer.dart';
import 'add_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      drawer: const AppDrawer(),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.products.isEmpty) {
            return const Center(child: Text("No products found. Add one!"));
          }

          return ListView.builder(
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              // Show first image if available
              // Note: Product model currently doesn't auto-fetch images with list unless backend does a join
              // For now, we will assume no image in list, or complex logic needed later.
              
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.medication),
                  title: Text(product.name),
                  subtitle: Text("MRP: ${product.mrp} | Packing: ${product.packingDesc}"),
                  onTap: () {
                    // Navigate to details/edit
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
