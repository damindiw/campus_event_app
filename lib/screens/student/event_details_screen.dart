import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/event_model.dart';
import '../../services/database_service.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Location: ${event.location}"),
            Text("Date: ${event.date} at ${event.time}"),
            const SizedBox(height: 20),
            Text(event.description),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  await DatabaseService().registerForEvent(uid, event.eventId);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("Register"),
            )
          ],
        ),
      ),
    );
  }
}