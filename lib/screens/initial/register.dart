import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keptoon/screens/initial/home.dart';
import 'package:keptoon/services/auth_service.dart';
import 'package:keptoon/utils/flush_bars.dart';
import 'package:keptoon/utils/pallete.dart';
import 'package:keptoon/utils/progress.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final AuthServcies _authServcies = AuthServcies();
  ProgressDialog pr;
  bool isSecureText = true;
  bool secureText = true;

  @override
  void initState() {
    super.initState();
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Download,
      textDirection: TextDirection.ltr,
      isDismissible: false,
      customBody: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        width: 100,
        height: 100,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 10,
            ),
            child: Column(
              children: <Widget>[
                flashProgress(),
                Text("making your account...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(129, 165, 168, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ),
      ),
      showLogs: false,
    );
  }

  done() async {
    if (username.text.trim() != "") {
      if (email.text.trim() != "") {
        if (password.text.trim() != "") {
          if (RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(email.text.trim())) {
            if (password.text.length > 6) {
              try {
                pr.show();
                String usernameS = username.text.trim();

                QuerySnapshot snapUser =
                    await _authServcies.usernameCheckSe(usernameS);
                QuerySnapshot snapEmail =
                    await _authServcies.emailCheckSe(email.text.trim());

                if (snapEmail.documents.isEmpty) {
                  if (snapUser.documents.isEmpty) {
                    AuthResult result =
                        await _authServcies.createUserWithEmailAndPasswordSe(
                            email.text.trim(), password.text.trim());
                    await _authServcies.createUserInDatabaseSe(result.user.uid,
                        username.text.trim(), email.text.trim());

                    _firebaseMessaging.getToken().then((token) {
                      print("Firebase Messaging Token: $token\n");
                      _authServcies.createMessagingToken(
                          token, result.user.uid);
                    });

                    pr.hide().whenComplete(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    });
                  } else {
                    pr.hide();
                    GradientSnackBar.showMessage(
                        context, "Username already used!");
                  }
                } else {
                  pr.hide();
                  GradientSnackBar.showMessage(
                      context, "Email address already used!");
                }
              } catch (e) {
                if (e.code == "ERROR_WEAK_PASSWORD") {
                  pr.hide();
                  GradientSnackBar.showMessage(context,
                      "Weak password, password should be at least 6 characters!");
                }
              }
            } else {
              GradientSnackBar.showMessage(context,
                  "Weak password, password should be at least 6 characters long!");
            }
          } else {
            GradientSnackBar.showMessage(
                context, "Please provide valid email!");
          }
        } else {
          GradientSnackBar.showMessage(context, "Password is required!");
        }
      } else {
        GradientSnackBar.showMessage(context, "Email is required!");
      }
    } else {
      GradientSnackBar.showMessage(context, "Username is required!");
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
            icon: Image.asset(
              'assets/icons/left-arrow.png',
              width: width * 0.07,
              height: height * 0.07,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      backgroundColor: Palette.backgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Create Account,",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "Sign up to get started!",
                      style:
                          TextStyle(fontSize: 20, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: username,
                      decoration: InputDecoration(
                        labelText: "User Name",
                        labelStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Palette.mainAppColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        labelStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Palette.mainAppColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: password,
                      obscureText: secureText,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                            onTap: () {
                              if (secureText) {
                                setState(() {
                                  secureText = false;
                                });
                              } else {
                                setState(() {
                                  secureText = true;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                secureText
                                    ? 'assets/icons/eye_open.png'
                                    : 'assets/icons/eye_close.png',
                                width: 30,
                                height: 30,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            )),
                        labelText: "Password",
                        labelStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Palette.mainAppColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 50,
                      child: FlatButton(
                        onPressed: () async {
                          await done();
                        },
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Palette.mainAppColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            constraints: BoxConstraints(
                                minHeight: 50, maxWidth: double.infinity),
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "I'm already a member.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Sign in.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Palette.mainAppColor,
                            fontSize: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
