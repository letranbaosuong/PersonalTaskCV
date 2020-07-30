import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';

class Project {
  String id;
  String name;
  DateTime dateTimeStart;
  DateTime dateTimeEnd;
  bool completed;
  DateTime dateTimeReminder;
  List<Task> listTask;

  Project({
    @required this.id,
    @required this.name,
    @required this.dateTimeStart,
    @required this.dateTimeEnd,
    @required this.completed,
    @required this.dateTimeReminder,
    @required this.listTask,
  });

  Project.fromSnapshot(dynamic snapshot)
      : id = snapshot['Id'],
        name = snapshot['Name'],
        dateTimeStart =
            DateTime.fromMillisecondsSinceEpoch(snapshot['DateTimeStart']),
        dateTimeEnd =
            DateTime.fromMillisecondsSinceEpoch(snapshot['DateTimeEnd']),
        completed = snapshot['Completed'],
        dateTimeReminder =
            DateTime.fromMillisecondsSinceEpoch(snapshot['DateTimeReminder']),
        listTask = snapshot['ListTask'];

  toJson() {
    return {
      'Id': id,
      'Name': name,
      'DateTimeStart': dateTimeStart.millisecondsSinceEpoch,
      'DateTimeEnd': dateTimeEnd.millisecondsSinceEpoch,
      'Completed': completed,
      'DateTimeReminder': dateTimeReminder.millisecondsSinceEpoch,
      'ListTask': listTask,
    };
  }

  @override
  String toString() {
    return '''Project{ 
      Id: $id,
      Name: $name,
      DateTimeStart: $dateTimeStart,
      DateTimeEnd: $dateTimeEnd,
      Completed: $completed,
      DateTimeReminder: $dateTimeReminder,
      ListTask: $listTask,
     }''';
  }
}
