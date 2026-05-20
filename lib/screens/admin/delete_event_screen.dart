import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteEventScreen extends StatelessWidget {
  const DeleteEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('Deleted Events Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Events').where('isDeleted', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) return const Center(child: Text('Data error encountered.'));
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Your trash log is completely clean! No deleted events found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              
              return Card(
                color: Colors.red.shade50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: Text(
                    data['eventName'] ?? 'Untitled Event', 
                    style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough),
                  ),
                  subtitle: Text(
                    "Originally on: ${data['date'] ?? 'N/A'} at ${data['time'] ?? 'N/A'}\nLocation: ${data['location'] ?? 'N/A'}"
                  ),
                  trailing: TextButton.icon(
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: const Text('Restore'),
                    onPressed: () async {
                      // Instantly restores the event back to the live list
                      await FirebaseFirestore.instance.collection('Events').doc(doc.id).update({'isDeleted': false});
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