import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/theme/style.dart';
import 'package:provider/Screen/Home/home.dart';
import 'package:provider/Components/validations.dart';
import 'package:provider/Screen/Login/phoneVerification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class SignupScreen2 extends StatefulWidget {
  @override
  _SignupScreen2State createState() => _SignupScreen2State();
}

class _SignupScreen2State extends State<SignupScreen2> {
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool autovalidate = false;
  var code;
  Validations validations = new Validations();
  final phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                Widget>[
              Column(children: <Widget>[
                // Container(
                //   height: 250.0,
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //       image: DecorationImage(
                //           image: AssetImage("assets/image/icon/Layer_2.png"),
                //           fit: BoxFit.cover
                //       )
                //   ),
                // ),
                SizedBox(height: 100,),
                Center(child: Image.asset('assets/Picture1.png')),
                new Padding(
                    padding: EdgeInsets.fromLTRB(18.0, 100.0, 18.0, 0.0),
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: double.infinity,
                        child: new Column(
                          children: <Widget>[
                            new Container(
                              //padding: EdgeInsets.only(top: 100.0),
                                child: new Material(
                                  borderRadius: BorderRadius.circular(7.0),
                                  elevation: 10.0,
                                  child: new Container(
                                    width: MediaQuery.of(context).size.width - 20.0,
                                    height: MediaQuery.of(context).size.height * 0.40,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20.0)),
                                    child: new Form(
                                        child: new Container(
                                          padding: EdgeInsets.all(18.0),
                                          child: new Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                height: 50.0,
                                                width: 300.0,
                                                child: Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      'Sign up',
                                                      style: headingBlack2,
                                                    ),
//                                                        Text(' with email and phone number', style: heading35BlackNormal,),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    decoration:BoxDecoration(
                                                      border: Border.all(color: Colors.grey),
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                    child:CountryCodePicker(

                                                      onChanged:(c){
                                                        code = c;
                                                        print(c.toString());
                                                      } ,
                                                      // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                                      initialSelection: 'DE',
                                                      favorite: ['+49','GERMANY'],
                                                      // optional. Shows only country name and flag
                                                      showCountryOnly: false,
                                                      // optional. Shows only country name and flag when popup is closed.
                                                      showOnlyCountryWhenClosed: false,
                                                      // optional. aligns the flag and the Text left
                                                      alignLeft: false,
                                                    ), ),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width/1.9,
                                                    child: TextFormField(
                                                        controller: phoneController,
                                                        keyboardType: TextInputType.phone,
                                                        validator: validations.validateMobile,
                                                        decoration: InputDecoration(
                                                            border: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(5.0),
                                                            ),
                                                            prefixIcon: Icon(Icons.phone,
                                                                color: blackColor,
                                                                size: 20.0),
                                                            contentPadding: EdgeInsets.only(
                                                                left: 15.0, top: 15.0),
                                                            hintText: 'Phone',
                                                            hintStyle: TextStyle(
                                                                color: Colors.grey,
                                                                fontFamily: 'Quicksand'))),
                                                  ),
                                                ],
                                              ),
                                              Divider(),
                                              // new Container(
                                              //     padding: EdgeInsets.only(
                                              //         top: 20.0, bottom: 20.0),
                                              //     child: new Row(
                                              //       mainAxisAlignment:
                                              //           MainAxisAlignment.center,
                                              //       children: <Widget>[
                                              //         InkWell(
                                              //           child: new Text(
                                              //             "Forgot Password ?",
                                              //             style: textStyleActive,
                                              //           ),
                                              //         ),
                                              //       ],
                                              //     )),
                                              new ButtonTheme(
                                                height: 50.0,
                                                minWidth: MediaQuery.of(context).size.width,
                                                child: RaisedButton.icon(
                                                  shape: new RoundedRectangleBorder(
                                                      borderRadius:
                                                      new BorderRadius.circular(5.0)),
                                                  elevation: 0.0,
                                                  color: primaryColor,
                                                  icon: new Text(''),
                                                  label: new Text(
                                                    'SIGN UP',
                                                    style: headingWhite,
                                                  ),
                                                  onPressed: () {
                                                    String valid =
                                                    validations.validateMobile(
                                                        phoneController.text);
                                                    // print('validation Error: ' + valid);

                                                    if (valid != null) {
                                                      print('VALIDATION ERROR: ' + valid);
                                                    } else {
                                                      _sendCodeToPhoneNumber();
                                                    }
                                                    // _sendCodeToPhoneNumber();
                                                    // Navigator.of(context).pushReplacement(
                                                    //     new MaterialPageRoute(
                                                    //         builder: (context) =>
                                                    //             new HomeScreen()));
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                )),
                            new Container(
                                padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Text(
                                      "Continue With Phone Number",
                                      style: textGrey,
                                    ),
                                    // new InkWell(
                                    //   onTap: () =>
                                    //       Navigator.pushNamed(context, '/login'),
                                    //   child: new Text(
                                    //     "Login",
                                    //     style: textStyleActive1,
                                    //   ),
                                    // ),
                                  ],
                                )),
                          ],
                        ))),
              ])
            ]),
          )),
    );
  }

  Future<void> _sendCodeToPhoneNumber() async {
    String phoneNumber = phoneController.text;
    String mum= code.toString() + phoneNumber.toString();

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential credential) {
      setState(() {
        // widget.isAutoSignIn = true;
        // widget.isVerificationCompleted = true;
        print(
            'Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $credential');
      });

      // DocumentReference docRef =
      //     Firestore.instance.collection('LM_Driver').document(user.uid);
      // Map<String, dynamic> data = {
      //   'name': 'Ali Hassan',
      //   'status': 'offline',
      //   'service_provider': 'Al Manar Services'
      // };
      // docRef.setData(data).then((document) {
      //   print('setting it up');
      // }).whenComplete(() {
      //   print('task completed');
      // });
      // MaterialPageRoute(builder: (context) => MyHomePage());
      // Navigator.of(context).pushReplacement(
      //     new MaterialPageRoute(builder: (context) => WalkthroughScreen()));
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        print(
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      // this.verificationId = verificationId;

      // if (!widget.isVerificationCompleted) {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => VerificationNumberWidget(
      //             verification: this.verificationId, phoneNumber: this.phone)),
      //   );
      // } else {
      // MaterialPageRoute(builder: (context) => PhoneVerification());
      // }

      print("code sent to your number : " + phoneNumber);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PhoneVerification(
                  verificationId: verificationId, phoneNumber: phoneNumber)));
      print('going to next screen');
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      // this.verificationId = verificationId;
      print("time out");
    };

    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: mum,
        timeout: const Duration(seconds: 120),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }
}