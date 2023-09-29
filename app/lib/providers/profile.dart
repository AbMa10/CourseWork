import 'package:flutter/material.dart';

class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String description;
  final String email;
  final String age;
  final String male;
  int rating;
  int countOfEvents = 0;
  String wasDeleted;
  Map<String, dynamic> complains = {};

  Profile({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.username,
    @required this.description,
    @required this.email,
    @required this.age,
    @required this.male,
    @required this.countOfEvents,
    @required this.rating,
    @required this.complains,
    this.wasDeleted
  });

  int get userRating {
    return rating;
  }
}
