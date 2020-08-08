import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/services/authentication.dart';
import 'package:flutter_personal_taskcv_app/src/views/fragments/fragments.dart';
import 'package:flutter_personal_taskcv_app/src/views/screens/add_profile_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}

class HomeScreen extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  final drawerItems = [
    DrawerItem('Hồ sơ', FontAwesomeIcons.userCircle),
    DrawerItem('Dự án', FontAwesomeIcons.tasks),
    DrawerItem('Thiết lập', FontAwesomeIcons.cog),
    DrawerItem('Trợ giúp', FontAwesomeIcons.questionCircle),
    DrawerItem('Đăng xuất', FontAwesomeIcons.signOutAlt),
  ];

  HomeScreen({Key key, this.auth, this.logoutCallback, this.userId})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  void initState() {
    _database
        .reference()
        .child('Users')
        .child(widget.userId)
        .once()
        .then((snapshot) {
      if (snapshot.value == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddProfileScreen(
              userId: widget.userId,
              auth: widget.auth,
              logoutCallback: widget.logoutCallback,
            ),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerOptions = [];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      if (i == 0) {
        drawerOptions.add(
          ListTile(
            title: Text(
              'DANH MỤC',
              style: GoogleFonts.roboto(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
      if (i == 3 || i == 4) {
        drawerOptions.add(
          Divider(
            thickness: 1,
          ),
        );
      }

      drawerOptions.add(
        ListTile(
          leading: Container(
            width: 30,
            height: 30,
            child: Icon(d.icon),
          ),
          title: Text(
            d.title,
            style: GoogleFonts.roboto(),
          ),
          selected: i == _selectedDrawerIndex,
          onTap: () => _onSelectItem(i),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drawerItems[_selectedDrawerIndex].title),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Container(
              child: DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange,
                      Colors.orangeAccent,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      showLogo(),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        'TaskCV',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[50],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: drawerOptions,
            )
          ],
        ),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }

  Widget showLogo() {
    return Container(
      width: 100,
      height: 100,
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
      child: Stack(
        children: [
          Align(
            alignment: Alignment(0, 0),
            child: ClipOval(
              child: Material(
                color: Colors.yellowAccent[10],
                child: InkWell(
                  splashColor: Colors.yellowAccent[100],
                  child: SizedBox(
                    width: 100,
                    height: 100,
                  ),
                  onTap: () {},
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, -0.6),
            child: Text(
              'Task',
              style: TextStyle(
                fontFamily: 'Prisma',
                fontSize: 24.5,
                color: Color(0xffE7A336),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, 0.6),
            child: Text(
              'CV',
              style: TextStyle(
                fontFamily: 'Prisma',
                fontSize: 49,
                color: Color(0xffE7A336),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _selectedDrawerIndex = 0;

  Widget _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return ProfileFragment(
          userId: widget.userId,
          auth: widget.auth,
          logoutCallback: widget.logoutCallback,
        );
      case 1:
        return ProjectFragment(
          userId: widget.userId,
          auth: widget.auth,
          logoutCallback: widget.logoutCallback,
        );
      case 2:
        return SettingFragment(
          userId: widget.userId,
          auth: widget.auth,
          logoutCallback: widget.logoutCallback,
        );
      case 3:
        return HelpFragment(
          userId: widget.userId,
          auth: widget.auth,
          logoutCallback: widget.logoutCallback,
        );
      case 4:
        signOut();
        return CircularProgressIndicator();

      default:
        return Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }
}
