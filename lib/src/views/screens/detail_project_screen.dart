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

  _deleteTask(Task task) {
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
    final task = _listTask[index];
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              task.completed
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '${task.name}',
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
                            onPressed: () {
                              Task taskTam = Task(
                                id: task.id,
                                name: task.name,
                                description: task.description,
                                location: task.location,
                                dateTimeStart: task.dateTimeStart,
                                dateTimeEnd: task.dateTimeEnd,
                                dateTimeReminder: task.dateTimeReminder,
                                completed: false,
                                isReminder: task.isReminder,
                              );
                              _setTask(taskTam);
                            },
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '${task.name}',
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
                            onPressed: () {
                              Task taskTam = Task(
                                id: task.id,
                                name: task.name,
                                description: task.description,
                                location: task.location,
                                dateTimeStart: task.dateTimeStart,
                                dateTimeEnd: task.dateTimeEnd,
                                dateTimeReminder: task.dateTimeReminder,
                                completed: true,
                                isReminder: task.isReminder,
                              );
                              _setTask(taskTam);
                            },
                          ),
                        ],
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(children: <Widget>[
                  Text(
                    '${task.description}',
                  ),
                  Spacer(),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(children: <Widget>[
                  Text(
                      '${DateFormat('dd/MM/yyyy').format(task.dateTimeStart)} - ${DateFormat('dd/MM/yyyy').format(task.dateTimeEnd)}'),
                  Spacer(),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    task.isReminder
                        ? IconButton(
                            icon: Icon(
                              Icons.notifications_active,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationTaskScreen(
                                    userId: widget.userId,
                                    auth: widget.auth,
                                    logoutCallback: widget.logoutCallback,
                                    project: widget.project,
                                    task: task,
                                  ),
                                ),
                              );
                            },
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.notifications_none,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationTaskScreen(
                                    userId: widget.userId,
                                    auth: widget.auth,
                                    logoutCallback: widget.logoutCallback,
                                    project: widget.project,
                                    task: task,
                                  ),
                                ),
                              );
                            },
                          ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.orangeAccent,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTaskScreen(
                              userId: widget.userId,
                              auth: widget.auth,
                              logoutCallback: widget.logoutCallback,
                              project: widget.project,
                              task: task,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteTask(task),
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Không có nhiệm vụ nào.',
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                      // return ListView.builder(
                      //   itemCount: 5,
                      //   itemBuilder: (BuildContext context, int index) =>
                      //       _buildTaskCard(context, index),
                      // );
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
              builder: (context) => AddTaskScreen(
                userId: widget.userId,
                auth: widget.auth,
                logoutCallback: widget.logoutCallback,
                project: widget.project,
              ),
            ),
          );
        },
        tooltip: 'Thêm nhiệm vụ',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
