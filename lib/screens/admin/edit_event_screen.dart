import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEventScreen extends StatelessWidget {
  const EditEventScreen({super.key});

  void _showEditDialog(BuildContext context, DocumentSnapshot doc) {
    final nameCtrl = TextEditingController(text: doc['eventName']);
    final locCtrl = TextEditingController(text: doc['location']);
    final descCtrl = TextEditingController(text: doc['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Event Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Event Name')),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('Events').doc(doc.id).update({
                'eventName': nameCtrl.text.trim(),
                'location': locCtrl.text.trim(),
                'description': descCtrl.text.trim(),
              });
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Save Modifications'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('Edit Active Events', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Events').where('isDeleted', isEqualTo: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No active events found. Try adding some inside your portal!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.event, color: Colors.amber),
                  title: Text(data['eventName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${data['date']} @ ${data['time']} \nPlace: ${data['location']}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(context, data)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          // Flagging as true preserves records for your view panel
                          await FirebaseFirestore.instance.collection('Events').doc(data.id).update({'isDeleted': true});
                        },
                      ),
                    ],
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