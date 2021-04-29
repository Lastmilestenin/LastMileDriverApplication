import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/Screen/Home/home.dart';
import 'package:provider/Screen/MyProfile/ProfileModel.dart';
import 'package:provider/data/globalvariables.dart';
import 'package:provider/theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:provider/data/globalvariables.dart';


import '../../Dialog.dart';

class Image4 extends StatefulWidget {

  ProfileModel profilemodel;

  Image4({this.profilemodel});

  @override
  _Image4State createState() => _Image4State();
}

class PrimitiveWrapper {
  var value;
  PrimitiveWrapper(this.value);
}

class _Image4State extends State<Image4> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  final _formKey = GlobalKey<FormState>();
  ProgressDialog pr;
  var image1, image2, image3, image4;
  var imageerror = ' ', licence_imageerror = ' ', plate_imageerror = ' ';
  var currentSelectedValue, currentSelectedValueerror = ' ';
  PickedFile _imageFile, _imageFileL, _imageFileP;
  dynamic _pickImageError;
  final ImagePicker _picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController plateController = TextEditingController();

  File _pickedImageL4;


  @override
  void initState() {
    pr = ProgressDialog(context);
    super.initState();
  }


  _loadPicker(String title, ImageSource source,) async {
    File picked = await ImagePicker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _pickedImageL4 = picked;
        _previewImage(title,);

      });
    }
    // Navigator.pop(context);
  }





  Widget imageLicenceParse(String title ) {
    return Container(
      height: MediaQuery.of(context).size.height / 3.9,
      width: MediaQuery.of(context).size.width / 1.2,
      padding: const EdgeInsets.only(left: 22.0, right: 12.0, bottom: 5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width / 2.5,
                height: MediaQuery.of(context).size.height / 5.5,
                child: _previewImage(title, ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.camera),
                onPressed: () => _loadPicker(
                    title,
                    ImageSource.gallery,
                    ),
              ),
              IconButton(
                  icon: Icon(Icons.add_a_photo),
                  onPressed: () {
                    // camera();
                    _loadPicker(title , ImageSource.camera, );
                  })
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              licence_imageerror,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewImage(String title) {

    if (_pickedImageL4 != null) {
      return Image.file(
        File(
          _pickedImageL4.path,
        ),
        fit: BoxFit.fill,
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Align(
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.blueGrey),
        ),
      );
    }
  }

  Widget _emailPasswordWidget() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          Text('Step 4', style: heading22Black,),
          SizedBox(
            height: 10,
          ),

          imageLicenceParse("Auto Bild"),
          SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }






  Widget _entryPlateField(String title) {

    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width / 1.2,
      padding: const EdgeInsets.only(left: 22.0, right: 12.0, bottom: 5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Center(
        child: TextFormField(
          //     textAlign: TextAlign.center,
          controller: plateController,
          keyboardType: TextInputType.text,
          decoration: new InputDecoration.collapsed(
            hintText: title,
          ),
          validator: (text) {
            if (text == null || text.isEmpty) {
              return "Plate Number is empty";
            }
            return null;
          },
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title : Text('Registration')
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[

          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: _emailPasswordWidget(),
                      ),
                      //child: sendButton,
                      // Container(
                      //   margin: EdgeInsets.only(bottom: 10),
                      //   padding: EdgeInsets.only(top: 10, bottom: 10),
                      //   height: 70,
                      //   width: MediaQuery.of(context).size.width / 1.17,
                      //   child: FlatButton(
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     onPressed: () {
                      //       setState(() {
                      //         // currentSelectedValueerror = " ";
                      //         imageerror = " ";
                      //         // licence_imageerror = " ";
                      //         // plate_imageerror = " ";
                      //       });
                      //
                      //       int i = 0;
                      //       if (_pickedImageL1 == null) {
                      //         setState(() {
                      //           imageerror = "Profile picture is empty";
                      //           i = 1;
                      //         });
                      //       }
                      //       if (_formKey.currentState.validate() && i == 0) {
                      //         pr.show();
                      //         geturl();
                      //       }
                      //     },
                      //     //color: AppColors.blueColor,
                      //     child: Center(
                      //       child: Text(
                      //         "Continue",
                      //         style: TextStyle(color: Colors.white),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),


          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
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
                  //  Dialogs().progressBarsprofile(context, pr);
                    submit();
                  },
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  submit() async {
    // final FormState form = formKey.currentState;
    // form.save();

    if (  _pickedImageL4 != null
    // _pickedImageL1 != null && _pickedImageL2 != null && _pickedImageL3 != null &&
    ) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userID = prefs.getString('userID');
      Future.delayed(const Duration(seconds: 1), ()async {


        image4 = File(_pickedImageL4.path);
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('service_provider/${path.basename(_pickedImageL4.path)}}');
        StorageUploadTask uploadTask = storageReference.putFile(File(_pickedImageL4.path));
        StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
        String url2 = (await downloadUrl.ref.getDownloadURL());
        //setState(() {
        // Globals.uploadedFileURL.add(url);
        //
        //
        // storageReference = FirebaseStorage.instance
        //     .ref()
        //     .child('service_provider/${path.basename( Globals.imgpath1)}}');
        // uploadTask = storageReference.putFile(File( Globals.imgpath1));
        // downloadUrl = (await uploadTask.onComplete);
        // url = (await downloadUrl.ref.getDownloadURL());
        // //setState(() {
        // Globals.uploadedFileURL.add(url);
        //
        // storageReference = FirebaseStorage.instance
        //     .ref()
        //     .child('service_provider/${path.basename( Globals.imgpath2)}}');
        // uploadTask = storageReference.putFile(File(Globals.imgpath2));
        // downloadUrl = (await uploadTask.onComplete);
        // url = (await downloadUrl.ref.getDownloadURL());
        // //setState(() {
        // Globals.uploadedFileURL.add(url);
        //
        // storageReference = FirebaseStorage.instance
        //     .ref()
        //     .child('service_provider/${path.basename(Globals.imgpath3)}}');
        // uploadTask = storageReference.putFile(File(Globals.imgpath3));
        // downloadUrl = (await uploadTask.onComplete);
        // url = (await downloadUrl.ref.getDownloadURL());
        //setState(() {
        //Globals.uploadedFileURL.add(url);
        //});
//        StorageUploadTask uploadTask = storageReference.putFile(_image);
//        await uploadTask.onComplete;
//        print('File Uploaded');
//        storageReference.getDownloadURL().then((fileURL) {
//          setState(() {
//            _uploadedFileURL = fileURL;
//            print('_uploadedFileURL: ' + _uploadedFileURL);
//          });
//        });

        DocumentReference docRef =
        Firestore.instance.collection('LM_Driver').document(userID);
        Map<String, dynamic> data = {
          'image1': Globals.image1.toString(),
          'image2': Globals.image2.toString(),
          'image3': Globals.image3.toString(),
          'image4': url2,
        };
        print('updated data: ' + data.toString());
        docRef.updateData(data).then((document) {
          print('profile data being updated');
        }).whenComplete(() async {
          print('profile data is updated');
          prefs.setBool('complete_profile', true);

          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
        }).catchError((error) {
          print('profile not updated ...error');

          // Navigator.of(context)
          //     .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
//        pr.hide();
        });
        // }

      });
      pr.hide();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
        ModalRoute.withName('/'),
      );


    } else {
      print('empty cells');
    }
  }



// void geturl()async{
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String userID = prefs.getString('userID');
//
//   image = File(_pickedImageL1.path);
//   if (_pickedImageL1.path != null) {
//     final StorageReference storageReference =
//     FirebaseStorage.instance.ref().child("service_provider").child(userID);
//     StorageUploadTask uploadTask = storageReference.putFile(image);
//     StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
//     String url = (await downloadUrl.ref.getDownloadURL());
//     print("URL is $url");
//     Globals.image1=url.toString();
//     // platecontrol=plateController.text;
//     pr.hide();
//     // Navigator.of(context)
//     //     .push(MaterialPageRoute(
//     //     builder: (_) => CarPicture()));
//   }
// }



}