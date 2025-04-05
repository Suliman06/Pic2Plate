import 'dart:io';
import 'dart:convert';
import 'secrets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class VisionService {
  static VisionService? _instance;
  final String apiKey;
  final ImagePicker _picker = ImagePicker();

  VisionService({required this.apiKey});

  /// Picks an image from the camera.
  Future<File?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    return null;
  }

  /// Converts the image file to a base64 encoded string.
  Future<String> _getBase64Image(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  /// Sends the image to the Google Cloud Vision API for label detection.
  /// Returns a list of label descriptions.
  Future<List<String>> detectLabels(File imageFile) async {
    final base64Image = await _getBase64Image(imageFile);

    final url = 'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';

    final requestPayload = {
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {"type": "LABEL_DETECTION", "maxResults": 10}
          ]
        }
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestPayload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic>? responses = data["responses"];
      if (responses != null && responses.isNotEmpty) {
        final annotations = responses[0]["labelAnnotations"];
        if (annotations != null) {
          List<String> labels = [];
          for (var annotation in annotations) {
            if (annotation["description"] != null) {
              labels.add(annotation["description"]);
            }
          }
          return labels;
        }
      }
    } else {
      print("Google Cloud Vision API error: ${response.statusCode} ${response.body}");
    }
    return [];
  }
}
