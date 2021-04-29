import 'dart:convert';



import 'package:http/http.dart';
import 'package:provider/Screen/SplashScreen/SplashScreen.dart';


class postRequest{

  var list = SplashScreen.toke;
  var length = SplashScreen.toke.length;
  var i = 0;


  //static String bodyt = "dfg";
  //postRequest();

  makePostRequest(String tit , String body , String to)  async{
    // set up POST request arguments
    i++;
    String url = 'https://fcm.googleapis.com/fcm/send';
    Map<String, String> headers = {"Content-type": "application/json" , "Authorization": "key=AAAA8ChHRlU:APA91bF15ZwQnqFc9dPiXQjv36CmM8ibvST7mgOjbGatJ8kZ_EX0OlznnfWz4ZSATb7Amm1cQvipilE4glaGDibIhMtg0NiKoiSOhmBAQYyszDuWAF3a9uc9_OlMfOeZIDhH0FBiEobg"};


    var json = jsonEncode({
      "notification": {"body": body , "title": tit ,  "sound": "default", "color": "#990000",},
      "priority": "high",
      "data": {"clickaction": "FLUTTERNOTIFICATIONCLICK", "id": "1", "status": "done"},
      "to": to,
    });
    //bodyt = "";
    //make POST request

    Response response = await post(url, headers: headers, body: json).whenComplete((){

      if(i<SplashScreen.toke.length){
        makePostRequest("post" , "Someone Posted a job" , SplashScreen.toke[i]);
      }

    });
    int statusCode = response.statusCode;
    // this API passes back the id of the new item added to the body
    var bodyt = response.body;
    print(bodyt.toString());
    //setState(() => _message = body);
    // {
    //   "title": "Hello",
    //   "body": "body text",
    //   "userId": 1,
    //   "id": 101
    // }
  }


}