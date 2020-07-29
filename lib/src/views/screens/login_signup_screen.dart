import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final String _email = 'email';
  static final String _password = 'password';
  static final String _mind = 'mind';
  static Future<String> getEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_email) ?? '';
  }

  static Future<bool> setEmail(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_email, value);
  }

  static Future<String> getPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_password) ?? '';
  }

  static Future<bool> setPassword(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_password, value);
  }

  static Future<bool> getMind() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_mind) ?? true;
  }

  static Future<bool> setMind(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(_mind, value);
  }

  static Future<bool> _storeLocalAccount(
      String email, String password, bool mind) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_email, email) &&
        await prefs.setString(_password, password) &&
        await prefs.setBool(_mind, mind);
  }

  static Future<void> _removeLocalAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('password');
    prefs.remove('mind');
  }
}

class LoginSignupScreen extends StatefulWidget {
  LoginSignupScreen({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textEmailController = TextEditingController();
  final _textPasswordController = TextEditingController();

  String _email;
  String _password;
  String _errorMessage;

  bool _isLoginForm;
  bool _isLoading;
  bool _passwordVisible;

  bool _isRemember;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      String userId = "";
      try {
        if (_isLoginForm) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in: $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null && _isLoginForm) {
          widget.loginCallback();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  Future<void> _getLocalAccountStartUp() async {
    _email = '';
    _password = '';
    _isRemember = false;

    String email = await SharedPreferencesHelper.getEmail();
    String password = await SharedPreferencesHelper.getPassword();
    bool mind = await SharedPreferencesHelper.getMind();

    setState(() {
      _email = email;
      _password = password;
      _isRemember = mind;
    });
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    _passwordVisible = true;
    _getLocalAccountStartUp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.1, 0.5, 0.7, 0.9],
            colors: [
              Colors.yellow[800],
              Colors.yellow[700],
              Colors.yellow[600],
              Colors.yellow[400],
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            _showForm(),
            _showCircularProgress(),
          ],
        ),
      ),
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác minh tài khoản"),
          content: Text(
              "Liên kết để xác minh tài khoản đã được gửi đến email của bạn"),
          actions: <Widget>[
            FlatButton(
              child: Text("Đã hiểu"),
              onPressed: () {
                toggleFormMode();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showForm() {
    return Container(
      padding: EdgeInsets.all(30),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            showLogo(),
            showEmailInput(),
            showPasswordInput(),
            showCheckRememberPass(),
            showPrimaryButton(),
            showSecondaryButton(),
            showErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Text(
        _errorMessage,
        style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300,
        ),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  Widget showLogo() {
    return Container(
      width: 200,
      height: 200,
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
                    width: 200,
                    height: 200,
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
                fontSize: 50,
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
                fontSize: 100,
                color: Color(0xffE7A336),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Tên đăng nhập',
          icon: Icon(
            Icons.mail,
            color: Colors.grey,
          ),
        ),
        validator: (value) =>
            !value.contains('@') ? 'Email không hợp lệ!' : null,
        onSaved: (value) => _email = value.trim(),
        onChanged: (value) async {
          _email = value.trim();
          if (_isRemember) {
            await SharedPreferencesHelper.setEmail(_email);
          } else {
            await SharedPreferencesHelper.setEmail('');
          }
        },
        controller: _textEmailController..text = _email,
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: _passwordVisible,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Mật khẩu',
          icon: Icon(
            Icons.lock,
            color: Colors.grey,
          ),
          suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                semanticLabel:
                    _passwordVisible ? 'Ẩn mật khẩu' : 'Hiện mật khẩu',
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                  // _passwordVisible ^= true;
                  //print("Icon button pressed! state: $_passwordVisible"); //Confirmed that the _passwordVisible is toggled each time the button is pressed.
                });
              }),
        ),
        validator: (value) =>
            value.isEmpty ? 'Mật khẩu không được rỗng!' : null,
        onSaved: (value) => _password = value.trim(),
        onChanged: (value) async {
          _password = value.trim();
          if (_isRemember) {
            await SharedPreferencesHelper.setPassword(_password);
          } else {
            await SharedPreferencesHelper.setPassword('');
          }
        },
        controller: _textPasswordController..text = _password,
      ),
    );
  }

  Widget showSecondaryButton() {
    return FlatButton(
      child: Text(
        _isLoginForm ? 'Tạo một tài khoản' : 'Có một tài khoản? Đăng nhập',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300),
      ),
      onPressed: toggleFormMode,
    );
  }

  Widget showPrimaryButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: RaisedButton(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          color: Colors.orangeAccent,
          child: Text(
            _isLoginForm ? 'Đăng nhập' : 'Tạo tài khoản',
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          onPressed: validateAndSubmit,
        ),
      ),
    );
  }

  Widget showCheckRememberPass() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _isRemember,
                onChanged: (value) async {
                  await SharedPreferencesHelper.setMind(value);
                  if (value) {
                    await SharedPreferencesHelper.setEmail(_email);
                    await SharedPreferencesHelper.setPassword(_password);
                  } else {
                    await SharedPreferencesHelper.setEmail('');
                    await SharedPreferencesHelper.setPassword('');
                  }
                  setState(() {
                    _isRemember = value;
                  });
                },
              ),
              Text('Lưu tài khoản'),
            ],
          ),
        ],
      ),
    );
  }
}
