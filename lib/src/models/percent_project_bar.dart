import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class PercentProjectBar {
  final String nameProject;

  final double percentComplete;

  final charts.Color barColor;

  PercentProjectBar({
    @required this.nameProject,
    @required this.percentComplete,
    @required this.barColor,
  });
}
