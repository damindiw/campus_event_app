import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/event_model.dart';
import '../../services/database_service.dart';
import 'qr_checkin_screen.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text("My Registered Events")),
      body: StreamBuilder<List<EventModel>>(
        stream: DatabaseService().getMyRegisteredEvents(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final event = list[index];
              return ListTile(
                title: Text(event.title),
                trailing: IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QRCheckInScreen(eventId: event.eventId, userId: uid))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}