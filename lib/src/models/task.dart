import 'package:flutter/material.dart';

class Task {
  String id;
  String name;
  DateTime dateTimeStart;
  DateTime dateTimeEnd;
  bool completed;
  DateTime dateTimeReminder;

  Task({
    @required this.id,
    @required this.name,
    @required this.dateTimeStart,
    @required this.dateTimeEnd,
    @required this.completed,
    @required this.dateTimeReminder,
  });

  Task.fromSnapshot(dynamic snapshot)
      : id = snapshot['Id'],
        name = snapshot['Name'],
        dateTimeStart =
            DateTime.fromMillisecondsSinceEpoch(snapshot['DateTimeStart']),
        dateTimeEnd =
            DateTime.fromMillisecondsSinceEpoch(snapshot['DateTimeEnd']),
        completed = snapshot['Completed'],
        dateTimeReminder =
            DateTime.fromMillisecondsSinceEpoch(snapshot['DateTimeReminder']);

  toJson() {
    return {
      'Id': id,
      'Name': name,
      'DateTimeStart': dateTimeStart.millisecondsSinceEpoch,
      'DateTimeEnd': dateTimeEnd.millisecondsSinceEpoch,
      'Completed': completed,
      'DateTimeReminder': dateTimeReminder.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return '''Task{ 
      Id: $id,
      Name: $name,
      DateTimeStart: $dateTimeStart,
      DateTimeEnd: $dateTimeEnd,
      Completed: $completed,
      DateTimeReminder: $dateTimeReminder,
     }''';
  }
}