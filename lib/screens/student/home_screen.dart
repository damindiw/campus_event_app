import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // 0 = Upcoming Events, 1 = My Registered Events
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Upcoming Events' : 'My Registered Events',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        // REMOVED THE FAULTY LEADING ICON BUTTON SO NAVIGATION HISTORY STAYS CLEAN
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          )
        ],
      ),
      body: _currentIndex == 0 ? _buildAllEventsTab() : _buildRegisteredEventsTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Upcoming',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_rounded),
            label: 'Registered',
          ),
        ],
      ),
    );
  }

  // TAB 1: Display all events posted by the admin (Filtering out deleted ones)
  Widget _buildAllEventsTab() {
    return StreamBuilder<QuerySnapshot>(
      // Filters database snapshots in real-time to ignore any item tagged as soft-deleted
      stream: FirebaseFirestore.instance
          .collection('Events')
          .where('isDeleted', isNotEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No upcoming events listed yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            return _buildEventCard(doc.id, data);
          },
        );
      },
    );
  }

  // TAB 2: Filter and display only events the current student registered for
  Widget _buildRegisteredEventsTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(_currentUid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text('No registrations found.'));
        }

        Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> registeredIds = userData['registeredEvents'] ?? [];

        if (registeredIds.isEmpty) {
          return const Center(child: Text('You haven\'t registered for any events yet.'));
        }

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('Events')
              .where(FieldPath.documentId, whereIn: registeredIds)
              .get(),
          builder: (context, eventSnapshot) {
            if (eventSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!eventSnapshot.hasData || eventSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Registered events data unavailable.'));
            }

            // Client-side filter fallback ensuring even registered views hide soft-deleted events
            var liveRegisteredDocs = eventSnapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return data['isDeleted'] != true;
            }).toList();

            if (liveRegisteredDocs.isEmpty) {
              return const Center(child: Text('You haven\'t registered for any active events yet.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: liveRegisteredDocs.length,
              itemBuilder: (context, index) {
                var doc = liveRegisteredDocs[index];
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                return _buildEventCard(doc.id, data);
              },
            );
          },
        );
      },
    );
  }

  // Common UI helper component for drawing matching event layout cards
  Widget _buildEventCard(String docId, Map<String, dynamic> data) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['eventName'] ?? 'Untitled Event',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 6),
            Text('Date: ${data['date'] ?? 'N/A'}', style: TextStyle(color: Colors.grey.shade700)),
            Text('Location: ${data['location'] ?? 'N/A'}', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(eventId: docId, eventData: data),
                    ),
                  );
                },
                child: const Text('[View Details]', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
            )
          ],
        ),
      ),
    );
  }
}