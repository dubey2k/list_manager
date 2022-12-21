// To parse this JSON data, do
//
//     final postDataModel = postDataModelFromMap(jsonString);

import 'dart:convert';

PostDataModel postDataModelFromMap(String str) =>
    PostDataModel.fromMap(json.decode(str));

String postDataModelToMap(PostDataModel data) => json.encode(data.toMap());

class PostDataModel {
  PostDataModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  int userId;
  int id;
  String title;
  String body;

  factory PostDataModel.fromMap(Map<String, dynamic> json) => PostDataModel(
        userId: json["userId"],
        id: json["id"],
        title: json["title"],
        body: json["body"],
      );

  Map<String, dynamic> toMap() => {
        "userId": userId,
        "id": id,
        "title": title,
        "body": body,
      };
}
