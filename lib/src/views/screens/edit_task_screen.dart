import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:flutter_personal_taskcv_app/src/services/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class EditTaskScreen extends StatefulWidget {
  EditTaskScreen({
    Key key,
    this.auth,
    this.userId,
    this.logoutCallback,
    this.project,
    this.task,
  }) : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final Project project;
  final Task task;

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final formatDate = DateFormat('dd-MM-yyyy');
  final formatTime = DateFormat('kk:mm');
  DateTime _selectedDateStart = DateTime.now();
  DateTime _selectedDateEnd = DateTime.now();
  TimeOfDay _selectedTimeStart = TimeOfDay.now();
  TimeOfDay _selectedTimeEnd = TimeOfDay.now();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textLocationEditingController;
  String _nameTask;
  String _location;
  String _description;

  @override
  void initState() {
    _textLocationEditingController = TextEditingController();
    _nameTask = widget.task.name;
    _location = widget.task.location;
    _textLocationEditingController.text = _location;
    _description = widget.task.description;
    _selectedDateStart = DateTime(
      widget.task.dateTimeStart.year,
      widget.task.dateTimeStart.month,
      widget.task.dateTimeStart.day,
    );
    _selectedTimeStart = TimeOfDay(
      hour: widget.task.dateTimeStart.hour,
      minute: widget.task.dateTimeStart.minute,
    );
    _selectedDateEnd = DateTime(
      widget.task.dateTimeEnd.year,
      widget.task.dateTimeEnd.month,
      widget.task.dateTimeEnd.day,
    );
    _selectedTimeEnd = TimeOfDay(
      hour: widget.task.dateTimeEnd.hour,
      minute: widget.task.dateTimeEnd.minute,
    );

    super.initState();
  }

  Future<void> _selectDateStart(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDateStart,
        firstDate: DateTime(1950, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDateStart)
      setState(() {
        _selectedDateStart = picked;
      });
  }

  Future<void> _selectDateEnd(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDateEnd,
        firstDate: DateTime(1950, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDateEnd)
      setState(() {
        _selectedDateEnd = picked;
      });
  }

  Future<void> _selectTimeStart(BuildContext context) async {
    final TimeOfDay pickedT = await showTimePicker(
        context: context,
        initialTime: _selectedTimeStart,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });

    if (pickedT != null && pickedT != _selectedTimeStart)
      setState(() {
        _selectedTimeStart = pickedT;
      });
  }

  Future<void> _selectTimeEnd(BuildContext context) async {
    final TimeOfDay pickedT = await showTimePicker(
        context: context,
        initialTime: _selectedTimeEnd,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });

    if (pickedT != null && pickedT != _selectedTimeEnd)
      setState(() {
        _selectedTimeEnd = pickedT;
      });
  }

  _setTask(Task task) {
    if (task != null) {
      _database
          .reference()
          .child('Tasks')
          .child(widget.userId)
          .child(widget.project.id)
          .child(task.id)
          .set(task.toJson());
    }
  }

  _getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String formattedAddress =
        '${placemark.name}, ${placemark.thoroughfare}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}.';
    setState(() {
      _location = formattedAddress;
      _textLocationEditingController.text = formattedAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Sửa nhiệm vụ'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        autovalidate: true,
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    Icons.title,
                    color: Colors.orange,
                  ),
                  title: TextFormField(
                    initialValue: _nameTask,
                    onChanged: (val) => setState(() => _nameTask = val),
                    validator: (val) {
                      if (val.trim().length < 3 || val.isEmpty) {
                        return 'Tên quá ngắn';
                      } else if (val.trim().length > 11) {
                        return 'Tên quá dài';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tên',
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    LineAwesomeIcons.alternate_map_marked,
                    color: Colors.orange,
                  ),
                  title: TextFormField(
                    controller: _textLocationEditingController,
                    onChanged: (val) => setState(() => _location = val),
                    validator: (val) {
                      if (val.trim().length < 3 || val.isEmpty) {
                        return 'Vui lòng nhập địa chỉ';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Địa điểm',
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.my_location,
                      color: Colors.orange,
                    ),
                    onPressed: _getUserLocation,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        width: 1,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 3,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${formatDate.format(_selectedDateStart)}',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.date_range,
                            color: Colors.orange,
                          ),
                          onPressed: () => _selectDateStart(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        width: 1,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 3,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${_selectedTimeStart.hour} : ${_selectedTimeStart.minute}',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.access_time,
                            color: Colors.orange,
                          ),
                          onPressed: () => _selectTimeStart(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        width: 1,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 3,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${formatDate.format(_selectedDateEnd)}',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.date_range,
                            color: Colors.orange,
                          ),
                          onPressed: () => _selectDateEnd(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        width: 1,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 3,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${_selectedTimeEnd.hour} : ${_selectedTimeEnd.minute}',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.access_time,
                            color: Colors.orange,
                          ),
                          onPressed: () => _selectTimeEnd(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    LineAwesomeIcons.sticky_note,
                    color: Colors.orange,
                  ),
                  title: TextFormField(
                    initialValue: _description,
                    keyboardType: TextInputType.multiline,
                    maxLines: 6,
                    onChanged: (val) => setState(() => _description = val),
                    validator: (val) {
                      if (val.trim().length < 3 || val.isEmpty) {
                        return 'Mô tả quá ngắn';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Mô tả nhiệm vụ',
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlatButton(
                    color: Colors.orange,
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  FlatButton(
                    color: Colors.orange,
                    child: const Text(
                      'Sửa',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        DateTime tamStart = DateTime(
                          _selectedDateStart.year,
                          _selectedDateStart.month,
                          _selectedDateStart.day,
                          _selectedTimeStart.hour,
                          _selectedTimeStart.minute,
                        );
                        DateTime tamEnd = DateTime(
                          _selectedDateEnd.year,
                          _selectedDateEnd.month,
                          _selectedDateEnd.day,
                          _selectedTimeEnd.hour,
                          _selectedTimeEnd.minute,
                        );
                        Task task = Task(
                          id: widget.task.id,
                          name: _nameTask,
                          description: _description,
                          location: _location,
                          dateTimeStart: tamStart,
                          dateTimeEnd: tamEnd,
                          dateTimeReminder: widget.task.dateTimeReminder,
                          completed: widget.task.completed,
                          isReminder: widget.task.isReminder,
                          idReminder: widget.task.idReminder,
                        );
                        _setTask(task);
                        Navigator.pop(context);
                      } else {
                        SnackBar snackbar =
                            SnackBar(content: Text('Sai thông tin kìa.'));
                        _scaffoldKey.currentState.showSnackBar(snackbar);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textLocationEditingController.dispose();
    super.dispose();
  }
}
