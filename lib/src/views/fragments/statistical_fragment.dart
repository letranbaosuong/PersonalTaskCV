import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:flutter_personal_taskcv_app/src/services/authentication.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_personal_taskcv_app/src/services/services.dart';
import 'package:flutter_personal_taskcv_app/src/views/screens/screens.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class StatisticalFragment extends StatefulWidget {
  StatisticalFragment({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _StatisticalFragmentState createState() => _StatisticalFragmentState();
}

class _StatisticalFragmentState extends State<StatisticalFragment> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<PercentProjectBar> data;
  DateTime _selectedDateStart = DateTime.now();
  DateTime _selectedDateEnd = DateTime.now();
  List<Project> _listProject;
  IServiceDAO _serviceDAO = ServiceDAOImpl();
  final RoundedLoadingButtonController _btnAddProfileController =
      new RoundedLoadingButtonController();

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

    // _database
    //     .reference()
    //     .child('Projects')
    //     .child(widget.userId)
    //     .orderByChild('DateTimeStart')
    //     .startAt(_selectedDateStart.millisecondsSinceEpoch)
    //     .endAt(_selectedDateEnd.millisecondsSinceEpoch)
    //     .once()
    //     .then((value) => print(value.value));
  }

  Future<void> _selectDateEnd(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDateEnd,
        firstDate: DateTime(1950, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDateEnd)
      setState(() {
        _selectedDateEnd = DateTime(
          picked.year,
          picked.month,
          picked.day,
          23,
          59,
        );
      });

    // _database
    //     .reference()
    //     .child('Projects')
    //     .child(widget.userId)
    //     .orderByChild('DateTimeStart')
    //     .startAt(_selectedDateStart.millisecondsSinceEpoch)
    //     .endAt(_selectedDateEnd.millisecondsSinceEpoch)
    //     .once()
    //     .then((value) => print(value.value));
  }

  @override
  void initState() {
    super.initState();
    _listProject = List();

    data = [
      // PercentProjectBar(
      //   nameProject: 'Đi chơi',
      //   percentComplete: 28.6,
      //   barColor:
      //       charts.ColorUtil.fromDartColor(Color(Random().nextInt(0xffffffff))),
      // ),
      // PercentProjectBar(
      //   nameProject: 'Mua sắm',
      //   percentComplete: 98.5,
      //   barColor: charts.ColorUtil.fromDartColor(
      //       Colors.primaries[Random().nextInt(Colors.primaries.length)]),
      // ),
      // PercentProjectBar(
      //   nameProject: 'Họp nhóm',
      //   percentComplete: 69.7,
      //   barColor: charts.ColorUtil.fromDartColor(
      //       Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)),
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: StreamBuilder(
                stream: _database
                    .reference()
                    .child('Projects')
                    .child(widget.userId)
                    .orderByChild('DateTimeStart')
                    .startAt(_selectedDateStart.millisecondsSinceEpoch)
                    .endAt(_selectedDateEnd.millisecondsSinceEpoch)
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      !snapshot.hasError &&
                      snapshot.data.snapshot.value != null) {
                    // print(snapshot.data.snapshot.value);
                    _listProject.clear();
                    data.clear();

                    Map<dynamic, dynamic> valueProjects =
                        snapshot.data.snapshot.value;
                    valueProjects.forEach((key, itemProject) {
                      if (itemProject != null) {
                        _listProject.add(Project.fromSnapshot(itemProject));
                      } else {}
                    });
                    print('_listProject: ${_listProject.length}');

                    for (int i = 0; i < _listProject.length; i++) {
                      print(_listProject[i].id);
                      _getPercentCompletedOfProject(_listProject[i]);
                    }
                    return Center();
                  } else {
                    _listProject.clear();
                    data.clear();
                    return Center();
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Container(
              width: 200,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(_selectedDateStart)}',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.date_range,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      _selectDateStart(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Container(
              width: 200,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(_selectedDateEnd)}',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.date_range,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      _selectDateEnd(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: RoundedLoadingButton(
              child: Text(
                'Đồng ý',
                style: TextStyle(color: Colors.white),
              ),
              controller: _btnAddProfileController,
              onPressed: () async {
                // _listProject.clear();
                // data.clear();

                // var dataProject = await _database
                //     .reference()
                //     .child('Projects')
                //     .child(widget.userId)
                //     .orderByChild('DateTimeStart')
                //     .startAt(_selectedDateStart.millisecondsSinceEpoch)
                //     .endAt(_selectedDateEnd.millisecondsSinceEpoch)
                //     .once();

                // if (dataProject.value != null) {
                //   Map<dynamic, dynamic> valueProjects = dataProject.value;
                //   valueProjects.forEach((key, itemProject) {
                //     if (itemProject != null) {
                //       _listProject.add(Project.fromSnapshot(itemProject));
                //     } else {}
                //   });
                //   print('_listProject: ${_listProject.length}');
                // }

                // if (_listProject.length > 0) {
                //   for (int i = 0; i < _listProject.length; i++) {
                //     _getPercentCompletedOfProject(_listProject[i]);
                //   }
                // }
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ShowChartScreen(
                //       dateTimeStart: _selectedDateStart,
                //       dateTimeEnd: _selectedDateEnd,
                //       data: data,
                //     ),
                //   ),
                // );

                // _btnAddProfileController.stop();

                if (_listProject.length > 0) {
                  _btnAddProfileController.success();
                  Timer(Duration(milliseconds: 500), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowChartScreen(
                          dateTimeStart: _selectedDateStart,
                          dateTimeEnd: _selectedDateEnd,
                          data: data,
                        ),
                      ),
                    );
                  });
                } else {
                  _btnAddProfileController.error();
                  final snackBar = SnackBar(
                    content: Text('Không có dữ liệu nào cả.'),
                    duration: Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {
                        // Some code to undo the change.
                      },
                    ),
                  );

                  // Find the Scaffold in the widget tree and use
                  // it to show a SnackBar.
                  Scaffold.of(context).showSnackBar(snackBar);
                  _listProject.clear();
                  data.clear();
                }
                Timer(Duration(milliseconds: 1500), () {
                  _btnAddProfileController.stop();
                });
              },
              width: 100,
              color: Color(0xffE7A336),
            ),
          ),
        ],
      ),
    );
  }

  void _getPercentCompletedOfProject(Project project) async {
    var dataPercent =
        await _serviceDAO.getPercentTotalTasks(widget.userId, project.id);
    print('project: ${project.name} - percent: $dataPercent');
    if (dataPercent.isNaN) {
      data.add(
        PercentProjectBar(
          nameProject: project.name,
          percentComplete: 0.0 * 100,
          barColor: charts.ColorUtil.fromDartColor(
            Color(
              (Random().nextDouble() * 0xFFFFFF).toInt(),
            ).withOpacity(1.0),
          ),
        ),
      );
    } else {
      data.add(
        PercentProjectBar(
          nameProject: project.name,
          percentComplete: dataPercent * 100,
          barColor: charts.ColorUtil.fromDartColor(
            Color(
              (Random().nextDouble() * 0xFFFFFF).toInt(),
            ).withOpacity(1.0),
          ),
        ),
      );
    }
    // _serviceDAO.getPercentTotalTasks(widget.userId, project.id).then((value) {
    //   print('project: ${project.name} - percent: $value');
    //   if (value.isNaN) {
    //     data.add(
    //       PercentProjectBar(
    //         nameProject: project.name,
    //         percentComplete: 0.0 * 100,
    //         barColor: charts.ColorUtil.fromDartColor(
    //           Color(
    //             (Random().nextDouble() * 0xFFFFFF).toInt(),
    //           ).withOpacity(1.0),
    //         ),
    //       ),
    //     );
    //   } else {
    //     data.add(
    //       PercentProjectBar(
    //         nameProject: project.name,
    //         percentComplete: value * 100,
    //         barColor: charts.ColorUtil.fromDartColor(
    //           Color(
    //             (Random().nextDouble() * 0xFFFFFF).toInt(),
    //           ).withOpacity(1.0),
    //         ),
    //       ),
    //     );
    //   }
    // });
  }
}

class MyBarChart extends StatelessWidget {
  final List data;
  MyBarChart(this.data);

  @override
  Widget build(BuildContext context) {
    List<charts.Series<PercentProjectBar, String>> series = [
      charts.Series(
        id: 'PercentProjectBar',
        data: data,
        domainFn: (PercentProjectBar percentProjectBar, _) =>
            percentProjectBar.nameProject,
        measureFn: (PercentProjectBar percentProjectBar, _) =>
            percentProjectBar.percentComplete,
        colorFn: (PercentProjectBar percentProjectBar, _) =>
            percentProjectBar.barColor,
      )
    ];

    return charts.BarChart(
      series,
      animate: true,
      barGroupingType: charts.BarGroupingType.groupedStacked,
    );
  }
}
