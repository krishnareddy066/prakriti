import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'plant_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesPage extends StatefulWidget {
  final String userId; // Pass the user ID to retrieve the user's favorites

  FavoritesPage({required this.userId});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}
final userId = FirebaseAuth.instance.currentUser?.uid;
class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _favorites = [];
  bool _isRetrieving = false;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {

    setState(() {
      _isRetrieving = true;
    });

    try {
      final userDoc = await _firestore.collection('users').doc(widget.userId).get();

      if (userDoc.exists) {
        final favorites = List<String>.from(userDoc.data()?['favorites'] ?? []);

        final favoritesData = await Future.wait(favorites.map((plantName) async {
          final plantDetailsSnapshot = await _firestore
              .collection('plantDetails')
              .doc(plantName)
              .get();

          if (plantDetailsSnapshot.exists) {
            final plantData = plantDetailsSnapshot.data()!;
            final advantages = plantData['advantages'] as String? ?? '';
            final disadvantages = plantData['disadvantages'] as String? ?? '';
            final leaves = plantData['leafInfo'] as String? ?? '';
            final stems = plantData['stemInfo'] as String? ?? '';
            final latin = plantData['latinName'] as String? ?? '';

            return {
              'name': plantName,
              'details': '$advantages $disadvantages $leaves $stems $latin',
            };
          } else {
            return {
              'name': plantName,
              'details': 'No details available',
            };
          }
        }).toList());

        setState(() {
          _favorites = favoritesData;
          _isRetrieving = false;
        });
      } else {
        setState(() {
          _favorites = [];
          _isRetrieving = false;
        });
      }
    } catch (e) {
      print("Error fetching favorites: $e");
      setState(() {
        _isRetrieving = false;
      });
    }
  }


  String _getImageForHerb(String herbName) {
    switch (herbName.toLowerCase()) {
      case 'aloe vera':
        return 'assets/images/aloe_vera.png';  // Example image path
      case 'basil':
        return 'assets/images/basil.png';  // Example image path
      case 'turmeric':
        return 'assets/images/turmeric.png';
      case 'amla':
        return 'assets/images/amla.png';   // Example image path
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
    // Add more cases as needed for other herbs
      default:
        return 'assets/images/default_herb.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
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
            _isRetrieving
                ? Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
                : _favorites.isEmpty
                ? Center(
              child: Text(
                'No favorite plants found.',
                style: TextStyle(color: Colors.white),
              ),
            )
                : AnimationLimiter(
              child: ListView.builder(
                itemCount: _favorites.length,
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
                                    _getImageForHerb(_favorites[index]['name']!),
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                                title: Text(
                                  _favorites[index]['name']!,
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                ),
                                subtitle: Text(
                                  _favorites[index]['details']!,
                                  style: TextStyle(color: Colors.white70),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlantDetailPage(
                                        herbName: _favorites[index]['name']!,
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
          ],
        ),
      ),
    );
  }
}
