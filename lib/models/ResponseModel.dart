import 'dart:convert';

import 'package:github_users/models/User.dart';

class ResponseModel {
  int totalCount;
  bool incompleteResults;
  List<User> items;

  ResponseModel({this.totalCount, this.incompleteResults, this.items});

  factory ResponseModel.fromJSON(Map<String, dynamic> parsedJSON) {
    var owner = parsedJSON["items"];
    return ResponseModel(
      totalCount: parsedJSON["total_count"],
      incompleteResults: parsedJSON['incomplete_results'],
      items: parseItems(owner),
    );
  }

  static List<User> parseItems(List<dynamic> itemsList) {

    return itemsList
        .map((e) => User(
              id: e["owner"]["id"],
              login: e["owner"]["login"],
              avatarUrl: e["owner"]["avatar_url"],
              url: e["owner"]["html_url"],
            ))
        .toList();
  }
}
