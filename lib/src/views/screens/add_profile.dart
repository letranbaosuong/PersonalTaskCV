import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:flutter_personal_taskcv_app/src/services/services.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

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
  String _userName;
  String _address;

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
        urlImage: 'null',
        listProject: [],
      );
      _setAccount(user);

      SnackBar snackbar = SnackBar(content: Text("Chào mừng $_userName!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
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
                                } else if (val.trim().length > 12) {
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
                              LineAwesomeIcons.address_card,
                              color: Colors.orange,
                            ),
                            title: TextFormField(
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
                                hintText: 'Đại chỉ',
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
                    RaisedButton.icon(
                      icon: Icon(
                        LineAwesomeIcons.check,
                        color: Colors.white,
                      ),
                      color: Color(0xffE7A336),
                      onPressed: _submit,
                      elevation: 4.0,
                      splashColor: Colors.orangeAccent,
                      label: Text(
                        'Đồng ý',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
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
  }
}
