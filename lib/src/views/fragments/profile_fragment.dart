import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/services/authentication.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

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
  File file;

  final formatDate = DateFormat('dd-MM-yyyy');
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
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
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
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
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_${widget.userId}.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
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
    setState(() {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Ảnh đại diện đã tải lên.'),
        ),
      );
    });
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    Future uploadPic(BuildContext context) async {
      String fileName = path.basename(file.path);
      StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('Users')
          .child('${widget.userId}')
          .child('AvatarImage')
          .child(fileName);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(file);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      setState(() {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Ảnh đại diện đã tải lên.'),
          ),
        );
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Builder(
          builder: (context) => Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Row(
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
                            child: (file != null)
                                ? Image.file(
                                    file,
                                    fit: BoxFit.fill,
                                  )
                                : Image.network(
                                    "https://images.unsplash.com/photo-1502164980785-f8aa41d53611?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                                    fit: BoxFit.fill,
                                  ),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        LineAwesomeIcons.user,
                        color: Colors.orange,
                      ),
                      title: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Tên',
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        LineAwesomeIcons.address_card,
                        color: Colors.orange,
                      ),
                      title: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Đại chỉ',
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        LineAwesomeIcons.birthday_cake,
                        color: Colors.orange,
                      ),
                      title: Text(
                        '${formatDate.format(selectedDate)}',
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
                  padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                  child: Card(
                    color: Colors.orange[100],
                    child: ListTile(
                      leading: Icon(
                        LineAwesomeIcons.mail_bulk,
                        color: Colors.orange,
                      ),
                      title: Text(
                        'letranbaosuong@gmail.com',
                      ),
                    ),
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
                        // uploadPic(context);
                        await compressImage();
                        String mediaUrl = await uploadImage(file);
                        print('tên hình nè////////// $mediaUrl');
                        // createPostInFirestore(
                        //   mediaUrl: mediaUrl,
                        //   location: locationController.text,
                        //   description: captionController.text,
                        // );
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
