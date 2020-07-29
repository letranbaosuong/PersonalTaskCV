import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';

class Room {
  String id;
  String name;
  String type;
  DateTime dateTime;
  List<Device> listDevice;

  Room({
    @required this.id,
    @required this.name,
    @required this.type,
    @required this.dateTime,
    @required this.listDevice,
  });

  Room.fromSnapshot(dynamic snapshot)
      : id = snapshot['Id'],
        name = snapshot['Name'],
        type = snapshot['Type'],
        dateTime = DateTime.fromMillisecondsSinceEpoch(snapshot['DateTime']),
        listDevice = snapshot['Devices'];

  toJson() {
    return {
      'Id': id,
      'Name': name,
      'Type': type,
      'DateTime': dateTime.millisecondsSinceEpoch,
      'Devices': listDevice,
    };
  }

  @override
  String toString() {
    return 'Room{id: $id, name: $name, type: $type, dateTime: $dateTime, listDevice: ${listDevice.toList().toString()}}';
  }
}
