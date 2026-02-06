import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/watermark_controller.dart';
import '../services/watermark_service.dart';

class PreviewScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const PreviewScreen({super.key, required this.imageBytes});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final WatermarkController _wmController = Get.find<WatermarkController>();
  Uint8List? _processedImage;
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _applyWatermark();
    
    // Listen to changes and re-apply watermark
    ever(_wmController.watermarkText, (_) => _applyWatermark());
    ever(_wmController.opacity, (_) => _applyWatermark());
    ever(_wmController.fontSize, (_) => _applyWatermark());
    ever(_wmController.watermarkColor, (_) => _applyWatermark());
    ever(_wmController.selectedPattern, (_) => _applyWatermark());
  }

  Future<void> _applyWatermark() async {
    setState(() => _isProcessing = true);

    final result = await WatermarkService.applyWatermark(
      imageBytes: widget.imageBytes,
      text: _wmController.watermarkText.value,
      pattern: _wmController.selectedPattern.value,
      opacity: _wmController.opacity.value,
      fontSize: _wmController.fontSize.value,
      colorValue: _wmController.watermarkColor.value,
      filter: _wmController.selectedFilter.value,
      logoPath: _wmController.logoPath.value,
    );

    if (mounted) {
      setState(() {
        _processedImage = result;
        _isProcessing = false;
      });
    }
  }

  Future<void> _saveImage() async {
    if (_processedImage == null) return;

    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        final photosStatus = await Permission.photos.request();
        if (!photosStatus.isGranted) {
          Get.snackbar('Error', 'Storage permission denied');
          return;
        }
      }

      final result = await ImageGallerySaverPlus.saveImage(
        _processedImage!,
        quality: 100,
        name: 'watermark_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        Get.snackbar(
          'Success',
          'Image saved to gallery',
          backgroundColor: const Color(0xFF10B981).withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Failed to save image');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Preview',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Preview Image
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _isProcessing
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                    )
                  : _processedImage != null
                      ? Image.memory(
                          _processedImage!,
                          fit: BoxFit.contain,
                        )
                      : const Center(
                          child: Text(
                            'Failed to process image',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
            ),
          ),

          // Settings Summary
          Obx(() => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.text_fields, color: Color(0xFF6366F1), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _wmController.watermarkText.value,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _patternChip('Grid', WatermarkPattern.grid),
                    const SizedBox(width: 8),
                    _patternChip('Diagonal', WatermarkPattern.diagonal),
                    const SizedBox(width: 8),
                    _patternChip('Center', WatermarkPattern.center),
                  ],
                ),
              ],
            ),
          )),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Retake',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_alt, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Save',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _patternChip(String label, WatermarkPattern pattern) {
    final isSelected = _wmController.selectedPattern.value == pattern;
    return GestureDetector(
      onTap: () => _wmController.selectPattern(pattern),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
