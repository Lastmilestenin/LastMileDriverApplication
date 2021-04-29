import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';


class Dialogs{
  progressBars(context, pr) {
    pr = ProgressDialog(context);
    //For normal dialog
    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);

    pr.style(
        message: 'Please Wait...',
        borderRadius: 10.0,
        backgroundColor: Colors.black,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    pr.show();
    Future.delayed(Duration(seconds:12)).then((value) {
      pr.hide();
    });
  }


  progressBarsprofile(context, pr) {
    pr = ProgressDialog(context);
    //For normal dialog
    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);

    pr.style(
        message: 'Please Wait...',
        borderRadius: 10.0,
        backgroundColor: Colors.black,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    pr.show();
  }


  progressBarsprofilehide(context, pr){
    pr.hide();
  }


}