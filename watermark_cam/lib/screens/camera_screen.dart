import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/watermark_controller.dart';
import '../widgets/settings_sheet.dart';
import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;
  final WatermarkController _wmController = Get.find<WatermarkController>();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _errorMessage = 'Camera permission denied';
          _isLoading = false;
        });
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras found';
          _isLoading = false;
        });
        return;
      }

      // Initialize with first (back) camera
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      final Uint8List imageBytes = await photo.readAsBytes();
      
      Get.to(() => PreviewScreen(imageBytes: imageBytes));
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        Get.to(() => PreviewScreen(imageBytes: imageBytes));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SettingsSheet(),
    );
  }

  ColorFilter? _getColorFilter(CameraFilter filter) {
    switch (filter) {
      case CameraFilter.none:
        return null;
      case CameraFilter.sepia:
        return const ColorFilter.matrix([
          0.393, 0.769, 0.189, 0, 0,
          0.349, 0.686, 0.168, 0, 0,
          0.272, 0.534, 0.131, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case CameraFilter.blackWhite:
        return const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case CameraFilter.vintage:
        return const ColorFilter.matrix([
          0.9, 0.5, 0.1, 0, 0,
          0.3, 0.8, 0.1, 0, 0,
          0.2, 0.3, 0.5, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case CameraFilter.cool:
        return const ColorFilter.matrix([
          1, 0, 0, 0, 0,
          0, 1, 0.1, 0, 0,
          0, 0, 1.2, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case CameraFilter.warm:
        return const ColorFilter.matrix([
          1.2, 0.1, 0, 0, 0,
          0, 1, 0, 0, 0,
          0, 0, 0.9, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case CameraFilter.vivid:
        return const ColorFilter.matrix([
          1.3, 0, 0, 0, 0,
          0, 1.3, 0, 0, 0,
          0, 0, 1.3, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case CameraFilter.blur:
        return null; // Blur is applied via ImageFiltered widget, not ColorFilter
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Stamp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'It',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ),
        leading: Obx(() => IconButton(
          onPressed: _wmController.toggleGrid,
          tooltip: 'Toggle Guide',
          icon: Icon(
            _wmController.showGrid.value ? Icons.grid_on : Icons.grid_off,
            color: _wmController.showGrid.value ? const Color(0xFF6366F1) : Colors.white,
            size: 28,
          ),
        )),
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.tune, color: Colors.white, size: 28),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            )
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _initCamera();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_isInitialized && _cameraController != null)
            Obx(() {
              final filter = _getColorFilter(_wmController.selectedFilter.value);
              return SizedBox.expand(
                child: filter != null
                    ? ColorFiltered(
                        colorFilter: filter,
                        child: CameraPreview(_cameraController!),
                      )
                    : CameraPreview(_cameraController!),
              );
            }),

          // Grid Overlay
          if (_isInitialized)
            Obx(() => _wmController.showGrid.value
                ? CustomPaint(
                    size: Size.infinite,
                    painter: GridOverlayPainter(),
                  )
                : const SizedBox.shrink()),

          // Filter Selection Bar
          if (_isInitialized)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 50,
                child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: CameraFilter.values.map((filter) {
                    final isSelected = _wmController.selectedFilter.value == filter;
                    return GestureDetector(
                      onTap: () => _wmController.selectFilter(filter),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6366F1) : Colors.white24,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getFilterName(filter),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
              ),
            ),

          // Bottom Action Bar
          if (_isInitialized)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery Button
                  GestureDetector(
                    onTap: _pickFromGallery,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Icon(Icons.photo_library, color: Colors.white, size: 28),
                    ),
                  ),
                  
                  // Capture Button
                  GestureDetector(
                    onTap: _capturePhoto,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white24, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Settings Button
                  GestureDetector(
                    onTap: _openSettings,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getFilterName(CameraFilter filter) {
    switch (filter) {
      case CameraFilter.none:
        return 'Normal';
      case CameraFilter.sepia:
        return 'Sepia';
      case CameraFilter.blackWhite:
        return 'B&W';
      case CameraFilter.vintage:
        return 'Vintage';
      case CameraFilter.cool:
        return 'Cool';
      case CameraFilter.warm:
        return 'Warm';
      case CameraFilter.vivid:
        return 'Vivid';
      case CameraFilter.blur:
        return 'Blur';
    }
  }
}

// Grid Overlay Painter for Rule of Thirds
class GridOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1;

    // Vertical lines (rule of thirds)
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(2 * size.width / 3, 0),
      Offset(2 * size.width / 3, size.height),
      paint,
    );

    // Horizontal lines (rule of thirds)
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, 2 * size.height / 3),
      Offset(size.width, 2 * size.height / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

