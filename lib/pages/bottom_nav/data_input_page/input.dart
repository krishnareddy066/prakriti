import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'health_service.dart';

class Input extends StatefulWidget {
  const Input({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Input> {
  File? _selectedImage;
  String _extractedText = "No text recognized.";
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      _extractText(File(pickedFile.path));
    } else {
      setState(() {
        _extractedText = "No image selected.";
      });
    }
  }

  Future<void> _extractText(File file) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFile(file);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text.isNotEmpty
            ? recognizedText.text
            : "No text found. Try another image.";
      });

      // Call AI to analyze the extracted text
      _analyzeHealthReport(_extractedText);
    } catch (e) {
      setState(() {
        _extractedText = "Error recognizing text: $e";
      });
    } finally {
      textRecognizer.close();
    }
  }

  Future<void> _analyzeHealthReport(String text) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final predictedIssues = await TextAnalysisService.analyzeHealthReport(text);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HealthIssuesPage(predictedIssues: predictedIssues.trim()),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Analysis"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : const Text(
              "No Image Selected",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              "Extracted Text:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _extractedText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}