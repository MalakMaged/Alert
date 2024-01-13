import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'constants.dart';
import 'package:crimebott/models/user.dart';

class Post {
  late String title;
  late String content;
  late PostType crimeType;
  late String iconData;
  late DateTime timestamp;
  late String username; // Add username attribute

  Post(this.title, this.content, String crimeTypeString, this.iconData,
      this.username,
      {required this.timestamp})
      : crimeType = _convertStringToPostType(crimeTypeString);

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'crimeType': crimeType.toString().split('.').last,
      'iconData': iconData,
      'timestamp': timestamp,
      'username': username,
    };
  }

  set setUsername(String name) {
    username = name;
  }

  String get formattedTimestamp {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
  }

  static PostType _convertStringToPostType(String value) {
    return PostType.values.firstWhere(
      (type) => type.toString() == 'PostType.' + value,
      orElse: () => PostType.accident,
    );
  }

  Post.fromJson(Map<dynamic, dynamic> json)
      : title = json['title'],
        content = json['content'],
        iconData = json['iconData'],
        timestamp = (json['timestamp'] as Timestamp).toDate(),
        crimeType = _convertStringToPostType(json['crimeType']),
        username = json['username'];
}
