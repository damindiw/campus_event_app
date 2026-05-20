import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EventDetailsScreen({super.key, required this.eventId, required this.eventData});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool _isAlreadyRegistered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  void _checkRegistrationStatus() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(_currentUid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        List<dynamic> registeredEvents = data['registeredEvents'] ?? [];
        if (registeredEvents.contains(widget.eventId)) {
          setState(() => _isAlreadyRegistered = true);
        }
      }
    } catch (e) {
      debugPrint("Error checking registration status: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _registerForEvent() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('Users').doc(_currentUid).set({
        'registeredEvents': FieldValue.arrayUnion([widget.eventId])
      }, SetOptions(merge: true));

      setState(() {
        _isAlreadyRegistered = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully Registered!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('EVENT DETAILS', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.eventData['eventName'] ?? 'Event Title',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                          const Divider(height: 30, thickness: 1.5),
                          _buildDetailRow(Icons.calendar_today, "Date: ${widget.eventData['date'] ?? 'N/A'}"),
                          _buildDetailRow(Icons.access_time, "Time: ${widget.eventData['time'] ?? 'N/A'}"),
                          _buildDetailRow(Icons.location_on, "Location: ${widget.eventData['location'] ?? 'N/A'}"),
                          const SizedBox(height: 24),
                          const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            widget.eventData['description'] ?? 'No description provided.',
                            style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isAlreadyRegistered ? null : _registerForEvent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isAlreadyRegistered ? Colors.white : Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                _isAlreadyRegistered ? 'Registered ✔' : 'Register Now',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}