import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<EventModel>> get incomingEvents {
    return _db.collection('Events').snapshots().map((snap) =>
      snap.docs.map((doc) => EventModel.fromMap(doc.data(), doc.id)).toList()
    );
  }

  Future<void> registerForEvent(String userId, String eventId) async {
    DocumentReference regRef = _db.collection('Registrations').doc();
    RegistrationModel reg = RegistrationModel(registrationId: regRef.id, userId: userId, eventId: eventId, attendanceStatus: 'absent');
    await regRef.set(reg.toMap());
  }

  Stream<List<EventModel>> getMyRegisteredEvents(String userId) {
    return _db.collection('Registrations').where('userId', isEqualTo: userId).snapshots().asyncMap((snapshot) async {
      List<EventModel> registeredDetails = [];
      for (var doc in snapshot.docs) {
        String eId = doc.data()['eventId'];
        DocumentSnapshot eDoc = await _db.collection('Events').doc(eId).get();
        if (eDoc.exists) {
          registeredDetails.add(EventModel.fromMap(eDoc.data() as Map<String, dynamic>, eDoc.id));
        }
      }
      return registeredDetails;
    });
  }
}