import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:flutter_personal_taskcv_app/src/services/services.dart';
import 'package:flutter_personal_taskcv_app/src/views/screens/screens.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class AddProfile extends StatefulWidget {
  AddProfile({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _AddProfileState createState() => _AddProfileState();
}

class _AddProfileState extends State<AddProfile> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final formatDate = DateFormat('dd-MM-yyyy');
  DateTime _selectedDate = DateTime.now();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textAddressEditingController;
  final RoundedLoadingButtonController _btnAddProfileController =
      new RoundedLoadingButtonController();
  String _userName;
  String _address;

  _getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String formattedAddress =
        '${placemark.name}, ${placemark.thoroughfare}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}.';
    setState(() {
      _textAddressEditingController =
          TextEditingController(text: formattedAddress);
      _textAddressEditingController.text = formattedAddress;
    });
  }

  _setAccount(User user) {
    _database
        .reference()
        .child('Users')
        .child('${widget.userId}')
        .set(user.toJson());
  }

  _submit() async {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();

      FirebaseUser userCurrent = await widget.auth.getCurrentUser();
      User user = User(
        id: widget.userId,
        name: _userName,
        email: userCurrent.email,
        birthDay: _selectedDate,
        address: _address,
        urlImage: '',
        listProject: [],
      );
      _setAccount(user);

      SnackBar snackbar = SnackBar(content: Text('Chào mừng $_userName!'));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 1), () {
        _btnAddProfileController.success();
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RootScreen(
                auth: Auth(),
              ),
            ),
          );
        });
      });
    } else {
      _btnAddProfileController.stop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1950, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  void initState() {
    _textAddressEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Thiết lập hồ sơ'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Center(
                  child: Text(
                    'Thông tin cơ bản',
                    style: TextStyle(fontSize: 25.0),
                  ),
                ),
              ),
              Container(
                child: Form(
                  key: _formKey,
                  autovalidate: true,
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
                              validator: (val) {
                                if (val.trim().length < 3 || val.isEmpty) {
                                  return 'Tên quá ngắn';
                                } else if (val.trim().length > 256) {
                                  return 'Tên quá dài';
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (val) => _userName = val,
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
                              controller: _textAddressEditingController,
                              validator: (val) {
                                if (val.trim().length < 3 || val.isEmpty) {
                                  return 'Vui lòng nhập địa chỉ';
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (val) => _address = val,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Địa chỉ',
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.my_location,
                                color: Colors.orange,
                              ),
                              onPressed: _getUserLocation,
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
                              LineAwesomeIcons.birthday_cake,
                              color: Colors.orange,
                            ),
                            title: Text(
                              '${formatDate.format(_selectedDate)}',
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                LineAwesomeIcons.calendar,
                                color: Colors.orange,
                              ),
                              onPressed: () => _selectDate(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // RaisedButton.icon(
                    //   icon: Icon(
                    //     LineAwesomeIcons.check,
                    //     color: Colors.white,
                    //   ),
                    //   color: Color(0xffE7A336),
                    //   onPressed: _submit,
                    //   elevation: 4.0,
                    //   splashColor: Colors.orangeAccent,
                    //   label: Text(
                    //     'Đồng ý',
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //       fontSize: 16.0,
                    //     ),
                    //   ),
                    // ),
                    RoundedLoadingButton(
                      child: Text(
                        'Đồng ý',
                        style: TextStyle(color: Colors.white),
                      ),
                      controller: _btnAddProfileController,
                      onPressed: _submit,
                      width: 100,
                      color: Color(0xffE7A336),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textAddressEditingController.dispose();
    super.dispose();
  }
}
