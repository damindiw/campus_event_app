import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/event_model.dart';
import '../admin/admin_panel_screen.dart';
import 'event_details_screen.dart';
import 'my_events_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Events"),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyEventsScreen()))),
          FutureBuilder(
            future: AuthService().getUserProfile(user?.uid ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.role == 'admin') {
                return IconButton(icon: const Icon(Icons.admin_panel_settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen())));
              }
              return const SizedBox();
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => AuthService().signOut())
        ],
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: DatabaseService().incomingEvents,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final item = events[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text(item.date),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsScreen(event: item))),
              );
            },
          );
        },
      ),
    );
  }
}