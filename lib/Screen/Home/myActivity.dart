import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/Components/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyActivity extends StatefulWidget {
  @override
  _MyActivityState createState() => _MyActivityState();
  final String userImage;
  final String userName;
  final String level;
  final String totalEarned;
  final double hoursOnline;
  final String  totalDistance;
  final int totalJob;
  final bool statusOnline;
  const MyActivity({
    Key key,
    this.userImage,
    //"https://firebasestorage.googleapis.com/v0/b/road-side-assist-1562842759870.appspot.com/o/user_default.png?alt=media&token=fc1e0ce4-9836-4793-ab68-f613d1a522d5",
    this.userName,
    this.level,
    this.totalEarned,
    this.hoursOnline,
    this.totalDistance,
    this.totalJob,
    this.statusOnline,
  }) : super(key: key);
}

class _MyActivityState extends State<MyActivity> {
  bool cupertinoState;
  String dist;

  @override
  void initState() {
    setState(() {
      if(widget.totalDistance.length < 4 && widget.totalDistance.length > 2){
        setState(() {
          dist = widget.totalDistance.substring(0,3);
        });
      }else if(widget.totalDistance.length < 3 && widget.totalDistance.length > 1)
      {
        setState(() {
          dist = widget.totalDistance.substring(0,2);
        });
      }
      else if(widget.totalDistance.length < 5 && widget.totalDistance.length > 3)
      {
        setState(() {
          dist = widget.totalDistance.substring(0,4);
        });
      }
      else if(widget.totalDistance.length < 6 && widget.totalDistance.length > 4)
      {
        setState(() {
          dist = widget.totalDistance.substring(0,5);
        });
      }
      else if(widget.totalDistance.length < 2 && widget.totalDistance.length > 0)
      {
        setState(() {
          dist = widget.totalDistance.substring(0,1);
        });
      }
      else{
        setState(() {
          dist = widget.totalDistance.substring(0,6);
        });
      }
    });
    super.initState();
    print('INSIDE MY ACT SHIT');
    print('userImage: ' + widget.userImage.toString());
    print('username: ' + widget.userName);
    print('totalEarned: ' + widget.totalEarned);
    print('hoursOnline: ' + widget.hoursOnline.toString());
    print('totalDistance: ' + widget.totalDistance);
    print('totalJob: ' + widget.totalJob.toString());
    print('boolshit: ' + widget.statusOnline.toString());

    // setState(() {
    //   cupertinoState = widget.statusOnline;
    // });
  }

  setCupertinoState() {
    setState(() {

      cupertinoState = widget.statusOnline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: whiteColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        'Change online Status: ',
                        style: headingBlack1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                // Expanded(
                //     flex: 5,
                //     child: CupertinoSwitch(
                //       value: statusOnline,
                //       onChanged: (value) {
                //         print('cupertino pressed' + value.toString());
                //         // setState((){

                //         // });
                //       },
                //     )),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      CupertinoSwitch(
                        activeColor: Color.fromRGBO(60, 111, 102, 1),
                        // value: widget.statusOnline,
                        value: cupertinoState == null
                            ? widget.statusOnline
                            : cupertinoState,
                        onChanged: (value) async {
                          print('cupertino pressed' + value.toString());
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String userID = prefs.getString('userID');

                          DocumentReference docRef = Firestore.instance
                              .collection('LM_Driver')
                              .document(userID);
                          Map<String, dynamic> data = {
                            'isShowLocation': value,
                          };
                          print('updated data: ' + data.toString());
                          docRef.updateData(data).then((document) {
                            print('location is being updated');
                          }).whenComplete(() async {
                            print('location is updated');
                          }).catchError((error) {
                            print('location not updated ...error');
                          });
                          setState(() {
                            cupertinoState = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: widget.userImage == null
                        ? Center(child: CircularProgressIndicator())
                        :
                        // 'assets/image/icon/user_default.png'
                        CachedNetworkImage(
                            imageUrl: widget.userImage,
                            fit: BoxFit.cover,
                            width: 40.0,
                            height: 40.0,
                          ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.userName ?? '',
                        style: textBoldBlack,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Text(
                      //   widget.level ?? '',
                      //   style: textGrey,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        widget.totalEarned.toString() + ' Euro' ?? '',
                        style: textBoldBlack,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Earned',
                        style: textGrey,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.0),
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Color.fromRGBO(60, 111, 102, 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                // Container(
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: <Widget>[
                //       Icon(
                //         Icons.access_time,
                //         color: greyColor,
                //       ),
                //       Text(
                //         widget.hoursOnline.toString() ?? '',
                //         style: heading18,
                //       ),
                //       Text(
                //         "Hours online",
                //         style: TextStyle(
                //           fontSize: 11,
                //           color: greyColor,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.poll,
                        color: greyColor,
                      ),
                      Text(
                        dist == null? '0' :dist,
                        style: heading18,
                      ),
                      Text(
                        "Total Distance",
                        style: TextStyle(
                          fontSize: 11,
                          color: greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.content_paste,
                        color: greyColor,
                      ),
                      Text(
                        widget.totalJob.toString() ?? '',
                        style: heading18,
                      ),
                      Text(
                        "Total Jobs",
                        style: TextStyle(
                          fontSize: 11,
                          color: greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
