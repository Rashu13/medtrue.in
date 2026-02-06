import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/watermark_controller.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WatermarkController>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Watermark Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Watermark Text
            const Text('Watermark Text', style: TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 8),
            Obx(() => TextField(
              onChanged: controller.updateText,
              controller: TextEditingController(text: controller.watermarkText.value)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.watermarkText.value.length),
                ),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter watermark text...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
            )),
            const SizedBox(height: 16),
            
            // Logo Selection
            const Text('Watermark Logo', style: TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 8),
            Obx(() => Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: controller.pickLogo,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.image, color: Colors.white60, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.logoPath.value.isEmpty 
                                  ? 'Select Logo (Optional)' 
                                  : 'Logo Selected',
                              style: TextStyle(
                                color: controller.logoPath.value.isEmpty ? Colors.white60 : Colors.white,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (controller.logoPath.value.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: controller.removeLogo,
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    tooltip: 'Remove Logo',
                  ),
                ],
              ],
            )),
            const SizedBox(height: 20),

            // Pattern Selection
            const Text('Pattern Style', style: TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PatternButton(
                  label: 'Grid',
                  icon: Icons.grid_on,
                  isSelected: controller.selectedPattern.value == WatermarkPattern.grid,
                  onTap: () => controller.selectPattern(WatermarkPattern.grid),
                ),
                _PatternButton(
                  label: 'Diagonal',
                  icon: Icons.trending_up,
                  isSelected: controller.selectedPattern.value == WatermarkPattern.diagonal,
                  onTap: () => controller.selectPattern(WatermarkPattern.diagonal),
                ),
                _PatternButton(
                  label: 'Center',
                  icon: Icons.center_focus_strong,
                  isSelected: controller.selectedPattern.value == WatermarkPattern.center,
                  onTap: () => controller.selectPattern(WatermarkPattern.center),
                ),
                _PatternButton(
                  label: 'Corner',
                  icon: Icons.crop_square,
                  isSelected: controller.selectedPattern.value == WatermarkPattern.corner,
                  onTap: () => controller.selectPattern(WatermarkPattern.corner),
                ),
                _PatternButton(
                  label: 'Border',
                  icon: Icons.border_all,
                  isSelected: controller.selectedPattern.value == WatermarkPattern.border,
                  onTap: () => controller.selectPattern(WatermarkPattern.border),
                ),
                _PatternButton(
                  label: 'Cross',
                  icon: Icons.add,
                  isSelected: controller.selectedPattern.value == WatermarkPattern.cross,
                  onTap: () => controller.selectPattern(WatermarkPattern.cross),
                ),
                _PatternButton(
                  label: 'X Grid',
                  icon: Icons.close,
                  isSelected: controller.selectedPattern.value == WatermarkPattern.diagonalGrid,
                  onTap: () => controller.selectPattern(WatermarkPattern.diagonalGrid),
                ),
              ],
            )),
            const SizedBox(height: 20),

            // Opacity Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Opacity', style: TextStyle(color: Colors.white60, fontSize: 14)),
                Obx(() => Text(
                  '${(controller.opacity.value * 100).toInt()}%',
                  style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600),
                )),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF6366F1),
                inactiveTrackColor: Colors.white12,
                thumbColor: Colors.white,
                overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
              ),
              child: Slider(
                value: controller.opacity.value,
                min: 0.1,
                max: 1.0,
                onChanged: controller.updateOpacity,
              ),
            )),
            const SizedBox(height: 16),

            // Font Size Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Watermark Size', style: TextStyle(color: Colors.white60, fontSize: 14)),
                Obx(() => Text(
                  '${controller.fontSize.value.toInt()}px',
                  style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600),
                )),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF6366F1),
                inactiveTrackColor: Colors.white12,
                thumbColor: Colors.white,
                overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
              ),
              child: Slider(
                value: controller.fontSize.value,
                min: 5,
                max: 100,
                onChanged: controller.updateFontSize,
              ),
            )),
            const SizedBox(height: 24),

            // Done Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PatternButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PatternButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 95,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white60, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
