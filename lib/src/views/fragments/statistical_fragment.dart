import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/services/authentication.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('chart'),
      ),
    );
  }
}
