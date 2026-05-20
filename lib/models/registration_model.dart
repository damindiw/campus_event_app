class RegistrationModel {
  final String registrationId;
  final String userId;
  final String eventId;
  final String attendanceStatus; // 'absent' or 'present'

  RegistrationModel({
    required this.registrationId, required this.userId,
    required this.eventId, required this.attendanceStatus,
  });

  factory RegistrationModel.fromMap(Map<String, dynamic> map, String id) {
    return RegistrationModel(
      registrationId: id,
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      attendanceStatus: map['attendanceStatus'] ?? 'absent',
    );
  }

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'eventId': eventId, 'attendanceStatus': attendanceStatus};
  }
}