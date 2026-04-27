import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ImageTextOcrService {
  ImageTextOcrService._();

  static final ImagePicker _picker = ImagePicker();

  /// Opens camera/gallery, runs OCR, and returns plain extracted text.
  static Future<String> pickAndExtractText(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2200,
    );
    if (file == null) return '';

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(file.path);
      final recognizedText = await recognizer.processImage(inputImage);
      return recognizedText.text.trim();
    } catch (_) {
      return '';
    } finally {
      await recognizer.close();
    }
  }
}