import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteEventScreen extends StatelessWidget {
  const DeleteEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Deleted Events Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Events').where('isDeleted', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Your trash log is completely clean! No deleted events found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index];
              return Card(
                color: Colors.red.shade50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: Text(data['eventName'], style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
                  subtitle: Text("Originally on: ${data['date']} at ${data['time']}\nLocation: ${data['location']}"),
                  trailing: TextButton.icon(
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: const Text('Restore'),
                    onPressed: () async {
                      // Instantly restores the event back to the live list
                      await FirebaseFirestore.instance.collection('Events').doc(data.id).update({'isDeleted': false});
                    },
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