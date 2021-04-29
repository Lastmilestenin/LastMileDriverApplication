import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/Screen/Walkthrough/walkthrough.dart';
import 'package:provider/theme/style.dart';
import 'package:provider/Components/validations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool autovalidate = false;
  Validations validations = new Validations();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();
  TextEditingController serviceProviderController = TextEditingController();

  bool isNameEmpty = false, isEmailEmpty = false, isPasswordEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Stack(children: <Widget>[
            // Container(
            //   height: 250.0,
            //   width: double.infinity,
            //   decoration: BoxDecoration(
            //       image: DecorationImage(
            //           image: AssetImage("assets/image/icon/Layer_2.png"),
            //           fit: BoxFit.cover)),
            // ),
            new Padding(
                padding: EdgeInsets.fromLTRB(18.0, 150.0, 18.0, 0.0),
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: new Column(
                      children: <Widget>[
                        new Container(
                            //padding: EdgeInsets.only(top: 100.0),
                            child: new Material(
                          borderRadius: BorderRadius.circular(7.0),
                          elevation: 5.0,
                          child: new Container(
                            width: MediaQuery.of(context).size.width - 20.0,
                            height: MediaQuery.of(context).size.height * 0.7,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0)),
                            child: new Form(
                                autovalidate: autovalidate,
                                key: formKey,
                                child: new Container(
                                  padding: EdgeInsets.all(18.0),
                                  child: new Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Profile Information',
                                        style: heading35Black,
                                      ),
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          TextFormField(
                                              validator:
                                                  validations.validateName,
                                              controller: nameController,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      CupertinoIcons
                                                          .clear_thick_circled,
                                                      color: greyColor2,
                                                    ),
                                                    onPressed: () {
                                                      nameController.text = "";
                                                    },
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 15.0,
                                                          top: 15.0),
                                                  hintText: 'Name',
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey,
                                                      fontFamily:
                                                          'Quicksand'))),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(top: 20.0)),
                                          TextFormField(
                                              controller: emailController,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator:
                                                  validations.validateEmail,
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      CupertinoIcons
                                                          .clear_thick_circled,
                                                      color: greyColor2,
                                                    ),
                                                    onPressed: () {
                                                      emailController.text = "";
                                                    },
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 15.0,
                                                          top: 15.0),
                                                  hintText: 'Email',
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey,
                                                      fontFamily:
                                                          'Quicksand'))),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(top: 20.0)),
                                          // TextFormField(
                                          //     controller: passwordController,
                                          //     keyboardType:
                                          //         TextInputType.visiblePassword,
                                          //     validator:
                                          //         validations.validatePassword,
                                          //     decoration: InputDecoration(
                                          //         border: OutlineInputBorder(
                                          //           borderRadius:
                                          //               BorderRadius.circular(
                                          //                   5.0),
                                          //         ),
                                          //         suffixIcon: IconButton(
                                          //           icon: Icon(
                                          //             CupertinoIcons
                                          //                 .clear_thick_circled,
                                          //             color: greyColor2,
                                          //           ),
                                          //           onPressed: () {
                                          //             passwordController.text =
                                          //                 "";
                                          //           },
                                          //         ),
                                          //         contentPadding:
                                          //             EdgeInsets.only(
                                          //                 left: 15.0,
                                          //                 top: 15.0),
                                          //         hintText: 'Password',
                                          //         hintStyle: TextStyle(
                                          //             color: Colors.grey,
                                          //             fontFamily:
                                          //                 'Quicksand'))),
                                          // Padding(
                                          //     padding:
                                          //         EdgeInsets.only(top: 20.0)),
//                                          TextFormField(
//                                              controller:
//                                                  serviceProviderController,
//                                              keyboardType: TextInputType.text,
//                                              decoration: InputDecoration(
//                                                  border: OutlineInputBorder(
//                                                    borderRadius:
//                                                        BorderRadius.circular(
//                                                            5.0),
//                                                  ),
//                                                  suffixIcon: IconButton(
//                                                    icon: Icon(
//                                                      CupertinoIcons
//                                                          .clear_thick_circled,
//                                                      color: greyColor2,
//                                                    ),
//                                                    onPressed: () {
//                                                      serviceProviderController
//                                                          .text = "";
//                                                    },
//                                                  ),
//                                                  contentPadding:
//                                                      EdgeInsets.only(
//                                                          left: 15.0,
//                                                          top: 15.0),
//                                                  hintText:
//                                                      'Service Provider/Private',
//                                                  hintStyle: TextStyle(
//                                                      color: Colors.grey,
//                                                      fontFamily:
//                                                          'Quicksand'))),
                                        ],
                                      ),
                                      new ButtonTheme(
                                        height: 50.0,
                                        minWidth:
                                            MediaQuery.of(context).size.width,
                                        child: RaisedButton.icon(
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0)),
                                          elevation: 0.0,
                                          color: primaryColor,
                                          icon: new Text(''),
                                          label: new Text(
                                            'SUBMIT',
                                            style: headingWhite,
                                          ),
                                          onPressed: () async {
                                            if (nameController
                                                        .text.isNotEmpty &&
                                                    emailController
                                                        .text.isNotEmpty
                                                //     &&
                                                // passwordController
                                                //     .text.isNotEmpty
                                                ) {
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              String userID =
                                                  prefs.getString('userID');

                                              DocumentReference docRef =
                                                  Firestore.instance
                                                      .collection(
                                                          'LM_Driver')
                                                      .document(userID);
                                              Map<String, dynamic> data = {
                                                'name': nameController.text,
                                                'email': emailController.text,
                                                // 'password':
                                                //     passwordController.text,
                                                'service_provider':
                                                    'Provider',
                                                'money_earned': '0',
                                                'total_jobs': 0,
                                                'total_distance': '0',
                                                'hours_online': 0.5
                                              };
                                              print('updated data: ' +
                                                  data.toString());
                                              docRef
                                                  .updateData(data)
                                                  .then((document) {
                                                print(
                                                    'profile data being updated');
                                              }).whenComplete(() async {
                                                print(
                                                    'profile data is updated');
                                                Navigator.of(context)
                                                    .pushNamedAndRemoveUntil(
                                                        '/walkthrough',
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);
                                              }).catchError((error) {
                                                print(
                                                    'profile not updated ...error');
                                              });
                                            } else {
                                              print('empty cells');
                                              setState(() {
                                                autovalidate = true;
                                              });
                                            }

                                            // submit();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        )),
                      ],
                    ))),
          ])
        ]),
      )),
    );
  }
}
