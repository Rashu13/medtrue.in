import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_models.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mrpController = TextEditingController();
  final _packingController = TextEditingController();
  
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      final product = Product(
        name: _nameController.text,
        packingDesc: _packingController.text,
        mrp: double.tryParse(_mrpController.text) ?? 0.0,
        // Add defaults for others
      );

      final provider = Provider.of<ProductProvider>(context, listen: false);
      final productId = await provider.addProduct(product);

      if (_selectedImage != null) {
        await provider.uploadImage(productId, _selectedImage!, isPrimary: true);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Product Name"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _packingController,
                decoration: const InputDecoration(labelText: "Packing (e.g. 10 TAB)"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _mrpController,
                decoration: const InputDecoration(labelText: "MRP"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              
              // Image Picker UI
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedImage == null
                      ? const Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.camera_alt, size: 50), Text("Tap to select image")],
                        ))
                      : Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 30),
              _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      child: const Text("Save Product"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
