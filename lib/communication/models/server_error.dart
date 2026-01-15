import 'dart:io';

class WebRTCServerException extends IOException {
  String? type;
  Data? data;

  WebRTCServerException({this.type, this.data});

  WebRTCServerException.fromJson(Map<String, dynamic> json) {
    if (json['type'] != null) {
      type = json['type'];
      data = json['data'] != null ? Data.fromJson(json['data']) : null;
    } else if (json['message'] != null) {
      type = 'unknown';
      data = Data(message: json['message']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? message;

  Data({this.message});

  Data.fromJson(Map<String, dynamic> json) {
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    return data;
  }
}
