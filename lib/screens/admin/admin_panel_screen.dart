import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _loc = TextEditingController();
  final _date = TextEditingController();
  final _time = TextEditingController();

  void _save() async {
    await FirebaseFirestore.instance.collection('Events').add({
      'title': _title.text.trim(), 'description': _desc.text.trim(),
      'location': _loc.text.trim(), 'date': _date.text.trim(),
      'time': _time.text.trim(), 'imageUrl': '',
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Campus Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: _loc, decoration: const InputDecoration(labelText: "Location")),
            TextField(controller: _date, decoration: const InputDecoration(labelText: "Date")),
            TextField(controller: _time, decoration: const InputDecoration(labelText: "Time")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text("Publish Event"))
          ],
        ),
      ),
    );
  }
}