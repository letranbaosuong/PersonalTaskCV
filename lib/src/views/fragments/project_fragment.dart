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

  List<Device> _listDevice;
  List<Image> _image;
  Image _imageLightOn = Image.asset('assets/icons8-light-on-96.png');
  Image _imageLightOff = Image.asset('assets/icons8-light-off-96.png');
  Image _imageTemperature =
      Image.asset('assets/icons8-temperature-sensitive-100.png');
  Image _imageHumidity = Image.asset('assets/icons8-humidity-80.png');

  List<ListItem> _dropdownItems = [
    ListItem(
      value: 'light',
      name: 'Đèn',
    ),
    ListItem(
      value: 'temperature',
      name: 'Nhiệt độ',
    ),
    ListItem(
      value: 'humidity',
      name: 'Độ ẩm',
    ),
  ];

  List<DropdownMenuItem<ListItem>> _dropdownMenuItems;
  ListItem _selectedItem;

  var _uuid = Uuid();

  // final _textIdDeviceController = TextEditingController();
  final _textNameDeviceController = TextEditingController();

  void showInSnackBar(String value) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  showAddDeviceDialog(BuildContext context) async {
    _textNameDeviceController.clear();
    _selectedItem = _dropdownMenuItems[0].value;

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Wrap(
                children: [
                  // TextField(
                  //   controller: _textIdDeviceController
                  //     ..text = deviceId.toString(),
                  //   autofocus: true,
                  //   enabled: false,
                  //   keyboardType: TextInputType.number,
                  //   inputFormatters: [
                  //     WhitelistingTextInputFormatter.digitsOnly,
                  //   ],
                  //   // Only numbers can be entered
                  //   decoration: InputDecoration(
                  //     labelText: 'Mã thiết bị',
                  //   ),
                  // ),
                  TextField(
                    controller: _textNameDeviceController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Tên thiết bị',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Loại thiết bị'),
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
                Device device = Device(
                  id: v1,
                  name: _textNameDeviceController.text.toString().trim(),
                  status: 0,
                  data: 0,
                  type: _selectedItem.value,
                  dateTime: DateTime.now(),
                );
                setDevice(device);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  showEditDeviceDialog(BuildContext context, Device device) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        if (device.type == 'light') {
          _selectedItem = _dropdownMenuItems[0].value;
        } else if (device.type == 'temperature') {
          _selectedItem = _dropdownMenuItems[1].value;
        } else if (device.type == 'humidity') {
          _selectedItem = _dropdownMenuItems[2].value;
        }

        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Wrap(
                children: [
                  TextField(
                    controller: _textNameDeviceController..text = device.name,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Tên thiết bị',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Loại thiết bị'),
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
              child: const Text('Sửa'),
              onPressed: () {
                Device deviceEdit = Device(
                  id: device.id,
                  name: _textNameDeviceController.text.toString().trim(),
                  status: device.status,
                  data: device.data,
                  type: _selectedItem.value,
                  dateTime: device.dateTime,
                );
                setDevice(deviceEdit);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
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

  Widget _offsetPopup(Device device) => PopupMenuButton<int>(
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
            print('sua ${device.id}');
            showEditDeviceDialog(context, device);
          } else if (value == 2) {
            print('xoa ${device.id}');
            deleteDevice(device);
          }
        },
      );

  deleteDevice(Device device) {
    _database
        .reference()
        .child('Users')
        .child(widget.userId)
        .child('Devices')
        .child('${device.id}')
        .remove()
        .then((_) {
      setState(() {
        //_listDevice.removeAt(deviceId);
        print('xoa thanh cong ${device.id}');
      });
    });
  }

  setDevice(Device device) {
    if (device != null) {
      _database
          .reference()
          .child('Users')
          .child('${widget.userId}')
          .child('Devices')
          .child('${device.id}')
          .set(device.toJson());
    }
  }

  @override
  void initState() {
    _listDevice = List();
    _image = List();

    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _selectedItem = _dropdownMenuItems[0].value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _database
          .reference()
          .child('Users')
          .child(widget.userId)
          .child('Devices')
          .onValue,
      builder: (context, AsyncSnapshot<Event> snapshot) {
        if (snapshot.hasData &&
            !snapshot.hasError &&
            snapshot.data.snapshot.value != null) {
          _listDevice.clear();
          _image.clear();
          /* // [{}, {}, {},...]
          var valuesDevice = snapshot.data.snapshot.value;
          //print(valuesDevice);
          valuesDevice.forEach((itemDevice) {
            if (itemDevice != null) {
              _listDevice.add(Device.fromSnapshot(itemDevice));
            } else {
//               print(object)
            }
          });
          */

          // { key: {}, key: {}, key: {},... }
          Map<dynamic, dynamic> valueDevices = snapshot.data.snapshot.value;
          valueDevices.forEach((key, itemDevice) {
            if (itemDevice != null) {
              _listDevice.add(Device.fromSnapshot(itemDevice));
            } else {}
          });

          _listDevice.sort((a, b) => a.dateTime.compareTo(b.dateTime));

          for (int i = 0; i < _listDevice.length; i++) {
            if (_listDevice[i].status == 1 && _listDevice[i].type == 'light') {
              _image.add(_imageLightOn);
            } else if (_listDevice[i].status == 0 &&
                _listDevice[i].type == 'light') {
              _image.add(_imageLightOff);
            } else if (_listDevice[i].type == 'temperature') {
              _image.add(_imageTemperature);
            } else if (_listDevice[i].type == 'humidity') {
              _image.add(_imageHumidity);
            }
          }

          return Scaffold(
            body: GridView.count(
              crossAxisCount: 2,
              children: List.generate(
                _listDevice.length,
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
                        if (_listDevice[index].status == 0) {
                          _listDevice[index].status = 1;
                        } else if (_listDevice[index].status == 1) {
                          _listDevice[index].status = 0;
                        }

                        /*
                                    // cach 1
                                    _database
                                        .reference()
                                        .child('Users')
                                        .child(snapshot.data)
                                        .child('Device$index')
                                        .update({'Status': _light[index]});
                                     */

                        Map<String, dynamic> childrenPathValueMap = {};
                        childrenPathValueMap[
                                'Users/${widget.userId}/Devices/${_listDevice[index].id}/Status'] =
                            _listDevice[index].status;
                        _database.reference().update(childrenPathValueMap);

                        if (_listDevice[index].status == 1 &&
                            _listDevice[index].type == 'light') {
                          _image[index] = _imageLightOn;
                        } else if (_listDevice[index].status == 0 &&
                            _listDevice[index].type == 'light') {
                          _image[index] = _imageLightOff;
                        }
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
                                    return _offsetPopup(_listDevice[index]);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: _image[index],
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: _listDevice[index].type == 'light'
                                  ? Text(
                                      '${_listDevice[index].name}',
                                      style: TextStyle(
                                        color: Colors.deepOrange,
                                        fontSize: 20,
                                      ),
                                    )
                                  : _listDevice[index].type == 'temperature'
                                      ? Text(
                                          '${_listDevice[index].data}°C',
                                          style: TextStyle(
                                            color: Colors.deepOrange,
                                            fontSize: 20,
                                          ),
                                        )
                                      : _listDevice[index].type == 'humidity'
                                          ? Text(
                                              '${_listDevice[index].data}%',
                                              style: TextStyle(
                                                color: Colors.deepOrange,
                                                fontSize: 20,
                                              ),
                                            )
                                          : Text('Ok'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showAddDeviceDialog(context);
              },
              tooltip: 'Thêm thiết bị',
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
//                    'Vui lòng thêm thiết bị!',
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
                      'Vui lòng thêm thiết bị!',
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
                showAddDeviceDialog(context);
              },
              tooltip: 'Thêm thiết bị',
              child: Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
