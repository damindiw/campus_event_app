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

  // Verifies if this student has already clicked register previously
  void _checkRegistrationStatus() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(_currentUid).get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        List<dynamic> registeredEvents = data['registeredEvents'] ?? [];
        if (registeredEvents.contains(widget.eventId)) {
          setState(() {
            _isAlreadyRegistered = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking registration status: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handles updating the student array inside Firestore securely and returns to the home feed
  void _registerForEvent() async {
    setState(() => _isLoading = true);

    try {
      // Set with merge handles fields safely even if 'registeredEvents' doesn't exist yet
      await FirebaseFirestore.instance.collection('Users').doc(_currentUid).set({
        'registeredEvents': FieldValue.arrayUnion([widget.eventId])
      }, SetOptions(merge: true));

      setState(() {
        _isAlreadyRegistered = true;
        _isLoading = false;
      });

      if (mounted) {
        // 1. Show a quick confirmation message to the student
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully Registered for this Event!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // 2. Automatically navigate back to the home screen showing upcoming events
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('EVENT DETAILS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.eventData['eventName'] ?? widget.eventData['eventName'] ?? 'eventName',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const SizedBox(height: 16),
                      Text('Date: ${widget.eventData['date'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Time: ${widget.eventData['time'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Location: ${widget.eventData['location'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      const Text('Description:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        widget.eventData['description'] ?? 'No description provided.',
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          onPressed: _isAlreadyRegistered ? null : _registerForEvent,
                          child: Text(
                            _isAlreadyRegistered ? 'Registered ✔' : '[ Register ]',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isAlreadyRegistered ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}