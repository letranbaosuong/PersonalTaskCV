import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:flutter_personal_taskcv_app/src/services/services.dart';
import 'package:flutter_personal_taskcv_app/src/views/screens/screens.dart';
import 'package:intl/intl.dart';

class NotificationProjectScreen extends StatefulWidget {
  NotificationProjectScreen(
      {Key key, this.auth, this.userId, this.logoutCallback, this.project})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final Project project;

  @override
  _NotificationProjectScreenState createState() =>
      _NotificationProjectScreenState();
}

class _NotificationProjectScreenState extends State<NotificationProjectScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final formatDate = DateFormat('dd-MM-yyyy');
  final formatTime = DateFormat('kk:mm');
  DateTime _selectedDateNotification = DateTime.now();
  TimeOfDay _selectedTimeNotification = TimeOfDay.now();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String _nameProject;
  bool _isNotification;

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
    print('Notification Received ${receivedNotification.id}');
  }

  onNotificationClick(String payload) {
    print('Payload $payload');
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (coontext) {
    //       return NotificationScreen(
    //         payload: payload,
    //       );
    //     },
    //   ),
    // );
  }

  @override
  void initState() {
    _isNotification = widget.project.isReminder;
    _nameProject = widget.project.name;
    _selectedDateNotification = DateTime(
      widget.project.dateTimeReminder.year,
      widget.project.dateTimeReminder.month,
      widget.project.dateTimeReminder.day,
    );
    _selectedTimeNotification = TimeOfDay(
      hour: widget.project.dateTimeReminder.hour,
      minute: widget.project.dateTimeReminder.minute,
    );

    notificationPlugin
        .setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onNotificationClick);

    super.initState();
  }

  Future<void> _selectDateNotification(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDateNotification,
        firstDate: DateTime(1950, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDateNotification)
      setState(() {
        _selectedDateNotification = picked;
      });
  }

  Future<void> _selectTimeNotification(BuildContext context) async {
    final TimeOfDay pickedT = await showTimePicker(
        context: context,
        initialTime: _selectedTimeNotification,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });

    if (pickedT != null && pickedT != _selectedTimeNotification)
      setState(() {
        _selectedTimeNotification = pickedT;
      });
  }

  _setProject(Project project) {
    if (project != null) {
      _database
          .reference()
          .child('Projects')
          .child('${widget.userId}')
          .child('${project.id}')
          .set(project.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Đặt lịch thông báo'),
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
                    enabled: false,
                    initialValue: _nameProject,
                    onChanged: (val) => setState(() => _nameProject = val),
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
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Column(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${formatDate.format(_selectedDateNotification)}',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.date_range,
                            color: Colors.orange,
                          ),
                          onPressed: () => _selectDateNotification(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5, top: 15),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${_selectedTimeNotification.hour} : ${_selectedTimeNotification.minute}',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.access_time,
                            color: Colors.orange,
                          ),
                          onPressed: () => _selectTimeNotification(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _isNotification,
                    onChanged: (value) {
                      setState(() {
                        _isNotification = value;
                      });
                    },
                  ),
                  Text('Đặt thông báo'),
                ],
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
                      'Đồng ý',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        DateTime tamNotification = DateTime(
                          _selectedDateNotification.year,
                          _selectedDateNotification.month,
                          _selectedDateNotification.day,
                          _selectedTimeNotification.hour,
                          _selectedTimeNotification.minute,
                        );
                        Project projectTam = Project(
                          id: widget.project.id,
                          name: widget.project.name,
                          description: widget.project.description,
                          location: widget.project.location,
                          dateTimeStart: widget.project.dateTimeStart,
                          dateTimeEnd: widget.project.dateTimeEnd,
                          dateTimeReminder: tamNotification,
                          completed: widget.project.completed,
                          isReminder: _isNotification,
                          listTask: [],
                          idReminder: widget.project.idReminder,
                        );
                        _setProject(projectTam);

                        await notificationPlugin
                            .scheduleNotificationProject(projectTam);
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
    super.dispose();
  }
}
