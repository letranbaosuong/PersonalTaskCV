import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/services/authentication.dart';
import 'package:flutter_personal_taskcv_app/src/views/widgets/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

const urlSocial = 'https://www.facebook.com/suong.le99';
const urlAddress =
    'https://www.google.com/maps/place/B%C3%ACnh+Thu%E1%BA%ADn,+Qu%E1%BA%ADn+7,+Th%C3%A0nh+ph%E1%BB%91+H%E1%BB%93+Ch%C3%AD+Minh,+Vi%E1%BB%87t+Nam/@10.7429202,106.7184029,16z/data=!4m13!1m7!3m6!1s0x31752545651a5d37:0x59351503d40d3fbb!2zUGjDuiBN4bu5LCBRdeG6rW4gNywgVGjDoG5oIHBo4buRIEjhu5MgQ2jDrSBNaW5oLCBWaeG7h3QgTmFt!3b1!8m2!3d10.7161298!4d106.7411559!3m4!1s0x31752f8072a86101:0xa84c5b3fd9e7d4f4!8m2!3d10.7414271!4d106.7264125';
const email = 'letranbaosuong@gmail.com';
const phone = '0367552499';

class HelpFragment extends StatefulWidget {
  HelpFragment({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _HelpFragmentState createState() => _HelpFragmentState();
}

class _HelpFragmentState extends State<HelpFragment> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  void _showDialog(BuildContext context, {String title, String msg}) {
    final dialog = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: <Widget>[
        RaisedButton(
          color: Colors.teal,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Đóng',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
    showDialog(context: context, builder: (x) => dialog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/my_avatar.png'),
                ),
              ),
              Text(
                'Lê Trần Bảo Sương',
                style: GoogleFonts.pacifico(
                  fontSize: 40.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Software Engineer',
                style: GoogleFonts.sourceSansPro(
                  fontSize: 30.0,
                  color: Colors.orange[50],
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
                width: 200,
                child: Divider(
                  color: Colors.orange.shade700,
                ),
              ),
              InfoCard(
                text: phone,
                icon: Icons.phone,
                onPressed: () async {
                  String removeSpaceFromPhoneNumber =
                      phone.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
                  final phoneCall = 'tel:$removeSpaceFromPhoneNumber';

                  if (await launcher.canLaunch(phoneCall)) {
                    await launcher.launch(phoneCall);
                  } else {
                    _showDialog(
                      context,
                      title: 'Xin lỗi!',
                      msg:
                          'Số điện thoại không thể được gọi. Vui lòng thử lại!',
                    );
                  }
                },
              ),
              InfoCard(
                text: email,
                icon: Icons.email,
                onPressed: () async {
                  final emailAddress = 'mailto:$email';

                  if (await launcher.canLaunch(emailAddress)) {
                    await launcher.launch(emailAddress);
                  } else {
                    _showDialog(
                      context,
                      title: 'Xin lỗi!',
                      msg: 'Email không thể được gửi. Vui lòng thử lại!',
                    );
                  }
                },
              ),
              InfoCard(
                text: 'Suong Le',
                icon: FontAwesomeIcons.facebook,
                onPressed: () async {
                  if (await launcher.canLaunch(urlSocial)) {
                    await launcher.launch(urlSocial);
                  } else {
                    _showDialog(
                      context,
                      title: 'Xin lỗi!',
                      msg: 'URL không thể được mở. Vui lòng thử lại!',
                    );
                  }
                },
              ),
              InfoCard(
                text: 'Bình Thuận, Quận 7, TP.HCM',
                icon: Icons.location_city,
                onPressed: () async {
                  if (await launcher.canLaunch(urlAddress)) {
                    await launcher.launch(urlAddress);
                  } else {
                    _showDialog(
                      context,
                      title: 'Xin lỗi!',
                      msg: 'URL không thể được mở. Vui lòng thử lại!',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.orange[200],
    );
  }
}
