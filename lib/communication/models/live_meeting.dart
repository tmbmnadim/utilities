class LiveMeeting {
  final String id;
  final String hostId;
  final List<String> participantIds;
  final String title;
  final DateTime? createdAt;
  final DateTime? endedAt;
  final List<String> participants;

  LiveMeeting({
    required this.id,
    required this.hostId,
    this.participantIds = const [],
    required this.title,
    required this.createdAt,
    required this.endedAt,
    required this.participants,
  });

  factory LiveMeeting.fromJson(Map<String, dynamic> json) {
    List<dynamic> participants = json['participantIds'];
    participants.removeWhere((e) => e == null);
    List<String> participantIds = List<String>.from(participants);
    participantIds.removeWhere((e) => e.isEmpty);
    return LiveMeeting(
      id: json['id'],
      hostId: json['host_id']??"N/A",
      participantIds: participantIds,
      title: json['title']??"N/A",
      createdAt: DateTime.tryParse(json['created_at']??"N/A"),
      endedAt: DateTime.tryParse(json['endedAt']??"N/A"),
      participants: List<String>.from(json['participants'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'host_id': hostId,
    'participantIds': participantIds,
    'startedAt': createdAt,
    'endedAt': endedAt,
    'participants': participants,
  };

  LiveMeeting copyWith({
    String? id,
    String? hostId,
    List<String>? participantIds,
    String? title,
    String? type,
    DateTime? createdAt,
    DateTime? endedAt,
    List<String>? participants,
  }) {
    return LiveMeeting(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      participantIds: participantIds ?? this.participantIds,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      participants: participants ?? this.participants,
    );
  }
}
