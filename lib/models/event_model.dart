class EventModel {
  final String eventId;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String imageUrl;

  EventModel({
    required this.eventId, required this.title, required this.description,
    required this.date, required this.time, required this.location, required this.imageUrl,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      eventId: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title, 'description': description, 'date': date,
      'time': time, 'location': location, 'imageUrl': imageUrl,
    };
  }
}