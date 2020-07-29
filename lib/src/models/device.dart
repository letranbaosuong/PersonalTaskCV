import 'package:flutter/material.dart';

class Device {
  String id;
  String name;
  int status;
  double data;
  String type;
  DateTime dateTime;

  Device.empty();

  Device({
    @required this.id,
    @required this.name,
    @required this.status,
    @required this.data,
    @required this.type,
    @required this.dateTime,
  });

  Device.fromSnapshot(dynamic snapshot)
      : id = snapshot['Id'],
        name = snapshot['Name'],
        status = snapshot['Status'],
        data = (snapshot['Data']).toDouble(),
        type = snapshot['Type'],
        dateTime = DateTime.fromMillisecondsSinceEpoch(snapshot['DateTime']);

  toJson() {
    return {
      'Id': id,
      'Name': name,
      'Status': status,
      'Data': data,
      'Type': type,
      'DateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'Device{deviceId: $id, name: $name, status: $status, data: $data, typeOfDevice: $type, dateTime: $dateTime}';
  }
}
