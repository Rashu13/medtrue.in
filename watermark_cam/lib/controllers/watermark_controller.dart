import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

enum WatermarkPattern { grid, diagonal, center, corner, border, cross, diagonalGrid }

enum CameraFilter { none, sepia, blackWhite, vintage, cool, warm, vivid, blur }

class WatermarkController extends GetxController {
  final _box = GetStorage();

  // Observable state
  final watermarkText = 'My Watermark'.obs;
  final opacity = 0.3.obs;
  final fontSize = 30.0.obs;
  final watermarkColor = 0xFFFFFFFF.obs;
  final selectedPattern = WatermarkPattern.diagonalGrid.obs; // Default to X Grid
  final showGrid = false.obs;
  final selectedFilter = CameraFilter.none.obs;
  final logoPath = ''.obs; // For logo watermark

  @override
  void onInit() {
    super.onInit();
    // Load persisted settings
    watermarkText.value = _box.read('watermarkText') ?? 'StampIt';
    opacity.value = _box.read('opacity') ?? 0.3;
    fontSize.value = _box.read('fontSize') ?? 30.0;
    watermarkColor.value = _box.read('watermarkColor') ?? 0xFFFFFFFF;
    
    // Load pattern
    final savedPatternIndex = _box.read('selectedPattern');
    if (savedPatternIndex != null) {
      selectedPattern.value = WatermarkPattern.values[savedPatternIndex];
    }

    // Load logo path
    logoPath.value = _box.read('logoPath') ?? '';

    // Setup listeners to save changes
    ever(watermarkText, (v) => _box.write('watermarkText', v));
    ever(opacity, (v) => _box.write('opacity', v));
    ever(fontSize, (v) => _box.write('fontSize', v));
    ever(watermarkColor, (v) => _box.write('watermarkColor', v));
    ever(selectedPattern, (v) => _box.write('selectedPattern', v.index));
    ever(logoPath, (v) => _box.write('logoPath', v));
  }

  void updateText(String text) => watermarkText.value = text;
  void updateOpacity(double value) => opacity.value = value;
  void updateFontSize(double value) => fontSize.value = value;
  void updateColor(int colorValue) => watermarkColor.value = colorValue;
  void selectPattern(WatermarkPattern pattern) => selectedPattern.value = pattern;
  void toggleGrid() => showGrid.value = !showGrid.value;
  void selectFilter(CameraFilter filter) => selectedFilter.value = filter;

  Future<void> pickLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        logoPath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick logo: $e');
    }
  }

  void removeLogo() {
    logoPath.value = '';
  }
}
