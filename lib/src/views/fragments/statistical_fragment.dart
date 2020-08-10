import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:flutter_personal_taskcv_app/src/services/authentication.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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

  @override
  void initState() {
    super.initState();

    data = [
      PercentProjectBar(
        nameProject: 'Đi chơi',
        percentComplete: 28.6,
        barColor:
            charts.ColorUtil.fromDartColor(Color(Random().nextInt(0xffffffff))),
      ),
      PercentProjectBar(
        nameProject: 'Mua sắm',
        percentComplete: 98.5,
        barColor: charts.ColorUtil.fromDartColor(
            Colors.primaries[Random().nextInt(Colors.primaries.length)]),
      ),
      PercentProjectBar(
        nameProject: 'Họp nhóm',
        percentComplete: 69.7,
        barColor: charts.ColorUtil.fromDartColor(
            Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)),
      ),
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
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Card(
              child: MyBarChart(data),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Biểu đồ thể hiện tiến độ hoàn thành của các dự án từ ngày 12/01/2019 - 28/07/2020.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
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
