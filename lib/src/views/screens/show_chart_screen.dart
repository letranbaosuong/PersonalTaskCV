import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class ShowChartScreen extends StatefulWidget {
  final DateTime dateTimeStart;
  final DateTime dateTimeEnd;
  final List<PercentProjectBar> data;

  const ShowChartScreen({
    Key key,
    @required this.dateTimeStart,
    @required this.dateTimeEnd,
    @required this.data,
  }) : super(key: key);

  @override
  _ShowChartScreenState createState() => _ShowChartScreenState();
}

class _ShowChartScreenState extends State<ShowChartScreen> {
  List<PercentProjectBar> _dataTemp;
  var idSet;
  var distinct;
  @override
  void initState() {
    // _dataTemp = List();
    // for (int i = 0; i < widget.data.length; i++) {
    //   if (!_dataTemp.contains(widget.data[i])) {
    //     _dataTemp.add(widget.data[i]);
    //   }
    // }
    // _dataTemp.forEach((element) {
    //   print(element.nameProject);
    // });

    idSet = <String>{};
    distinct = <PercentProjectBar>[];
    for (var d in widget.data) {
      if (idSet.add(d.nameProject)) {
        distinct.add(d);
      }
    }

    for (var d in distinct) {
      print('distinct::: ${d.nameProject}');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biểu đồ thống kê'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 300,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Card(
              child: MyBarChart(distinct),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                        text:
                            'Biểu đồ thể hiện tiến độ hoàn thành của các dự án từ ngày '),
                    TextSpan(
                      text:
                          '${DateFormat('dd/MM/yyyy').format(widget.dateTimeStart)}',
                      style: TextStyle(
                        color: Colors.pink[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' - '),
                    TextSpan(
                      text:
                          '${DateFormat('dd/MM/yyyy').format(widget.dateTimeEnd)}',
                      style: TextStyle(
                        color: Colors.pink[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
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
