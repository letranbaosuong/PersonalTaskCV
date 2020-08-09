import 'package:flutter/material.dart';

class Task {
  String id;
  String name;
  String description;
  String location;
  DateTime dateTimeStart;
  DateTime dateTimeEnd;
  bool completed;
  bool isReminder;
  DateTime dateTimeReminder;

  Task({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.location,
    @required this.dateTimeStart,
    @required this.dateTimeEnd,
    @required this.completed,
    @required this.isReminder,
    @required this.dateTimeReminder,
  });

  Task.fromSnapshot(dynamic snapshot)
      : id = snapshot['Id'],
        name = snapshot['Name'],
        description = snapshot['Description'],
        location = snapshot['Location'],
        dateTimeStart =
            DateTime.fromMillisecondsSinceEpoch(snapshot['DateTimeStart']),
        dateTimeEnd =
            DateTime.fromMillisecondsSinceEpoch(snapshot['DateTimeEnd']),
        completed = snapshot['Completed'],
        isReminder = snapshot['IsReminder'],
        dateTimeReminder =
            DateTime.fromMillisecondsSinceEpoch(snapshot['DateTimeReminder']);

  toJson() {
    return {
      'Id': id,
      'Name': name,
      'Description': description,
      'Location': location,
      'DateTimeStart': dateTimeStart.millisecondsSinceEpoch,
      'DateTimeEnd': dateTimeEnd.millisecondsSinceEpoch,
      'Completed': completed,
      'IsReminder': isReminder,
      'DateTimeReminder': dateTimeReminder.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return '''Task{ 
      Id: $id,
      Name: $name,
      Description: $description,
      Location: $location,
      DateTimeStart: $dateTimeStart,
      DateTimeEnd: $dateTimeEnd,
      Completed: $completed,
      IsReminder: $isReminder,
      DateTimeReminder: $dateTimeReminder,
     }''';
  }
}
