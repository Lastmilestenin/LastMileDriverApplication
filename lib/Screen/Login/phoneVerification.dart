import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/Screen/SignUp/signup2.dart';
import 'package:provider/theme/style.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:provider/Screen/Login/login.dart';
import 'package:provider/Screen/Walkthrough/walkthrough.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneVerification extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  PhoneVerification(
      {Key key, @required this.verificationId, @required this.phoneNumber})
      : super(key: key);

  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  TextEditingController controller = TextEditingController();
  String thisText = "";
  int pinLength = 6;

  bool hasError = false;
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: whiteColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: blackColor,
          ),
          onPressed: () => Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => SignupScreen2())),
        ),
      ),
      body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Container(
              color: whiteColor,
              padding: EdgeInsets.fromLTRB(
                  screenSize.width * 0.13, 0.0, screenSize.width * 0.13, 0.0),
              child: Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 10.0),
                        child: Text(
                          'Phone Verification',
                          style: headingBlack,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 0.0),
                        child: Text('Enter your OTP code here'
                          ,style: headingBlack3 ,),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        padding: EdgeInsets.only(top: 30.0, bottom: 60.0),
                        child: PinCodeTextField(
                          autofocus: true,
                          controller: controller,
                          hideCharacter: false,
                          highlight: true,
                          highlightColor: secondary,
                          defaultBorderColor: blackColor,
                          hasTextBorderColor: primaryColor,
                          maxLength: pinLength,
                          hasError: hasError,
                          maskCharacter: "*",
                          onTextChanged: (text) {
                            setState(() {
                              hasError = false;
                            });
                          },
                          onDone: (text) {
                            print("DONE $text");
                          },
                          pinCodeTextFieldLayoutType:
                          PinCodeTextFieldLayoutType.WRAP,
                          wrapAlignment: WrapAlignment.start,
                          pinBoxDecoration:
                          ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                          pinTextStyle: heading35Black,
                          pinTextAnimatedSwitcherTransition:
                          ProvidedPinBoxTextAnimation.scalingTransition,
                          pinTextAnimatedSwitcherDuration:
                          Duration(milliseconds: 300),
                        ),
                      ),
                      new ButtonTheme(
                        height: 45.0,
                        minWidth: MediaQuery.of(context).size.width - 50,
                        child: RaisedButton.icon(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0)),
                          elevation: 0.0,
                          color: primaryColor,
                          icon: new Text(''),
                          label: new Text(
                            'VERIFY NOW',
                            style: headingWhite,
                          ),
                          onPressed: () {
                            _signInWithPhoneNumber();
                            // Navigator.of(context).pushReplacement(
                            //     new MaterialPageRoute(
                            //         builder: (context) => WalkthroughScreen()));
                          },
                        ),
                      ),
                      new Container(
                          padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new InkWell(
                                onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder:(_)=> SignupScreen2())),
                                child: new Text(
                                  "I didn't get a code",
                                  style: textStyleActive1,
                                ),
                              ),
                            ],
                          )),
                    ]),
              ),
            ),
          )),
    );
  }

  void _signInWithPhoneNumber() async {
    // String phoneNumber = widget.
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => WalkthroughScreen()));
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: widget.verificationId,
      smsCode: controller.text,
    );
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() async {
      // Location location = new Location();
      // location.getLocation();
     // FirebaseUser user = await _auth.currentUser();
      var check = false;
        Firestore.instance
          .collection('LM_Driver')
          .document(currentUser.uid.toString())
          .get()
          .then((DocumentSnapshot snap) async {
        if (snap.data['email']!=null && snap.data['profile_pic']!=null)
          {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.clear();
            prefs.setString('userID', user.uid);
            String userID = prefs.getString('userID');
            print('USERID : ' + userID);
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
          }else{
          setState(() {
            Location location = new Location();
            location.getLocation().then((value) {
              DocumentReference docRef = Firestore.instance
                  .collection('LM_Driver')
                  .document(user.uid);
              Map<String, dynamic> data = {
                'name': "",
                'email': "",
                // 'password':
                //     passwordController.text,
                'service_provider':
                'Provider',
                'money_earned': '0',
                'total_jobs': 0,
                'total_distance': '0',
                'hours_online': 0.5,
                'phone_number': widget.phoneNumber.toString(),
                'status': 'offline',
                'isShowLocation': false,
                'position': {
                  'latitude': value.latitude,
                  'longitude': value.longitude,
                }
              };
              print('submitted data: ' + data.toString());
              docRef.setData(data).then((document) {
                print('_signInWithPhoneNumber setting it up');
              }).whenComplete(() async {
                print('_signInWithPhoneNumber task completed');
                SharedPreferences prefs = await SharedPreferences.getInstance();
                // String email = prefs.getString('userID');
                prefs.setString('userID', user.uid);
                prefs.setString('phonenumber', widget.phoneNumber.toString());
                String userID = prefs.getString('userID');
                print('USERID : ' + userID);
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/edit_prifile', (Route<dynamic> route) => false);
                // print('Pressed $counter times.');
                // await prefs.setInt('counter', counter);
              }).catchError((error) {
                print('_signInWithPhoneNumber error faced');
              });
            });
          });
        }
      });

      // if (user != null) {
      //   print('_signInWithPhoneNumber Successfully signed in, uid: ' + user.uid);
      //   DocumentReference docRef = Firestore.instance
      //       .collection('LM_Driver')
      //       .document(user.uid);
      //   Map<String, dynamic> data = {
      //     'name': "",
      //     'email': "",
      //     // 'password':
      //     //     passwordController.text,
      //     'service_provider':
      //     'Provider',
      //     'money_earned': '0',
      //     'total_jobs': 0,
      //     'total_distance': '0',
      //     'hours_online': 0.5,
      //     'phone_number': widget.phoneNumber.toString(),
      //     'status': 'offline',
      //     'isShowLocation': false,
      //     'position': {
      //       'latitude': 24.95028893,
      //       'longitude': 67.04050944,
      //     },
      //     'all': false,
      //   };
      //   print('submitted data: ' + data.toString());
      //   docRef.setData(data).then((document) {
      //     print('_signInWithPhoneNumber setting it up');
      //   }).whenComplete(() async {
      //     print('_signInWithPhoneNumber task completed');
      //     SharedPreferences prefs = await SharedPreferences.getInstance();
      //     // String email = prefs.getString('userID');
      //     prefs.setString('userID', user.uid);
      //     prefs.setString('phonenumber', widget.phoneNumber.toString());
      //     String userID = prefs.getString('userID');
      //     print('USERID : ' + userID);
      //     Navigator.of(context).pushNamedAndRemoveUntil(
      //         '/edit_prifile', (Route<dynamic> route) => false);
      //     // print('Pressed $counter times.');
      //     // await prefs.setInt('counter', counter);
      //   }).catchError((error){
      //     print('_signInWithPhoneNumber error faced');
      //   });
      // } else {
      //   print('Sign in failed');
      // }
    });
  }
}