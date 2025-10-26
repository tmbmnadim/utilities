class WSMessage<T> {
  final String type;
  final T data;

  WSMessage({required this.type, required this.data});

  factory WSMessage.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return WSMessage(
      type: json['type'],
      data: fromJsonT(json['data']),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) => {
        'type': type,
        'data': toJsonT(data),
      };
}
