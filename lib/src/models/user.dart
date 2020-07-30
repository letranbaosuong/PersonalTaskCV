import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';

class User {
  String id;
  String name;
  String email;
  DateTime birthDay;
  String address;
  String urlImage;
  List<Project> listProject;

  User({
    @required this.id,
    @required this.name,
    @required this.email,
    @required this.birthDay,
    @required this.address,
    @required this.urlImage,
    @required this.listProject,
  });

  User.fromSnapshot(dynamic snapshot)
      : id = snapshot['Id'],
        name = snapshot['Name'],
        email = snapshot['Email'],
        birthDay = DateTime.fromMillisecondsSinceEpoch(snapshot['BirthDay']),
        address = snapshot['Address'],
        urlImage = snapshot['UrlImage'],
        listProject = snapshot['ListProject'];

  toJson() {
    return {
      'Id': id,
      'Name': name,
      'Email': email,
      'BirthDay': birthDay.millisecondsSinceEpoch,
      'Address': address,
      'UrlImage': urlImage,
      'ListProject': listProject,
    };
  }

  @override
  String toString() {
    return '''User{ 
      Id: $id,
      Name: $name,
      Email: $email,
      BirthDay: $birthDay,
      Address: $address,
      UrlImage: $urlImage,
      ListProject: $listProject,
     }''';
  }
}
