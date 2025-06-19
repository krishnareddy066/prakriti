import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Service for analyzing health reports using Gemini API
class TextAnalysisService {
  static const String apiKey = "AIzaSyAIOFLtY1fiDsgpM83lOhLBbyn26bBgiL8"; // Replace with your actual Gemini API key
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

  static Future<String> analyzeHealthReport(String text) async {
    int retryCount = 0;
    const maxRetries = 5;
    const baseDelay = 5;

    while (retryCount < maxRetries) {
      try {
        print("Attempt ${retryCount + 1}: Sending request to Gemini AI...");
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {
                    "text":
                    "You are a medical assistant. Extract and list only health issues from the provided medical report in a comma-separated format. Example: 'low blood pressure, high sugar, diabetes'. Here is the report: $text"
                  }
                ]
              }
            ]
          }),
        );

        print("API Response Status Code: ${response.statusCode}");
        print("API Response Body: ${response.body}");

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          return responseData['candidates'][0]['content']['parts'][0]['text'] ?? "No health issues detected.";
        } else if (response.statusCode == 429) {
          retryCount++;
          int delayInSeconds = baseDelay * (1 << retryCount);
          print("Rate limit exceeded. Retrying in $delayInSeconds seconds...");
          await Future.delayed(Duration(seconds: delayInSeconds));
        } else {
          throw Exception("Error analyzing health report. Status Code: ${response.statusCode}");
        }
      } catch (e) {
        throw Exception("Error: $e");
      }
    }

    throw Exception("Failed to analyze health report after $maxRetries attempts.");
  }
}

// Widget for displaying predicted health issues
class HealthIssuesPage extends StatelessWidget {
  final String predictedIssues;

  const HealthIssuesPage({super.key, required this.predictedIssues});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Predicted Health Issues"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Predicted Health Issues:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                predictedIssues,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}