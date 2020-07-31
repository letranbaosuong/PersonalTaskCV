import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:flutter_personal_taskcv_app/src/services/authentication.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final String _ten = 'ten';
  static final String _diaChi = 'diaChi';
  static final String _ngaySinh = 'ngaySinh';

  static Future<String> getTen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_ten) ?? '';
  }

  static Future<bool> setTen(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_ten, value);
  }

  static Future<String> getDiachi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_diaChi) ?? '';
  }

  static Future<bool> setDiachi(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_diaChi, value);
  }

  static Future<int> getNgaysinh() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_ngaySinh) ?? -1;
  }

  static Future<bool> setNgaysinh(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(_ngaySinh, value);
  }

  static Future<bool> _storeInfo(
      String ten, String diaChi, int ngaySinh) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_ten, ten) &&
        await prefs.setString(_diaChi, diaChi) &&
        await prefs.setInt(_ngaySinh, ngaySinh);
  }

  static Future<void> _removeInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_ten);
    prefs.remove(_diaChi);
    prefs.remove(_ngaySinh);
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

class _ProfileFragmentState extends State<ProfileFragment> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final StorageReference storageRef = FirebaseStorage.instance.ref();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  // TextEditingController _textUserNameEditingController;
  TextEditingController _textAddressEditingController;
  String _userName;
  String _address;
  User _dataUserCurrent;
  File _file;

  bool _isUploading;

  final formatDate = DateFormat('dd-MM-yyyy');
  DateTime _selectedDate = DateTime.now();

  _getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String formattedAddress =
        '${placemark.name}, ${placemark.thoroughfare}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}.';
    await SharedPreferencesHelper.setDiachi(formattedAddress);
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

  _submit(String userId, String userName, String address, DateTime selectedDate,
      File file) async {
    setState(() {
      _isUploading = true;
    });
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      User user;

      if (file == null) {
        user = User(
          id: userId,
          name: userName,
          email: _dataUserCurrent.email,
          birthDay: selectedDate,
          address: address,
          urlImage: _dataUserCurrent.urlImage,
          listProject: [],
        );
      } else {
        // uploadPic(context);
        await compressImage();
        String mediaUrl = await uploadImage(file);

        user = User(
          id: userId,
          name: userName,
          email: _dataUserCurrent.email,
          birthDay: selectedDate,
          address: address,
          urlImage: mediaUrl,
          listProject: [],
        );

        clearImage();
      }

      _setAccount(user);

      SharedPreferencesHelper._removeInfo();

      setState(() {
        _isUploading = false;
      });

      SnackBar snackbar = SnackBar(content: Text('Cập nhật thành công.'));
      _scaffoldKey.currentState.showSnackBar(snackbar);
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
        SharedPreferencesHelper.setNgaysinh(picked.millisecondsSinceEpoch);
      });
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 500,
      maxWidth: 500,
    );
    setState(() {
      this._file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this._file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text('Chọn ảnh đại diện'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Ảnh trong máy ảnh'),
              onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
              child: Text('Ảnh từ thư viện'),
              onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
              child: Text('Hủy'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  clearImage() {
    if (_file != null)
      setState(() {
        _file = null;
      });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(_file.readAsBytesSync());
    final compressedImageFile = File('$path/img_${widget.userId}.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      _file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask = storageRef
        .child('Users')
        .child('${widget.userId}')
        .child('AvatarImage')
        .child('avatar_${widget.userId}.jpg')
        .putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  @override
  void initState() {
    // _textUserNameEditingController = TextEditingController(text: 'username');
    // _textAddressEditingController = TextEditingController(text: 'address');
    _isUploading = false;
    _database
        .reference()
        .child('Users')
        .child(widget.userId)
        .once()
        .then((snapshot) {
      if (snapshot.value != null) {
        _dataUserCurrent = User.fromSnapshot(snapshot.value);
        _selectedDate = _dataUserCurrent.birthDay;
        _textAddressEditingController =
            TextEditingController(text: _dataUserCurrent.address);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _database.reference().child('Users').child(widget.userId).onValue,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData &&
            !snapshot.hasError &&
            snapshot.data.snapshot.value != null) {
          _dataUserCurrent = User.fromSnapshot(snapshot.data.snapshot.value);
          // print('${snapshot.data.snapshot.value}');
          _userName = _dataUserCurrent.name;
          _address = _dataUserCurrent.address;
          // _selectedDate = _dataUserCurrent.birthDay;
          if (_textAddressEditingController == null) {
            _textAddressEditingController =
                TextEditingController(text: _dataUserCurrent.address);
          }

          return Scaffold(
            key: _scaffoldKey,
            body: ListView(
              children: [
                _isUploading
                    ? Container(
                        width: double.infinity,
                        child: LinearProgressIndicator(),
                      )
                    : Text(''),
                SingleChildScrollView(
                  child: Builder(
                    builder: (context) => Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                    radius: 100,
                                    backgroundColor: Color(0xffE7A336),
                                    child: ClipOval(
                                      child: new SizedBox(
                                        width: 180.0,
                                        height: 180.0,
                                        child: (_file == null)
                                            ? (_dataUserCurrent
                                                    .urlImage.isEmpty)
                                                ? Image.asset(
                                                    'assets/images/default_avatar.jpg',
                                                    fit: BoxFit.fill,
                                                  )
                                                : Image.network(
                                                    '${_dataUserCurrent.urlImage}',
                                                    fit: BoxFit.fill,
                                                  )
                                            : Image.file(
                                                _file,
                                                fit: BoxFit.fill,
                                              ),

                                        // child: (_file != null)
                                        //     ? Image.file(
                                        //         _file,
                                        //         fit: BoxFit.fill,
                                        //       )
                                        //     : Image.network(
                                        //         "https://images.unsplash.com/photo-1502164980785-f8aa41d53611?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                                        //         fit: BoxFit.fill,
                                        //       ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 60.0),
                                  child: IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.camera,
                                      size: 30.0,
                                      color: Color(0xffE7A336),
                                    ),
                                    onPressed: () => selectImage(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20.0, 5.0, 20.0, 0.0),
                                  child: Card(
                                    child: ListTile(
                                      leading: Icon(
                                        LineAwesomeIcons.user,
                                        color: Colors.orange,
                                      ),
                                      title: TextFormField(
                                        initialValue: _dataUserCurrent.name,
                                        onChanged: (val) async {
                                          await SharedPreferencesHelper.setTen(
                                              val);
                                        },
                                        // controller: _textUserNameEditingController
                                        //   ..text = _userName,
                                        validator: (val) {
                                          if (val.trim().length < 3 ||
                                              val.isEmpty) {
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
                                  padding: const EdgeInsets.fromLTRB(
                                      20.0, 5.0, 20.0, 0.0),
                                  child: Card(
                                    child: ListTile(
                                      leading: Icon(
                                        LineAwesomeIcons.alternate_map_marked,
                                        color: Colors.orange,
                                      ),
                                      title: TextFormField(
                                        // initialValue: _dataUserCurrent.address,
                                        onChanged: (val) async {
                                          await SharedPreferencesHelper
                                              .setDiachi(val);
                                        },
                                        controller:
                                            _textAddressEditingController,
                                        validator: (val) {
                                          if (val.trim().length < 3 ||
                                              val.isEmpty) {
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
                                  padding: const EdgeInsets.fromLTRB(
                                      20.0, 5.0, 20.0, 0.0),
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
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20.0, 5.0, 20.0, 0.0),
                                  child: Card(
                                    color: Colors.orange[100],
                                    child: ListTile(
                                      leading: Icon(
                                        LineAwesomeIcons.mail_bulk,
                                        color: Colors.orange,
                                      ),
                                      title: Text(
                                        '${_dataUserCurrent.email}',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton.icon(
                                icon: Icon(
                                  LineAwesomeIcons.upload,
                                  color: Colors.white,
                                ),
                                color: Color(0xffE7A336),
                                onPressed: () async {
                                  _userName =
                                      await SharedPreferencesHelper.getTen();
                                  _address =
                                      await SharedPreferencesHelper.getDiachi();
                                  _selectedDate =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          await SharedPreferencesHelper
                                              .getNgaysinh());
                                  if (_userName.isEmpty) {
                                    _userName = _dataUserCurrent.name;
                                  }
                                  if (_address.isEmpty) {
                                    _address = _dataUserCurrent.address;
                                  }
                                  if ((await SharedPreferencesHelper
                                          .getNgaysinh()) ==
                                      -1) {
                                    _selectedDate = _dataUserCurrent.birthDay;
                                  }

                                  print(
                                      '_userName::: $_userName, _address::: $_address, _selectedDate::: $_selectedDate');
                                  _submit(widget.userId, _userName, _address,
                                      _selectedDate, _file);
                                },
                                elevation: 4.0,
                                splashColor: Colors.orangeAccent,
                                label: Text(
                                  'Cập nhật',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    // _textUserNameEditingController.dispose();
    if (_textAddressEditingController != null) {
      _textAddressEditingController.dispose();
    }
    clearImage();
    super.dispose();
  }
}
