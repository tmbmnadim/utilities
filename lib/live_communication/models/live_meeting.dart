class LiveMeeting {
  final String id;
  final String name;
  final List<String> participants;

  LiveMeeting({required this.id, required this.name, required this.participants});

  factory LiveMeeting.fromJson(Map<String, dynamic> json) {
    return LiveMeeting(
      id: json['id'],
      name: json['name'],
      participants: List<String>.from(json['participants'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'participants': participants,
      };
}
