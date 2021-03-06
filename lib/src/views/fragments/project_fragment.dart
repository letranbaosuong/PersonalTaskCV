import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:flutter_personal_taskcv_app/src/services/authentication.dart';
import 'package:flutter_personal_taskcv_app/src/services/services.dart';
import 'package:flutter_personal_taskcv_app/src/views/screens/screens.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProjectFragment extends StatefulWidget {
  ProjectFragment({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _ProjectFragmentState createState() => _ProjectFragmentState();
}

class _ProjectFragmentState extends State<ProjectFragment> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  List<Project> _listProject;
  List<double> _listPercentCompleted;
  double _percentCompleted;
  IServiceDAO _serviceDAO = ServiceDAOImpl();

  void showInSnackBar(String value) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  // List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(List listItems) {
  //   List<DropdownMenuItem<ListItem>> items = List();
  //   for (ListItem listItem in listItems) {
  //     items.add(
  //       DropdownMenuItem(
  //         child: Text(listItem.name),
  //         value: listItem,
  //       ),
  //     );
  //   }
  //   return items;
  // }

  Widget _offsetPopup(Project project) => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text('Sửa'),
          ),
          PopupMenuItem(
            value: 2,
            child: Text('Xóa'),
          ),
        ],
        icon: Icon(Icons.settings),
        offset: Offset(0, 100),
        initialValue: 1,
        onSelected: (value) {
          if (value == 1) {
            print('sua ${project.id}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProjectScreen(
                  userId: widget.userId,
                  auth: widget.auth,
                  logoutCallback: widget.logoutCallback,
                  project: project,
                ),
              ),
            );
          } else if (value == 2) {
            print('xoa ${project.id}');
            deleteProject(project);
          }
        },
      );

  deleteProject(Project project) {
    _database
        .reference()
        .child('Projects')
        .child(widget.userId)
        .child('${project.id}')
        .remove()
        .then((_) {
      setState(() {
        print('xoa thanh cong ${project.id}');
      });
    });
  }

  Widget _notificationProject(Project project) => IconButton(
        icon: project.isReminder
            ? Icon(
                Icons.notifications_active,
                color: Colors.green,
              )
            : Icon(Icons.notifications),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationProjectScreen(
                userId: widget.userId,
                auth: widget.auth,
                logoutCallback: widget.logoutCallback,
                project: project,
              ),
            ),
          );
        },
      );

  @override
  void initState() {
    _listProject = List();
    _percentCompleted = 0.0;
    _listPercentCompleted = List();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          _database.reference().child('Projects').child(widget.userId).onValue,
      builder: (context, AsyncSnapshot<Event> snapshot) {
        if (snapshot.hasData &&
            !snapshot.hasError &&
            snapshot.data.snapshot.value != null) {
          _listProject.clear();
          _listPercentCompleted.clear();
          /* // [{}, {}, {},...]
          var valuesProject = snapshot.data.snapshot.value;
          //print(valuesProject);
          valuesProject.forEach((itemProject) {
            if (itemProject != null) {
              _listProject.add(Project.fromSnapshot(itemProject));
            } else {
//               print(object)
            }
          });
          */

          // { key: {}, key: {}, key: {},... }
          Map<dynamic, dynamic> valueProjects = snapshot.data.snapshot.value;
          valueProjects.forEach((key, itemProject) {
            if (itemProject != null) {
              _listProject.add(Project.fromSnapshot(itemProject));
            } else {}
          });

          _listProject
              .sort((a, b) => a.dateTimeStart.compareTo(b.dateTimeStart));

          // for (int i = 0; i < _listProject.length; i++)
          //   _serviceDAO
          //       .getListTask(widget.userId, _listProject[i])
          //       .then((tasks) {
          //     int dem = 0;
          //     tasks.forEach((task) {
          //       if (task.completed) {
          //         dem++;
          //       }
          //     });
          //     _percentCompleted = dem / _listProject.length;
          //     _listPercentCompleted.add(_percentCompleted);
          //     print(_percentCompleted);
          //   });

          return Scaffold(
            body: GridView.count(
              crossAxisCount: 2,
              children: List.generate(_listProject.length, (index) {
                return Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.green,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        // if (_listProject[index].status == 0) {
                        //   _listProject[index].status = 1;
                        // } else if (_listProject[index].status == 1) {
                        //   _listProject[index].status = 0;
                        // }

                        /*
                                    // cach 1
                                    _database
                                        .reference()
                                        .child('Users')
                                        .child(snapshot.data)
                                        .child('Device$index')
                                        .update({'Status': _light[index]});
                                     */

                        // Map<String, dynamic> childrenPathValueMap = {};
                        // childrenPathValueMap[
                        //         'Users/${widget.userId}/Projects/${_listProject[index].id}/Status'] =
                        //     _listProject[index].status;
                        // _database.reference().update(childrenPathValueMap);

                        // if (_listProject[index].status == 1 &&
                        //     _listProject[index].type == 'light') {
                        //   _image[index] = _imageLightOn;
                        // } else if (_listProject[index].status == 0 &&
                        //     _listProject[index].type == 'light') {
                        //   _image[index] = _imageLightOff;
                        // }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailProjectScreen(
                              userId: widget.userId,
                              auth: widget.auth,
                              logoutCallback: widget.logoutCallback,
                              project: _listProject[index],
                            ),
                          ),
                        );
                      });
                    },
                    child: Center(
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: _notificationProject(_listProject[index]),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                StatefulBuilder(
                                  builder: (BuildContext context,
                                      void Function(void Function()) setState) {
                                    return _offsetPopup(_listProject[index]);
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Align(
                          //   alignment: Alignment.center,
                          //   child: CircularPercentIndicator(
                          //     animation: true,
                          //     radius: 75.0,
                          //     percent: 0.0,
                          //     lineWidth: 5.0,
                          //     circularStrokeCap: CircularStrokeCap.round,
                          //     backgroundColor: Colors.orange[100],
                          //     progressColor: Colors.orange,
                          //     center: Text(
                          //       '${(0.0 * 100).round()}%',
                          //       style: TextStyle(
                          //         fontWeight: FontWeight.w700,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                '${_listProject[index].name}',
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            // alignment: Alignment(0, 0.7),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                '${DateFormat('dd/MM/yyyy').format(_listProject[index].dateTimeStart)}',
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
              tooltip: 'Thêm dự án',
              child: Icon(Icons.add),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Không có dự án nào.',
                      style: TextStyle(
                        fontSize: 25,
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
              tooltip: 'Thêm dự án',
              child: Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
