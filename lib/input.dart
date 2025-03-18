import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'health_service.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<InputPage> {
  File? _selectedImage; // To store the selected image file
  String _analysisResult = "No analysis performed yet."; // To store the analysis result
  bool _isLoading = false; // To indicate loading state

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // Update the selected image
        _analysisResult = "Analyzing..."; // Reset the analysis result
      });
      _processImage(File(pickedFile.path)); // Process the image immediately
    } else {
      // Handle case where no image is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image selected.")),
      );
    }
  }

  Future<void> _processImage(File file) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFile(file);

    try {
      // Extract text from the image
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      // Pass the extracted text directly to the analysis function
      if (recognizedText.text.isNotEmpty) {
        _analyzeHealthReport(recognizedText.text);
      } else {
        setState(() {
          _analysisResult = "No text found in the image.";
        });
      }
    } catch (e) {
      // Handle errors during text recognition
      setState(() {
        _analysisResult = "Error recognizing text: $e";
      });
    } finally {
      textRecognizer.close(); // Close the text recognizer
    }
  }

  Future<void> _analyzeHealthReport(String text) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Analyze the health report using the AI service
      final predictedIssues = await TextAnalysisService.analyzeHealthReport(text);

      // Update the analysis result directly on this screen
      setState(() {
        _analysisResult = predictedIssues.trim();
      });
    } catch (e) {
      // Handle errors during analysis
      setState(() {
        _analysisResult = "Error analyzing report: $e";
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(""),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    "Health Analysis",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE57300), // Orange color
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Upload your \"Diagnosis Report\" to get the result.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFE57300), // Orange color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007AFF), // Blue color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Text(
                      "Upload",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Note:\n1. Upload in image format\n2. PDF Upcoming feature",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 20),
                  if (_selectedImage != null)
                    Image.file(_selectedImage!, height: 200),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Color(0xFFE57300)), // Orange color
                    ),
                  const SizedBox(height: 20),
                  Text(
                    "Analysis Result:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE57300), // Orange color
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _analysisResult,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}