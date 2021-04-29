import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/Screen/MyProfile/Image1.dart';
import 'package:provider/Screen/MyProfile/ProfileModel.dart';
import 'package:provider/theme/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/Components/inputDropdown.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import '../../Dialog.dart';

const double _kPickerSheetHeight = 216.0;

class MyProfile extends StatefulWidget {

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  ProgressDialog pr;
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> listGender = [
    {
      "id": '0',
      "name": 'Male',
    },
    {
      "id": '1',
      "name": 'Female',
    }
  ];
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  String selectedGender;
  String lastSelectedValue;
  DateTime date = DateTime.now();
  File _image;
  PickedFile imageFile;
  String _uploadedFileURL;
  String username = '';
  String totalEarned = '0', totalDistance = '0';
  double hoursOnline = 0.0;
  int totalJobs = 0;
  dynamic pickImageError;

  final ImagePicker _picker = ImagePicker();

  var image;

  String phoneNumber = '', email = '', userImage = '';

  // progressBars(context, pr) {
  //   //  pr = ProgressDialog(context);
  //   //For normal dialog
  //   // pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
  //
  //   pr.style(
  //       message: 'Please Wait...',
  //       borderRadius: 10.0,
  //       backgroundColor: Colors.black,
  //       progressWidget: CircularProgressIndicator(),
  //       elevation: 10.0,
  //       insetAnimCurve: Curves.easeInOut,
  //       progress: 0.0,
  //       maxProgress: 100.0,
  //       progressTextStyle: TextStyle(
  //           color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w400),
  //       messageTextStyle: TextStyle(
  //           color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w600)
  //   );
  //   pr.show();
  //   Future.delayed(Duration(seconds:6)).then((value) {
  //     pr.hide();
  //   });
  // }




  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    try {
      final pickedFile = await _picker.getImage(
        source: source,
      );
      setState(() {
        imageFile = pickedFile;
        _image=File(imageFile.path);
        //  imageFile = pickedFile;
      });
    } catch (e) {
      setState(() {
        pickImageError = e;
      });
    }
  }

//  Future getImageLibrary() async {
//    var gallery =
//        await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 700);
//    setState(() {
//      _image = gallery;
//      print('GALLERY IMAGE: ' + _image.toString());
//    });
//  }
//
//  Future cameraImage() async {
//    var image =
//        await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 700);
//    setState(() {
//      _image = image;
//      print('CAMERA IMAGE: ' + _image.toString());
//    });
//  }

  @override
  void initState() {
    // TODO: implement initState
    pr = ProgressDialog(context);
    super.initState();
    _getUserData();
  }

  Future _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    nameController.text=prefs.getString('username');
    emailController.text=prefs.getString('email');
    String userID = prefs.getString('userID');
    await Firestore.instance
        .collection('LM_Driver')
        .document(userID)
        .get()
        .then((DocumentSnapshot snap) {
      print('USER DATA: ' + snap.data.toString());
      setUserData(snap.data);
    });
  }

  getDefaultPic() async {
    final ref = FirebaseStorage.instance.ref().child('user_default.png');
// no need of the file extension, the name will do fine.
    setState(() async {
      userImage = await ref.getDownloadURL();
      print('GETTING DEFAULT PIC' + userImage.toString());
    });
  }

  Future setUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//    final FirebaseAuth _auth = FirebaseAuth.instance;
//
//    final FirebaseUser currentUser = await _auth.currentUser();
//
//    DocumentReference docRef = Firestore.instance
//        .collection('LM_Driver')
//        .document(currentUser.uid);
//    if(docRef[])
    prefs.setString('username', userData['name']);
    prefs.setString('totalEarned', userData['money_earned']);
    prefs.setInt('totalJobs', userData['total_jobs']);
    prefs.setDouble('hoursOnline', userData['hours_online']);
    prefs.setString('totalDistance', userData['total_distance']);
    prefs.setString('phoneNumber', userData['phone_number']);
    prefs.setString('email', userData['email']??"");
    prefs.setBool('complete_profile', userData['all']);
    phoneController.text = prefs.getString('phoneNumber');
    print('USERNAME: ' + userData['name']);
    setState(() {

      if (userData['profile_pic'] == null) {
        getDefaultPic();
      } else {
        userImage = userData['profile_pic'];
      }
      username = userData['name'];
      print(username);
      totalEarned = userData['money_earned'];
      print('totalEarned ' + totalEarned.toString());
      totalJobs = userData['total_jobs'];
      print('totalJobs ' + totalJobs.toString());
      hoursOnline = userData['hours_online'];
      print('hoursOnline ' + hoursOnline.toString());
      totalDistance = userData['total_distance'];
      print('totalDistance ' + totalDistance.toString());
      phoneNumber = userData['phone_number'];
      email = userData['email'];
      //nameController.text = username;
      //emailController.text = email;
      phoneController.text = phoneNumber;
    });
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  void showDemoActionSheet({BuildContext context, Widget child}) {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((String value) {
      if (value != null) {
        setState(() {
          lastSelectedValue = value;
        });
      }
    });
  }

  selectCamera() {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
          title: const Text('Select Camera'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text('Camera'),
              onPressed: () {
                Navigator.pop(context, 'Camera');
                _onImageButtonPressed(ImageSource.camera, context: context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Photo Library'),
              onPressed: () {
                Navigator.pop(context, 'Photo Library');
                _onImageButtonPressed(ImageSource.gallery, context: context);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
          )),
    );
  }

  void SubmitData()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID');

      if (imageFile != null) {
        image = File(imageFile.path);
        // Future uploadFile() async {
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('service_provider/${path.basename(imageFile.path)}}');
        StorageUploadTask uploadTask = storageReference.putFile(File(imageFile.path));
        StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
        String url = (await downloadUrl.ref.getDownloadURL());
        setState(() {
          _uploadedFileURL = url;
        });

      }





      Firestore.instance
        .collection('LM_Driver')
        .document(userID)
        .updateData({
        'name': nameController.text.toString(),
        'email': emailController.text.toString(),
        'phone_number': phoneController.text.toString(),
        'profile_pic': _uploadedFileURL,
    });
    pr.hide();
     Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Image1()));
  }







//   submit() async {
//     // final FormState form = formKey.currentState;
//     // form.save();
//
//    {
//
//
//
//
//       DocumentReference docRef =
//       Firestore.instance.collection('LM_Driver').document(userID);
//       Map<String, dynamic> data = {
//         'name': nameController.text,
//         'email': emailController.text,
//         'phone_number': phoneController.text,
//         'profile_pic': _uploadedFileURL,
//       };
//       print('updated data: ' + data.toString());
//       docRef.updateData(data).then((document) {
//         print('profile data being updated');
//       }).whenComplete(() async {
//         print('profile data is updated');
//
//          // Navigator.of(context)
//          //     .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
//       }).catchError((error) {
//         print('profile not updated ...error');
//         pr.hide();
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (BuildContext context) => Image1()),
//           ModalRoute.withName('/'),
//         );
// //        pr.hide();
//       });
//       // }
//     } else {
//       print('empty cells');
//     }
//   }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: blackColor),
        elevation: 0.0,
        backgroundColor: whiteColor,
        title: Text(
          'My Profile',
          style: TextStyle(color: blackColor),
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              child: Form(
                key: formKey,
                child: Container(
                  color: Color(0xffeeeeee),
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: whiteColor,
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.only(bottom: 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(50.0),
                              child: new ClipRRect(
                                  borderRadius:
                                      new BorderRadius.circular(100.0),
                                  child: _image == null
                                      ? new GestureDetector(
                                          onTap: () {
                                            selectCamera();
                                          },
                                          child: new Container(
                                              height: 80.0,
                                              width: 80.0,
                                              color: primaryColor,
                                              child: new Image.asset(
                                                userImage == null?
                                                'assets/image/icon/avatar.png':userImage,
                                                fit: BoxFit.cover,
                                                height: 80.0,
                                                width: 80.0,
                                              )))
                                      : new GestureDetector(
                                          onTap: () {
                                            selectCamera();
                                          },
                                          child: new Container(
                                            height: 80.0,
                                            width: 80.0,
                                            child: Image.file(
                                              _image,
                                              fit: BoxFit.cover,
                                              height: 800.0,
                                              width: 80.0,
                                            ),
                                          ))),
                            ),
                            Expanded(
                                child: Container(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  TextFormField(
                                    style: textStyle,
                                    decoration: InputDecoration(
                                        fillColor: whiteColor,
                                        labelStyle: textStyle,
                                        hintStyle:
                                            TextStyle(color: Colors.black),
                                        counterStyle: textStyle,
                                        hintText: "Name",
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white))),
                                    controller: nameController,
                                    validator: (text) {
                                      if (nameController != null) {
                                        return "Enter Name";
                                      }
                                      return null;
                                    },
                                    //     new TextEditingController.fromValue(
                                    //   new TextEditingValue(
                                    //     text: username,
                                    //     selection: new TextSelection.collapsed(
                                    //         offset: 11),
                                    //   ),
                                    // ),
                                    onChanged: (String _firstName) {},
                                  ),
                                  // TextField(
                                  //   style: textStyle,
                                  //   decoration: InputDecoration(
                                  //       fillColor: whiteColor,
                                  //       labelStyle: textStyle,
                                  //       hintStyle:
                                  //           TextStyle(color: Colors.white),
                                  //       counterStyle: textStyle,
                                  //       hintText: "Last Name",
                                  //       border: UnderlineInputBorder(
                                  //           borderSide: BorderSide(
                                  //               color: Colors.white))),
                                  //   controller:
                                  //       new TextEditingController.fromValue(
                                  //     new TextEditingValue(
                                  //       text: "Last Name",
                                  //       selection: new TextSelection.collapsed(
                                  //           offset: 11),
                                  //     ),
                                  //   ),
                                  //   onChanged: (String _lastName) {},
                                  // ),
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
                      Container(
                        color: whiteColor,
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.only(top: 10.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Text(
                                        "Phone Number",
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      style: textStyle,
                                      keyboardType: TextInputType.phone,
                                        enableInteractiveSelection: false,
                                      enabled: false,
                                      decoration: InputDecoration(
                                          fillColor: whiteColor,
                                          labelStyle: textStyle,
                                          hintStyle:
                                              TextStyle(color: Colors.black),
                                          counterStyle: textStyle,
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white))),
                                      controller: phoneController,
                                      validator: (text) {
                                        if (phoneController != null) {
                                          return "Enter Name";
                                        }
                                        return null;
                                      },
                                      //     new TextEditingController.fromValue(
                                      //   new TextEditingValue(
                                      //     text: phoneNumber,
                                      //     selection:
                                      //         new TextSelection.collapsed(
                                      //             offset: 11),
                                      //   ),
                                      // ),
                                      onChanged: (String _phone) {},
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Text(
                                        "Email",
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      keyboardType: TextInputType.emailAddress,
                                      style: textStyle,
                                      decoration: InputDecoration(
                                          fillColor: whiteColor,
                                          labelStyle: textStyle,
                                          hintStyle:
                                              TextStyle(color: Colors.black),
                                          counterStyle: textStyle,
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white))),
                                      controller: emailController,
                                      validator: (text) {
                                        if (emailController != null) {
                                          return "Enter Name";
                                        }
                                        return null;
                                      },
                                      //     new TextEditingController.fromValue(
                                      //   new TextEditingValue(
                                      //     text: email,
                                      //     selection:
                                      //         new TextSelection.collapsed(
                                      //             offset: 11),
                                      //   ),
                                      // ),
                                      onChanged: (String _email) {},
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Text(
                                        "Gender",
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: new DropdownButtonHideUnderline(
                                        child: Container(
                                      // padding: EdgeInsets.only(bottom: 12.0),
                                      child: new InputDecorator(
                                        decoration: const InputDecoration(),
                                        isEmpty: selectedGender == null,
                                        child: new DropdownButton<String>(
                                          hint: new Text(
                                            "Gender",
                                            style: textStyle,
                                          ),
                                          value: selectedGender,
                                          isDense: true,
                                          onChanged: (String newValue) {
                                            setState(() {
                                              selectedGender = newValue;
                                              print(selectedGender);
                                            });
                                          },
                                          items: listGender.map((value) {
                                            return new DropdownMenuItem<String>(
                                              value: value['id'],
                                              child: new Text(
                                                value['name'],
                                                style: textStyle,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    )),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Text(
                                        "Birthday",
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: GestureDetector(
                                        onTap: () {
                                          showCupertinoModalPopup<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return _buildBottomPicker(
                                                CupertinoDatePicker(
                                                  mode: CupertinoDatePickerMode
                                                      .date,
                                                  initialDateTime: date,
                                                  onDateTimeChanged:
                                                      (DateTime newDateTime) {
                                                    setState(() {
                                                      date = newDateTime;
                                                    });
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: new InputDropdown(
                                          valueText:
                                              DateFormat.yMMMMd().format(date),
                                          valueStyle:
                                              TextStyle(color: blackColor),
                                        )),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 20.0),
                              child: new ButtonTheme(
                                height: 45.0,
                                minWidth:
                                    MediaQuery.of(context).size.width - 50,
                                child: RaisedButton.icon(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  elevation: 0.0,
                                  color: primaryColor,
                                  icon: new Text(''),
                                  label: new Text(
                                    'NEXT',
                                    style: headingwhite,
                                  ),
                                  onPressed: () {
                                    pr.show();
//                                     Dialogs().progressBars(context, pr);

                                    SubmitData();


                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
