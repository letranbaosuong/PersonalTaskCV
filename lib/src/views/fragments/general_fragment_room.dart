import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:flutter_personal_taskcv_app/src/services/authentication.dart';
import 'package:uuid/uuid.dart';

class ListItem {
  String value;
  String name;

  ListItem({this.value, this.name});
}

class CircleProgress extends CustomPainter {
  double value;
  bool isTemp;

  CircleProgress(this.value, this.isTemp);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    int maximumValue =
        isTemp ? 50 : 100; // Temp's max is 50, Humidity's max is 100

    Paint outerCircle = Paint()
      ..strokeWidth = 14
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    Paint tempArc = Paint()
      ..strokeWidth = 14
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint humidityArc = Paint()
      ..strokeWidth = 14
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - 14;
    canvas.drawCircle(center, radius, outerCircle);

    double angle = 2 * pi * (value / maximumValue);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        angle, false, isTemp ? tempArc : humidityArc);
  }
}

class ProfileFragment extends StatefulWidget {
  ProfileFragment({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _ProfileFragmentState createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment>
    with SingleTickerProviderStateMixin {
  AnimationController progressController;
  Animation<double> tempAnimation;
  Animation<double> humidityAnimation;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  List<Room> _listRoom;
  Image _imageRoom;
  List<ListItem> _dropdownItems = [
    ListItem(
      value: 'living_room',
      name: 'Phòng khách',
    ),
    ListItem(
      value: 'bed_room',
      name: 'Phòng ngủ',
    ),
    ListItem(
      value: 'dining_room',
      name: 'Phòng ăn',
    ),
    ListItem(
      value: 'bath_room',
      name: 'Phòng tắm',
    ),
    ListItem(
      value: 'meeting_room',
      name: 'Phòng họp',
    ),
    ListItem(
      value: 'babys_room',
      name: 'Phòng trẻ con',
    ),
    ListItem(
      value: 'orther_room',
      name: 'Phòng khác',
    ),
  ];

  List<DropdownMenuItem<ListItem>> _dropdownMenuItems;
  ListItem _selectedItem;

  var _uuid = Uuid();
  final _textNameRoomController = TextEditingController();

  @override
  void initState() {
    // double temp = snapshot.value['Temperature']['Data'];
    // double humidity = snapshot.value['Humidity']['Data'];
    _DashboardInit(28, 77.3);
    _listRoom = getRooms();
    _imageRoom = Image.asset('assets/icons8-room-96.png');

    _database
        .reference()
        .child('Users')
        .child(widget.userId)
        .child('Rooms')
        .once()
        .then((snapshot) {
      Map<dynamic, dynamic> valueRooms = snapshot.value;
      valueRooms.forEach((key, itemRoom) {
        print(itemRoom['name']);
        _listRoom.add(Room.fromSnapshot(itemRoom));
      });
    });

    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _selectedItem = _dropdownMenuItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ListItem>> items = List();
    for (ListItem listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.name),
          value: listItem,
        ),
      );
    }
    return items;
  }

  _DashboardInit(double temp, double humid) {
    progressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    ); //1s

    tempAnimation =
        Tween<double>(begin: -50, end: temp).animate(progressController)
          ..addListener(() {
            setState(() {});
          });

    humidityAnimation =
        Tween<double>(begin: 0, end: humid).animate(progressController)
          ..addListener(() {
            setState(() {});
          });

    progressController.forward();
  }

  ListTile makeListTile(Room room) {
    if (room.type == 'living_room') {
      _imageRoom = Image.asset('assets/icons8-living-room-64.png');
    } else if (room.type == 'bed_room') {
      _imageRoom = Image.asset('assets/icons8-sleeping-in-bed-128.png');
    } else if (room.type == 'dining_room') {
      _imageRoom = Image.asset('assets/icons8-kitchen-room-96.png');
    } else if (room.type == 'bath_room') {
      _imageRoom = Image.asset('assets/icons8-bath-96.png');
    } else if (room.type == 'meeting_room') {
      _imageRoom = Image.asset('assets/icons8-meeting-room-96.png');
    } else if (room.type == 'babys_room') {
      _imageRoom = Image.asset('assets/icons8-babys-room-64.png');
    } else if (room.type == 'orther_room') {
      _imageRoom = Image.asset('assets/icons8-room-96.png');
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: EdgeInsets.only(
          left: 0,
          right: 15,
          top: 15,
          bottom: 15,
        ),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              width: 1.0,
              color: Colors.black26,
            ),
          ),
        ),
        child: _imageRoom,
      ),
      title: Text(
        room.name,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

      subtitle: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              // tag: 'hero',
              // child: LinearProgressIndicator(
              //   backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
              //   value: 0.33,
              //   valueColor: AlwaysStoppedAnimation(Colors.green),
              // ),
              child: Icon(
                Icons.important_devices,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Gồm ${room.listDevice.length} thiết bị',
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
      trailing: Icon(
        Icons.keyboard_arrow_right,
        color: Colors.black,
        size: 30.0,
      ),
      onTap: () {
        print('chuyen screen');
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => DetailPage(lesson: lesson)));
      },
    );
  }

  Card makeCard(Room room) => Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white70),
          child: makeListTile(room),
        ),
      );

  setRoom(Room room) {
    if (room != null) {
      _database
          .reference()
          .child('Users')
          .child('${widget.userId}')
          .child('Rooms')
          .child('${room.id}')
          .set(room.toJson());
    }
  }

  List<Room> getRooms() {
    return [
      Room(
        id: 'qfdgsfdgsdfgsgasgertyuiuytre',
        name: "Phòng khách",
        type: 'living_room',
        dateTime: DateTime.now(),
        listDevice: [
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          )
        ],
      ),
      Room(
        id: 'asfhkdjghddfhdgh',
        name: "Phòng ngủ",
        type: 'bed_room',
        dateTime: DateTime.now(),
        listDevice: [],
      ),
      Room(
        id: 'qfdgsfdgsdfgsgasgertyuiuytre',
        name: "Phòng khách",
        type: 'living_room',
        dateTime: DateTime.now(),
        listDevice: [
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          ),
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          ),
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          ),
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          ),
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          ),
        ],
      ),
      Room(
        id: 'asfhkdjghddfhdgh',
        name: "Phòng ngủ",
        type: 'bed_room',
        dateTime: DateTime.now(),
        listDevice: [
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          ),
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          ),
        ],
      ),
      Room(
        id: 'qfdgsfdgsdfgsgasgertyuiuytre',
        name: "Phòng khách",
        type: 'living_room',
        dateTime: DateTime.now(),
        listDevice: [
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          ),
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          ),
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          ),
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          ),
        ],
      ),
      Room(
        id: 'asfhkdjghddfhdgh',
        name: "Phòng ngủ",
        type: 'bed_room',
        dateTime: DateTime.now(),
        listDevice: [],
      ),
      Room(
        id: 'qfdgsfdgsdfgsgasgertyuiuytre',
        name: "Phòng khách",
        type: 'living_room',
        dateTime: DateTime.now(),
        listDevice: [
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          )
        ],
      ),
      Room(
        id: 'asfhkdjghddfhdgh',
        name: "Phòng ngủ",
        type: 'bed_room',
        dateTime: DateTime.now(),
        listDevice: [],
      ),
      Room(
        id: 'qfdgsfdgsdfgsgasgertyuiuytre',
        name: "Phòng khách",
        type: 'living_room',
        dateTime: DateTime.now(),
        listDevice: [
          Device(
            id: null,
            name: null,
            status: null,
            data: null,
            type: null,
            dateTime: null,
          )
        ],
      ),
      Room(
        id: 'asfhkdjghddfhdgh',
        name: "Phòng ngủ",
        type: 'bed_room',
        dateTime: DateTime.now(),
        listDevice: [],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final makeBody = Expanded(
      child: SingleChildScrollView(
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: _listRoom.length,
          itemBuilder: (BuildContext context, int index) {
            return makeCard(_listRoom[index]);
          },
        ),
      ),
    );

    return Scaffold(
      body: StreamBuilder(
        stream: _database
            .reference()
            .child('Users')
            .child(widget.userId)
            .child('Rooms')
            .onValue,
        builder: (context, AsyncSnapshot<Event> snapshot) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    CustomPaint(
                      foregroundPainter:
                          CircleProgress(tempAnimation.value, true),
                      child: Container(
                        width: 150,
                        height: 150,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Nhiệt độ'),
                              Text(
                                '${tempAnimation.value.toInt()}',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '°C',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    CustomPaint(
                      foregroundPainter:
                          CircleProgress(humidityAnimation.value, false),
                      child: Container(
                        width: 150,
                        height: 150,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Độ ẩm'),
                              Text(
                                '${humidityAnimation.value.toInt()}',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '%',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                makeBody,
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddRoomDialog(context);
        },
        tooltip: 'Thêm phòng',
        child: Icon(Icons.add),
      ),
    );
  }

  showAddRoomDialog(BuildContext context) async {
    _textNameRoomController.clear();

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Wrap(
                children: [
                  TextField(
                    controller: _textNameRoomController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Tên phòng',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Loại phòng'),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                value: _selectedItem,
                                items: _dropdownMenuItems,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedItem = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
              child: const Text('Thêm'),
              onPressed: () {
                String v1 = _uuid.v1();
                Room room = Room(
                  id: v1,
                  name: _textNameRoomController.text.toString().trim(),
                  type: _selectedItem.value,
                  dateTime: DateTime.now(),
                  listDevice: [],
                );
                setRoom(room);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
