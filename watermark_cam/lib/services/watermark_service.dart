import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;
import '../controllers/watermark_controller.dart';

class WatermarkService {
  /// Apply watermark to image bytes
  static Future<Uint8List?> applyWatermark({
    required Uint8List imageBytes,
    required String text,
    required WatermarkPattern pattern,
    required double opacity,
    required double fontSize,
    required int colorValue,
    CameraFilter filter = CameraFilter.none,
    String? logoPath,
  }) async {
    try {
      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Apply filter first
      image = _applyFilter(image, filter);

      // Resize image to max 1920 width to prevent OOM
      if (image.width > 1920) {
        image = img.copyResize(image, width: 1920);
      }

      // Calculate font size based on image dimensions
      int scaledFontSize = (fontSize * image.width / 400).round();
      if (scaledFontSize < 16) scaledFontSize = 16;

      // Get color with opacity
      int r = (colorValue >> 16) & 0xFF;
      int g = (colorValue >> 8) & 0xFF;
      int b = colorValue & 0xFF;
      int a = (opacity * 255).round();
      
      img.Color watermarkColor = img.ColorRgba8(r, g, b, a);

      // Load and resize logo if available
      img.Image? logo;
      if (logoPath != null && logoPath.isNotEmpty) {
        try {
          final logoBytes = await File(logoPath).readAsBytes();
          img.Image? originalLogo = img.decodeImage(logoBytes);
          if (originalLogo != null) {
            // Resize logo to match text height
            int targetHeight = (scaledFontSize * 2.0).toInt(); // Increased size
            logo = img.copyResize(originalLogo, height: targetHeight);
            
            // Apply opacity to logo
            for (var pixel in logo) {
              pixel.a = (pixel.a * opacity).toInt();
            }
          }
        } catch (e) {
          print('Error loading logo: $e');
        }
      }

      switch (pattern) {
        case WatermarkPattern.center:
          _drawCenterWatermark(image, text, watermarkColor, scaledFontSize, logo);
          break;
        case WatermarkPattern.grid:
          _drawGridWatermark(image, text, watermarkColor, scaledFontSize, logo);
          break;
        case WatermarkPattern.diagonal:
          _drawDiagonalWatermark(image, text, watermarkColor, scaledFontSize, logo);
          break;
        case WatermarkPattern.corner:
          _drawCornerWatermark(image, text, watermarkColor, scaledFontSize, logo);
          break;
        case WatermarkPattern.border:
          _drawBorderWatermark(image, text, watermarkColor, scaledFontSize, logo);
          break;
        case WatermarkPattern.cross:
          _drawCrossWatermark(image, text, watermarkColor, scaledFontSize, logo);
          break;
        case WatermarkPattern.diagonalGrid:
          _drawDiagonalGridWatermark(image, text, watermarkColor, scaledFontSize, logo);
          break;
      }

      // Encode back to PNG
      return Uint8List.fromList(img.encodePng(image));
    } catch (e) {
      print('Error applying watermark: $e');
      return null;
    }
  }

  static img.Image _applyFilter(img.Image image, CameraFilter filter) {
    switch (filter) {
      case CameraFilter.none:
        return image;
      case CameraFilter.sepia:
        return img.sepia(image);
      case CameraFilter.blackWhite:
        return img.grayscale(image);
      case CameraFilter.vintage:
        img.Image result = img.sepia(image);
        return img.adjustColor(result, contrast: 0.9, brightness: 0.95);
      case CameraFilter.cool:
        return img.adjustColor(image, hue: 0.1, saturation: 1.1);
      case CameraFilter.warm:
        return img.adjustColor(image, hue: -0.05, saturation: 1.15);
      case CameraFilter.vivid:
        return img.adjustColor(image, saturation: 1.5, contrast: 1.2);
      case CameraFilter.blur:
        return img.gaussianBlur(image, radius: 3);
    }
  }

  /// Helper to draw Content (Text + Optional Logo)
  static void _drawContent(img.Image image, String text, img.BitmapFont font, int x, int y, img.Color color, img.Image? logo) {
    int currentX = x;
    
    // Draw Logo
    if (logo != null) {
      // Center logo vertically relative to text
      // Font height approx 48 for arial48? No, we pass font.
      // But we resized logo to fit.
      // Simply draw logo at x, y - (logo.height/4) to center?
      // Text usually draws from top-left.
      img.compositeImage(image, logo, dstX: currentX, dstY: y - (logo.height ~/ 6));
      currentX += logo.width + 10;
    }

    // Draw Text
    if (text.isNotEmpty) {
      img.drawString(image, text, font: font, x: currentX, y: y, color: color);
    }
  }

  static void _drawCenterWatermark(img.Image image, String text, img.Color color, int fontSize, img.Image? logo) {
    int textWidth = text.length * fontSize ~/ 2;
    int contentWidth = textWidth + (logo != null ? logo.width + 10 : 0);
    
    _drawContent(
      image, 
      text, 
      img.arial48, 
      (image.width ~/ 2) - (contentWidth ~/ 2), 
      image.height ~/ 2, 
      color, 
      logo
    );
  }

  static void _drawGridWatermark(img.Image image, String text, img.Color color, int fontSize, img.Image? logo) {
    int textWidth = text.length * fontSize ~/ 2;
    int contentWidth = textWidth + (logo != null ? logo.width + 10 : 0);
    int stepX = contentWidth + 100;
    int stepY = fontSize + 100;
    
    for (int x = 0; x < image.width; x += stepX) {
      for (int y = 0; y < image.height; y += stepY) {
        _drawContent(image, text, img.arial48, x, y, color, logo);
      }
    }
  }

  static void _drawDiagonalWatermark(img.Image image, String text, img.Color color, int fontSize, img.Image? logo) {
    int textWidth = text.length * fontSize ~/ 2;
    int contentWidth = textWidth + (logo != null ? logo.width + 10 : 0);
    int stepX = contentWidth + 80;
    int diagonalLines = (image.width + image.height) ~/ stepX + 2;
    
    for (int i = 0; i < diagonalLines; i++) {
      int startX = -image.height + (i * stepX);
      int startY = image.height ~/ 2;
      _drawContent(image, text, img.arial48, startX, startY, color, logo);
    }
  }

  static void _drawCornerWatermark(img.Image image, String text, img.Color color, int fontSize, img.Image? logo) {
    int padding = 20;
    int textWidth = text.length * fontSize ~/ 2;
    int contentWidth = textWidth + (logo != null ? logo.width + 10 : 0);
    
    // Top-left
    _drawContent(image, text, img.arial48, padding, padding, color, logo);
    // Top-right
    _drawContent(image, text, img.arial48, image.width - contentWidth - padding, padding, color, logo);
    // Bottom-left
    _drawContent(image, text, img.arial48, padding, image.height - fontSize - padding, color, logo);
    // Bottom-right
    _drawContent(image, text, img.arial48, image.width - contentWidth - padding, image.height - fontSize - padding, color, logo);
  }

  static void _drawBorderWatermark(img.Image image, String text, img.Color color, int fontSize, img.Image? logo) {
    int textWidth = text.length * fontSize ~/ 2;
    int contentWidth = textWidth + (logo != null ? logo.width + 10 : 0);
    int spacing = contentWidth + 50;
    
    // Top edge
    for (int x = 0; x < image.width; x += spacing) {
      _drawContent(image, text, img.arial48, x, 10, color, logo);
    }
    // Bottom edge
    for (int x = 0; x < image.width; x += spacing) {
      _drawContent(image, text, img.arial48, x, image.height - fontSize - 10, color, logo);
    }
    // Left edge (Vertical is tricky with horizontal text, keep logic simple)
    // Just draw text for vertical edges for now to maintain readability, or use just text?
    // Let's use _drawContent but it draws horizontally.
    for (int y = fontSize + 50; y < image.height - fontSize - 50; y += fontSize + 30) {
      _drawContent(image, text, img.arial48, 10, y, color, logo);
    }
    // Right edge
    for (int y = fontSize + 50; y < image.height - fontSize - 50; y += fontSize + 30) {
      _drawContent(image, text, img.arial48, image.width - contentWidth - 10, y, color, logo);
    }
  }

  static void _drawCrossWatermark(img.Image image, String text, img.Color color, int fontSize, img.Image? logo) {
    int textWidth = text.length * fontSize ~/ 2;
    int contentWidth = textWidth + (logo != null ? logo.width + 10 : 0);
    int spacing = contentWidth + 60;
    
    // Horizontal center line
    int centerY = image.height ~/ 2;
    for (int x = 0; x < image.width; x += spacing) {
      _drawContent(image, text, img.arial48, x, centerY, color, logo);
    }
    
    // Vertical center line
    // Centering vertically drawn horizontal text
    int centerX = (image.width ~/ 2) - (contentWidth ~/ 2);
    for (int y = 0; y < image.height; y += fontSize + 40) {
      _drawContent(image, text, img.arial48, centerX, y, color, logo);
    }
  }

  // Diagonal Grid (X pattern) watermark like Canva
  static void _drawDiagonalGridWatermark(img.Image image, String text, img.Color color, int fontSize, img.Image? logo) {
    int textWidth = text.length * fontSize ~/ 2;
    int contentWidth = textWidth + (logo != null ? logo.width + 20 : 0);
    
    // Increased spacing significantly for clean Canva-like look
    int spacingX = contentWidth + 200; 
    int spacingY = fontSize + 200;
    
    // Draw watermarks along both diagonals creating X pattern
    for (int row = 0; row < (image.height ~/ spacingY) + 2; row++) {
      for (int col = 0; col < (image.width ~/ spacingX) + 2; col++) {
        // Top-left to bottom-right diagonal offset
        int x1 = (col * spacingX) + (row * 60) - spacingX;
        int y1 = row * spacingY;
        if (x1 >= -contentWidth && x1 < image.width && y1 >= 0 && y1 < image.height) {
          _drawContent(image, text, img.arial48, x1, y1, color, logo);
        }
        
        // Top-right to bottom-left diagonal offset
        int x2 = image.width - (col * spacingX) - (row * 60);
        int y2 = row * spacingY;
        if (x2 >= -contentWidth && x2 < image.width && y2 >= 0 && y2 < image.height) {
          _drawContent(image, text, img.arial48, x2, y2, color, logo);
        }
      }
    }
  }
}

