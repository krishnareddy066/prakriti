import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExpertConnectPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect to Experts"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('experts').snapshots(), // Listen to the 'experts' collection
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching data
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Handle errors gracefully
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Display a message if no experts are available
            return const Center(child: Text("No experts available."));
          }

          // Extract the list of experts from the snapshot
          final expertList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: expertList.length,
            itemBuilder: (context, index) {
              // Get the expert data as a map
              final expertData = expertList[index].data() as Map<String, dynamic>;
              final expertName = expertData['name'] ?? 'Unknown Expert';
              final expertSpecialization = expertData['specialization'] ?? 'Not specified';
              final expertContact = expertData['contact'] ?? 'Not available';
              final expertEmail = expertData['email'] ?? 'Not available';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(expertName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Specialization: $expertSpecialization"),
                      Text("Contact: $expertContact"),
                      Text("Email: $expertEmail"),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Implement chat/call functionality here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Connecting with $expertName...")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text("Connect"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}