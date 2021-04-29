import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/Components/validations.dart';
import 'package:provider/theme/style.dart';
import 'package:fluttertoast/fluttertoast.dart';

class JourneyEndScreen extends StatefulWidget {
  final String journeyID;

  JourneyEndScreen({this.journeyID});

  @override
  _JourneyEndScreenState createState() => _JourneyEndScreenState();
}

class _JourneyEndScreenState extends State<JourneyEndScreen> {
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  bool autovalidate = false;
  Validations validations = new Validations();
  TextEditingController nameController = TextEditingController();
  TextEditingController cprConroller = TextEditingController();

  bool isNameEmpty = false, isCPREmpty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Stack(children: <Widget>[
            new Padding(
                padding: EdgeInsets.fromLTRB(18.0, 150.0, 18.0, 0.0),
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                                        'Journey End Info',
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
                                                  hintText: 'Receiver Name',
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey,
                                                      fontFamily:
                                                          'Quicksand'))),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(top: 20.0)),
                                          TextFormField(
                                              controller: cprConroller,
                                              keyboardType:
                                                  TextInputType.number,
                                              validator:
                                                  validations.validateCPR,
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
                                                      cprConroller.text = "";
                                                    },
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 15.0,
                                                          top: 15.0),
                                                  hintText: 'Receiver CPR',
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey,
                                                      fontFamily:
                                                          'Quicksand'))),
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
                                                cprConroller.text.isNotEmpty) {
                                              // SharedPreferences prefs =
                                              //     await SharedPreferences
                                              //         .getInstance();
                                              // String userID =
                                              //     prefs.getString('userID');

                                              DocumentReference docRef =
                                                  Firestore.instance
                                                      .collection(
                                                          'journey_history')
                                                      .document(
                                                          widget.journeyID);
                                              Map<String, dynamic> data = {
                                                'receiver_name':
                                                    nameController.text,
                                                'receiver_cpr':
                                                    cprConroller.text
                                              };
                                              print('updated data: ' +
                                                  data.toString());
                                              docRef
                                                  .updateData(data)
                                                  .then((document) {
                                                print(
                                                    'journey data being updated');
                                              }).whenComplete(() async {
                                                print(
                                                    'journey data is updated');
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Successfully Added the Receiver's Info",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    timeInSecForIos: 3,
                                                    backgroundColor:
                                                        Colors.blue,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                                Navigator.of(context)
                                                    .pushNamedAndRemoveUntil(
                                                        '/home',
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);
                                                // Navigator.of(context)
                                                //     .pushNamedAndRemoveUntil(
                                                //         '/walkthrough',
                                                //         (Route<dynamic>
                                                //                 route) =>
                                                //             false);
                                              }).catchError((error) {
                                                print(
                                                    'journey not updated ...error');
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
