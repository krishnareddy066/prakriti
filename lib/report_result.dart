import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'plant_detail_page.dart';
import 'expert_connect_page.dart'; // Import the new ExpertConnectPage
import 'package:shimmer/shimmer.dart';

class ReportResultPage extends StatefulWidget {
  final String analysisResult;

  const ReportResultPage({super.key, required this.analysisResult});

  @override
  _ReportResultPageState createState() => _ReportResultPageState();
}

class _ReportResultPageState extends State<ReportResultPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> diseases = [];
  Map<String, List<Map<String, dynamic>>> treatmentsWithDetails = {};
  bool _isFetchingTreatments = false;

  @override
  void initState() {
    super.initState();
    diseases = widget.analysisResult.split(',').map((disease) => disease.trim()).toList();
    _fetchTreatments();
  }

  Future<void> _fetchTreatments() async {
    setState(() {
      _isFetchingTreatments = true;
    });
    try {
      for (var disease in diseases) {
        final snapshot = await _firestore.collection('diseases').doc(disease).get();
        if (snapshot.exists) {
          final data = snapshot.data();
          final ayurvedicTreatments = data?['ayurvedic_treatments'] as List<dynamic>? ?? [];
          // Fetch details of each treatment from plantDetails collection
          List<Map<String, dynamic>> detailedTreatments = [];
          for (var treatment in ayurvedicTreatments) {
            final plantSnapshot = await _firestore.collection('plantDetails').doc(treatment).get();
            if (plantSnapshot.exists) {
              final plantData = plantSnapshot.data()!;
              detailedTreatments.add({
                'name': treatment,
                'details': plantData['advantages'] ?? '',
              });
            }
          }
          treatmentsWithDetails[disease] = detailedTreatments;
        }
      }
    } catch (e) {
      print("Error fetching treatments: $e");
    } finally {
      setState(() {
        _isFetchingTreatments = false;
      });
    }
  }

  String _getImageForHerb(String herbName) {
    // Check herbName and return the appropriate image path
    switch (herbName.toLowerCase()) {
      case 'aloe vera':
        return 'assets/images/aloe_vera.png'; // Example image path
      case 'basil':
        return 'assets/images/basil.png'; // Example image path
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
        return 'assets/images/default_herb.png'; // Default image if herb name doesn't match
    }
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[700]!,
      highlightColor: Colors.grey[300]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 3, // Simulate 3 disease cards
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: double.infinity, // Span the entire screen width
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 2, // Simulate 2 treatments per disease
                  itemBuilder: (context, idx) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 15,
                                width: MediaQuery.of(context).size.width * 0.7, // Adjust width
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                height: 10,
                                width: MediaQuery.of(context).size.width * 0.5, // Adjust width
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Results",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange, // Brighter color
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "List of Diseases",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE57300), // Orange color
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isFetchingTreatments
                    ? _buildShimmerLoader()
                    : AnimationLimiter(
                  child: Column(
                    children: diseases.map((disease) {
                      return AnimationConfiguration.staggeredList(
                        position: diseases.indexOf(disease),
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: DiseaseCard(
                              key: ValueKey(disease),
                              disease: disease,
                              treatments: treatmentsWithDetails[disease] ?? [],
                              getImageForHerb: _getImageForHerb,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the ExpertConnectPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpertConnectPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE57300), // Orange color
                ),
                child: const Text("Connect to Expert"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiseaseCard extends StatelessWidget {
  final String disease;
  final List<Map<String, dynamic>> treatments;
  final String Function(String herbName) getImageForHerb;

  const DiseaseCard({
    super.key,
    required this.disease,
    required this.treatments,
    required this.getImageForHerb,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Disease: $disease",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Treatments",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: treatments.length,
          itemBuilder: (context, index) {
            final treatment = treatments[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Color(0x33727272),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 16.0),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(getImageForHerb(treatment['name'])),
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text(
                      treatment['name'],
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    subtitle: Text(
                      treatment['details'],
                      style: TextStyle(color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlantDetailPage(
                            herbName: treatment['name'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}