import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'plant_detail_page.dart';
import 'chatbot_home.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _allPlants = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isRetrieving = false;
  bool _isSearching = false;

  // Speech-to-text instance
  late stt.SpeechToText _speech;
  bool _isListening = false; // Track listening state
  String _recognizedText = ""; // Store recognized text

  // Add a TextEditingController for text search
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _fetchAllPlants();

    // Initialize the TextEditingController
    _searchController = TextEditingController();

    // Initialize speech-to-text
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    // Dispose of the TextEditingController to avoid memory leaks
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllPlants() async {
    setState(() {
      _isRetrieving = true;
    });
    try {
      final snapshotPlantDetails = await _firestore.collection('plantDetails').get();
      final snapshotHealthcare = await _firestore.collection('healthcare').get();
      setState(() {
        // Fetch data from 'plantDetails'
        final plantDetails = snapshotPlantDetails.docs.map((doc) {
          final advantages = doc.data()['advantages'] as String? ?? '';
          final disadvantages = doc.data()['disadvantages'] as String? ?? '';
          final leaves = doc.data()['leafInfo'] as String? ?? '';
          final stems = doc.data()['stemInfo'] as String? ?? '';
          final latin = doc.data()['latinName'] as String? ?? '';
          return {
            'name': doc.id,
            'details': '$advantages $disadvantages $leaves $stems $latin',
          };
        }).toList();
        // Fetch data from 'healthcare'
        final healthcareDetails = snapshotHealthcare.docs.map((doc) {
          final List<dynamic> treat = doc.data()['treat'] as List<dynamic>? ?? [];
          return {
            'name': doc.id,
            'details': treat.join(', '),
          };
        }).toList();
        // Combine both collections
        _allPlants = [...plantDetails, ...healthcareDetails];
        _searchResults = _allPlants;
        _isRetrieving = false;
      });
    } catch (e) {
      print("Error fetching plants: $e");
      setState(() {
        _isRetrieving = false;
      });
    }
  }

  void _searchPlants(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        if (query.isEmpty) {
          _searchResults = _allPlants;
        } else {
          _searchResults = _allPlants
              .where((plant) =>
                  plant['name']!.toLowerCase().contains(query.toLowerCase()) ||
                  plant['details']!.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
        _isSearching = false;
      });
    });
  }

  // Start listening for voice input
  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords.toLowerCase();
            _searchController.text = _recognizedText; // Populate the search bar
            _searchPlants(_recognizedText); // Trigger search with recognized text
          });
        });
      } else {
        print("Speech recognition not available.");
      }
    }
  }

  // Stop listening
  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  String _getImageForHerb(String herbName) {
    switch (herbName.toLowerCase()) {
      case 'aloe vera':
        return 'assets/images/aloe_vera.png';
      case 'basil':
        return 'assets/images/basil.png';
      case 'turmeric':
        return 'assets/images/turmeric.png';
      case 'amla':
        return 'assets/images/amla.png';
      case 'brahmi':
        return 'assets/images/brahmi.png';
      case 'cardamom':
        return 'assets/images/cardamom.png';
      case 'eucalyptus':
        return 'assets/images/eucalyptus.png';
      case 'henna':
        return 'assets/images/henna.png';
      case 'licorice':
        return 'assets/images/licorice.png';
      case 'mullein':
        return 'assets/images/mullein.png';
      case 'neem':
        return 'assets/images/neem.png';
      case 'peppermint':
        return 'assets/images/peppermint.png';
      case 'thyme':
        return 'assets/images/thyme.png';
      case 'tulasi':
        return 'assets/images/tulasi.png';
      case 'alovera':
        return 'assets/images/aloe_vera.png';
      case 'triphala':
        return 'assets/images/triphala.png';
      case 'coconut':
        return 'assets/images/coconut.png';
      case 'ashawaganda':
        return 'assets/images/ashawaganda.png';
      case 'ginger':
        return 'assets/images/ginger.png';
      default:
        return 'assets/images/default_herb.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Plants',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.15,
                    child: SizedBox.expand(
                      child: Image.asset(
                        'assets/images/appbackgroundoptimize.gif',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.15),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController, // Use the TextEditingController
                          onChanged: _searchPlants,
                          decoration: InputDecoration(
                            hintText: 'Search for a plant or disease .....',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: _isSearching
                                ? Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.orange,
                                    ),
                                  )
                                : null,
                          ),
                          style: TextStyle(color: Colors.black),
                          cursorColor: Colors.orange,
                        ),
                      ),
                      IconButton(
                        onPressed: _isListening ? _stopListening : _startListening,
                        icon: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          color: _isListening ? Colors.red : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isRetrieving
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        )
                      : _searchResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No matching plants found.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatBotScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                    ),
                                    child: Text('Ask the Chatbot'),
                                  ),
                                ],
                              ),
                            )
                          : AnimationLimiter(
                              child: ListView.builder(
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 500),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              color: Color(0x33727272),
                                              child: ListTile(
                                                contentPadding: const EdgeInsets.symmetric(
                                                    vertical: 3.0, horizontal: 16.0),
                                                leading: CircleAvatar(
                                                  radius: 30,
                                                  backgroundImage: AssetImage(
                                                    _getImageForHerb(_searchResults[index]['name']!),
                                                  ),
                                                  backgroundColor: Colors.transparent,
                                                ),
                                                title: Text(
                                                  _searchResults[index]['name']!,
                                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                                ),
                                                subtitle: Text(
                                                  _searchResults[index]['details']!,
                                                  style: TextStyle(color: Colors.white70),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => PlantDetailPage(
                                                        herbName: _searchResults[index]['name']!,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}