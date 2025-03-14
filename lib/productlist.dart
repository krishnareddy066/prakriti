import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AmazonProductsPage extends StatefulWidget {
  @override
  _AmazonProductsPageState createState() => _AmazonProductsPageState();
}

class _AmazonProductsPageState extends State<AmazonProductsPage> {
  final List<Map<String, String>> products = [
    {
      'name': 'Aloe Vera',
      'image': 'assets/images/aloe_vera.png',
      'url': 'https://www.amazon.in/s?k=aloe+vera',
    },
    {
      'name': 'Amla',
      'image': 'assets/images/amla.png',
      'url': 'https://www.amazon.in/s?k=amla',
    },
    {
      'name': 'Ashwagandha',
      'image': 'assets/images/ashawaganda.png',
      'url': 'https://www.amazon.in/s?k=ashwagandha',
    },
    {
      'name': 'Brahmi',
      'image': 'assets/images/brahmi.png',
      'url': 'https://www.amazon.in/s?k=brahmi',
    },
    {
      'name': 'Cardamom',
      'image': 'assets/images/cardamom.png',
      'url': 'https://www.amazon.in/s?k=cardamom',
    },
    {
      'name': 'Coconut',
      'image': 'assets/images/coconut.png',
      'url': 'https://www.amazon.in/s?k=coconut',
    },
    {
      'name': 'Eucalyptus',
      'image': 'assets/images/eucalyptus.png',
      'url': 'https://www.amazon.in/s?k=eucalyptus',
    },
    {
      'name': 'Ginger',
      'image': 'assets/images/ginger.png',
      'url': 'https://www.amazon.in/s?k=ginger',
    },
    {
      'name': 'Henna',
      'image': 'assets/images/henna.png',
      'url': 'https://www.amazon.in/s?k=henna',
    },
    {
      'name': 'Licorice',
      'image': 'assets/images/licorice.png',
      'url': 'https://www.amazon.in/s?k=licorice',
    },
    {
      'name': 'Mullein',
      'image': 'assets/images/mullein.png',
      'url': 'https://www.amazon.in/s?k=mullein',
    },
    {
      'name': 'Neem',
      'image': 'assets/images/neem.png',
      'url': 'https://www.amazon.in/s?k=neem',
    },
    {
      'name': 'Peppermint',
      'image': 'assets/images/peppermint.png',
      'url': 'https://www.amazon.in/s?k=peppermint',
    },
    {
      'name': 'Thyme',
      'image': 'assets/images/thyme.png',
      'url': 'https://www.amazon.in/s?k=thyme',
    },
    {
      'name': 'Triphala',
      'image': 'assets/images/triphala.png',
      'url': 'https://www.amazon.in/s?k=triphala',
    },
    {
      'name': 'Tulasi',
      'image': 'assets/images/tulasi.png',
      'url': 'https://www.amazon.in/s?k=tulasi',
    },
    {
      'name': 'Turmeric',
      'image': 'assets/images/turmeric.png',
      'url': 'https://www.amazon.in/s?k=turmeric',
    },
  ];

  List<Map<String, String>> displayedProducts = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedProducts = List.from(products); // Initialize with all products
  }

  void _openAmazonLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open $url';
    }
  }

  void _filterProducts(String query) {
    setState(() {
      displayedProducts = products
          .where((product) =>
          product['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ayurvedic Products',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background GIF
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/appbackgroundoptimize.gif',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Products...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _filterProducts,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: displayedProducts.length,
                  itemBuilder: (context, index) {
                    final product = displayedProducts[index];

                    return GestureDetector(
                      onTap: () => _openAmazonLink(product['url']!),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15)),
                                child: Image.asset(
                                  product['image']!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product['name']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}