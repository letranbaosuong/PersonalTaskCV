import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:flutter_personal_taskcv_app/src/services/authentication.dart';
import 'package:flutter_personal_taskcv_app/src/views/screens/screens.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DetailProjectScreen extends StatefulWidget {
  DetailProjectScreen({
    Key key,
    this.auth,
    this.userId,
    this.logoutCallback,
    this.project,
  }) : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final Project project;

  @override
  _DetailProjectScreenState createState() => _DetailProjectScreenState();
}

class _DetailProjectScreenState extends State<DetailProjectScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  List<Task> _listTask;

  deleteTask(Task task) {
    _database
        .reference()
        .child('Tasks')
        .child(widget.userId)
        .child(widget.project.id)
        .child(task.id)
        .remove()
        .then((_) {
      setState(() {
        print('xoa thanh cong ${task.id}');
      });
    });
  }

  Widget _notificationTask(Task task) => IconButton(
        icon: task.isReminder
            ? Icon(Icons.notifications_active)
            : Icon(Icons.notifications),
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => NotificationTaskScreen(
          //       userId: widget.userId,
          //       auth: widget.auth,
          //       logoutCallback: widget.logoutCallback,
          //       task: task,
          //     ),
          //   ),
          // );
        },
      );

  @override
  void initState() {
    _listTask = List();
    super.initState();
  }

  Widget _buildTaskCard(BuildContext context, int index) {
    // final task = _listTask[index];
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              true
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Tên nhiệm vụ',
                            style: TextStyle(
                              fontSize: 20,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.check_box,
                              color: Colors.green,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Tên nhiệm vụ',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.check_box_outline_blank,
                              color: Colors.green,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(children: <Widget>[
                  Text(
                    "Mô tả sương sương dfdasf\nsdfasd",
                  ),
                  Spacer(),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(children: <Widget>[
                  Text('Ngày bắt đầu - Ngày kết thúc'),
                  Spacer(),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    false
                        ? IconButton(
                            icon: Icon(
                              Icons.notifications_active,
                              color: Colors.blue,
                            ),
                            onPressed: () {},
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.notifications_none,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {},
                          ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.orangeAccent,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết dự án'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                widget.project.name,
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: false,
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: LinearPercentIndicator(
                    animation: true,
                    lineHeight: 14.0,
                    animationDuration: 1500,
                    percent: 0.8,
                    center: Text(
                      "80.0%",
                      style: TextStyle(fontSize: 12.0),
                    ),
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    progressColor: Colors.green,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                widget.project.description,
                style: TextStyle(
                  fontSize: 20.0,
                ),
                softWrap: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 5),
              child: Text(
                'Danh sách nhiệm vụ',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            SizedBox(
              child: Divider(
                color: Colors.orange.shade700,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: StreamBuilder(
                  stream: _database
                      .reference()
                      .child('Tasks')
                      .child(widget.userId)
                      .child(widget.project.id)
                      .onValue,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData &&
                        !snapshot.hasError &&
                        snapshot.data.snapshot.value != null) {
                      _listTask.clear();
                      /* // [{}, {}, {},...]
                      var valuesProject = snapshot.data.snapshot.value;
                      //print(valuesProject);
                      valuesProject.forEach((itemProject) {
                        if (itemProject != null) {
                          _listTask.add(Project.fromSnapshot(itemProject));
                        } else {
        //               print(object)
                        }
                      });
                      */

                      // { key: {}, key: {}, key: {},... }
                      Map<dynamic, dynamic> valueTasks =
                          snapshot.data.snapshot.value;
                      valueTasks.forEach((key, itemTask) {
                        if (itemTask != null) {
                          _listTask.add(Task.fromSnapshot(itemTask));
                        } else {}
                      });

                      _listTask.sort(
                          (a, b) => a.dateTimeStart.compareTo(b.dateTimeStart));

                      return ListView.builder(
                        itemCount: _listTask.length,
                        itemBuilder: (BuildContext context, int index) =>
                            _buildTaskCard(context, index),
                      );
                    } else {
                      // return Center(
                      //   child: Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       CircularProgressIndicator(),
                      //       Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: Text(
                      //           'Không có nhiệm vụ nào.',
                      //           style: TextStyle(
                      //             fontSize: 25,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // );
                      return ListView.builder(
                        itemCount: 5,
                        itemBuilder: (BuildContext context, int index) =>
                            _buildTaskCard(context, index),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProjectScreen(
                userId: widget.userId,
                auth: widget.auth,
                logoutCallback: widget.logoutCallback,
              ),
            ),
          );
        },
        tooltip: 'Thêm nhiệm vụ',
        child: Icon(Icons.add),
      ),
    );
  }
}
