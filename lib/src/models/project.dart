import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';

class Project {
  String id;
  String name;
  String description;
  String location;
  DateTime dateTimeStart;
  DateTime dateTimeEnd;
  bool completed;
  bool isReminder;
  DateTime dateTimeReminder;
  List<Task> listTask;

  Project({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.location,
    @required this.dateTimeStart,
    @required this.dateTimeEnd,
    @required this.completed,
    @required this.isReminder,
    @required this.dateTimeReminder,
    @required this.listTask,
  });

  Project.fromSnapshot(dynamic snapshot)
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
            DateTime.fromMillisecondsSinceEpoch(snapshot['DateTimeReminder']),
        listTask = snapshot['ListTask'];

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
      'ListTask': listTask,
    };
  }

  @override
  String toString() {
    return '''Project{ 
      Id: $id,
      Name: $name,
      Description: $description,
      Location: $location,
      DateTimeStart: $dateTimeStart,
      DateTimeEnd: $dateTimeEnd,
      Completed: $completed,
      IsReminder: $isReminder,
      DateTimeReminder: $dateTimeReminder,
      ListTask: $listTask,
     }''';
  }
}
