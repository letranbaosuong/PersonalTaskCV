import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:flutter_personal_taskcv_app/src/services/authentication.dart';
import 'package:flutter_personal_taskcv_app/src/views/screens/screens.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

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
  var _uuid = Uuid();

  // final _textIdDeviceController = TextEditingController();
  final _textNameProjectController = TextEditingController();

  void showInSnackBar(String value) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  showAddProjectDialog(BuildContext context) async {
    _textNameProjectController.clear();

    await showGeneralDialog<String>(
      barrierDismissible: false,
      barrierColor: Colors.orangeAccent,
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondAnimation) {
        // StatefulBuilder(
        //     builder: (BuildContext context,
        //         void Function(void Function()) setState) {
        //       return Wrap(
        //         children: [
        //           TextField(
        //             controller: _textNameProjectController,
        //             autofocus: true,
        //             decoration: InputDecoration(
        //               labelText: 'Tên dự án',
        //             ),
        //           ),
        //           TextField(
        //             controller: _textNameProjectController,
        //             autofocus: true,
        //             decoration: InputDecoration(
        //               labelText: 'Tên dự án',
        //             ),
        //           ),
        //         ],
        //       );
        //     },
        //   ),
        //   FlatButton(
        //       child: const Text('Thêm'),
        //       onPressed: () {
        //         String v1 = _uuid.v1();
        //         Project project = Project(
        //           id: v1,
        //           name: _textNameProjectController.text.toString().trim(),
        //           dateTimeStart: null,
        //           dateTimeEnd: null,
        //           dateTimeReminder: null,
        //           completed: false,
        //           listTask: [],
        //         );
        //         setProject(project);
        //         Navigator.pop(context);
        //       },
        //     )
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width - 10,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    // key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                          child: Card(
                            child: ListTile(
                              leading: Icon(
                                LineAwesomeIcons.user,
                                color: Colors.orange,
                              ),
                              title: TextFormField(
                                // initialValue: _dataUserCurrent.name,
                                onChanged: (val) async {
                                  // await SharedPreferencesHelper.setTen(val);
                                },
                                // controller: _textUserNameEditingController
                                //   ..text = _userName,
                                validator: (val) {
                                  if (val.trim().length < 3 || val.isEmpty) {
                                    return 'Tên quá ngắn';
                                  } else if (val.trim().length > 256) {
                                    return 'Tên quá dài';
                                  } else {
                                    return null;
                                  }
                                },
                                // onSaved: (val) => _userName = val,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Tên',
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                          child: Card(
                            child: ListTile(
                              leading: Icon(
                                LineAwesomeIcons.alternate_map_marked,
                                color: Colors.orange,
                              ),
                              title: TextFormField(
                                // initialValue: _dataUserCurrent.address,
                                onChanged: (val) async {
                                  // await SharedPreferencesHelper.setDiachi(val);
                                },
                                // controller: _textAddressEditingController,
                                validator: (val) {
                                  if (val.trim().length < 3 || val.isEmpty) {
                                    return 'Vui lòng nhập mô tả';
                                  } else {
                                    return null;
                                  }
                                },
                                // onSaved: (val) => _address = val,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Mô tả',
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                          child: Row(
                            children: [
                              Card(
                                child: ListTile(
                                  leading: Icon(
                                    LineAwesomeIcons.birthday_cake,
                                    color: Colors.orange,
                                  ),
                                  title: Text('Bắt đầu'),
                                ),
                              ),
                              Card(
                                child: ListTile(
                                  leading: Icon(
                                    LineAwesomeIcons.birthday_cake,
                                    color: Colors.orange,
                                  ),
                                  title: Text('giờ'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  showEditProjectDialog(BuildContext context, Project project) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        // if (project.type == 'light') {
        //   _selectedItem = _dropdownMenuItems[0].value;
        // } else if (project.type == 'temperature') {
        //   _selectedItem = _dropdownMenuItems[1].value;
        // } else if (project.type == 'humidity') {
        //   _selectedItem = _dropdownMenuItems[2].value;
        // }

        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Wrap(
                children: [
                  TextField(
                    controller: _textNameProjectController..text = project.name,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Tên dự án',
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 10),
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text('Loại dự án'),
                  //       Padding(
                  //         padding: const EdgeInsets.only(top: 5),
                  //         child: Container(
                  //           width: double.infinity,
                  //           padding:
                  //               const EdgeInsets.only(left: 10.0, right: 10.0),
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(10.0),
                  //             border: Border.all(),
                  //           ),
                  //           child: DropdownButtonHideUnderline(
                  //             child: DropdownButton(
                  //               value: _selectedItem,
                  //               items: _dropdownMenuItems,
                  //               onChanged: (value) {
                  //                 setState(() {
                  //                   _selectedItem = value;
                  //                 });
                  //               },
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              );
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Huỷ'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: const Text('Sửa'),
              onPressed: () {
                Project projectEdit = Project(
                  id: project.id,
                  name: _textNameProjectController.text.toString().trim(),
                  dateTimeStart: null,
                  dateTimeEnd: null,
                  dateTimeReminder: null,
                  completed: false,
                  listTask: [],
                );
                setProject(projectEdit);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
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
            showEditProjectDialog(context, project);
          } else if (value == 2) {
            print('xoa ${project.id}');
            deleteProject(project);
          }
        },
      );

  deleteProject(Project project) {
    _database
        .reference()
        .child('Users')
        .child(widget.userId)
        .child('Projects')
        .child('${project.id}')
        .remove()
        .then((_) {
      setState(() {
        //_listProject.removeAt(projectId);
        print('xoa thanh cong ${project.id}');
      });
    });
  }

  setProject(Project project) {
    if (project != null) {
      _database
          .reference()
          .child('Users')
          .child('${widget.userId}')
          .child('Projects')
          .child('${project.id}')
          .set(project.toJson());
    }
  }

  @override
  void initState() {
    _listProject = List();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _database
          .reference()
          .child('Users')
          .child(widget.userId)
          .child('Projects')
          .onValue,
      builder: (context, AsyncSnapshot<Event> snapshot) {
        if (snapshot.hasData &&
            !snapshot.hasError &&
            snapshot.data.snapshot.value != null) {
          _listProject.clear();
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
          valueProjects.forEach((key, itemDevice) {
            if (itemDevice != null) {
              _listProject.add(Project.fromSnapshot(itemDevice));
            } else {}
          });

          // _listProject.sort((a, b) => a.dateTime.compareTo(b.dateTime));

          // for (int i = 0; i < _listProject.length; i++) {
          //   if (_listProject[i].status == 1 &&
          //       _listProject[i].type == 'light') {
          //     _image.add(_imageLightOn);
          //   } else if (_listProject[i].status == 0 &&
          //       _listProject[i].type == 'light') {
          //     _image.add(_imageLightOff);
          //   } else if (_listProject[i].type == 'temperature') {
          //     _image.add(_imageTemperature);
          //   } else if (_listProject[i].type == 'humidity') {
          //     _image.add(_imageHumidity);
          //   }
          // }

          return Scaffold(
            body: GridView.count(
              crossAxisCount: 2,
              children: List.generate(
                _listProject.length,
                (index) => Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.green,
                    ),
                    //borderRadius: BorderRadius.circular(10),
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
                      });
                    },
                    child: Center(
                      child: Stack(
                        children: [
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
                          //   child: _image[index],
                          // ),
                          // Align(
                          //   alignment: Alignment.bottomCenter,
                          //   child: Padding(
                          //     padding: EdgeInsets.only(bottom: 10),
                          //     child: _listProject[index].type == 'light'
                          //         ? Text(
                          //             '${_listProject[index].name}',
                          //             style: TextStyle(
                          //               color: Colors.deepOrange,
                          //               fontSize: 20,
                          //             ),
                          //           )
                          //         : _listProject[index].type == 'temperature'
                          //             ? Text(
                          //                 '${_listProject[index].data}°C',
                          //                 style: TextStyle(
                          //                   color: Colors.deepOrange,
                          //                   fontSize: 20,
                          //                 ),
                          //               )
                          //             : _listProject[index].type == 'humidity'
                          //                 ? Text(
                          //                     '${_listProject[index].data}%',
                          //                     style: TextStyle(
                          //                       color: Colors.deepOrange,
                          //                       fontSize: 20,
                          //                     ),
                          //                   )
                          //                 : Text('Ok'),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // showAddProjectDialog(context);
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
//          WidgetsBinding.instance.addPostFrameCallback((_) {
//            Scaffold.of(context)
//              ..hideCurrentSnackBar()
//              ..showSnackBar(
//                SnackBar(
//                  content: Text(
//                    'Vui lòng thêm dự án!',
//                    style: TextStyle(
//                      color: Colors.white,
//                      fontSize: 25,
//                    ),
//                  ),
//                ),
//              );
//          });
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
                // showAddProjectDialog(context);
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
