import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ProfilePhotoService {
  static final ImagePicker _picker = ImagePicker();

  /// Lets the user pick a photo, compresses/resizes it to keep it small
  /// (so it fits comfortably inside a Firestore document), and returns
  /// it as a Base64 string ready to save. Returns null if the user cancels.
  static Future<String?> pickAndEncode({required bool fromCamera}) async {
    final XFile? picked = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return null;

    final Uint8List rawBytes = await picked.readAsBytes();

    // Decode, resize down to a small square, and re-encode as JPEG
    // to keep the final size well under Firestore's 1MB document limit.
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) return null;

    final resized = img.copyResizeCropSquare(decoded, size: 240);
    final compressedBytes = img.encodeJpg(resized, quality: 70);

    return base64Encode(compressedBytes);
  }
}