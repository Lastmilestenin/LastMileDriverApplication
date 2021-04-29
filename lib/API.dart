



import 'dart:io';

import 'package:dio/dio.dart';


class API{
  static var success = "false";


  static driverstatuschange(var rider,var orderid, var status, var vendorid){
    success = "false";
    Dio dio = new Dio();
    //dio.options.headers['Content-Type'] = 'application/json';
    //dio.options.headers["authorization"] = "token ${token}";
    FormData formData = new FormData.fromMap({
      'riderId':rider,
      'orderId':int.parse(orderid.toString()),
      'status':status,
      'vendorId':int.parse(vendorid.toString()),

    });
    dio.post("http://thelastmile.shop/public/api/orderStatus", data: formData,options: Options(
      contentType: "application/json",
    ),
    ).then((response){
      Map<String, dynamic> data = response.data;
      var status = data['success'];

      if(response.statusCode == 200){
        if(status != null){
          success = "true";
          print('done');
        }
        else{
          success = "error";
          print('error');
        }
      }
      else{
        success = "error";
        throw Exception('Failed to Fetch Vendors');
      }
    }).catchError(_handleDioErrorsignup);
  }

  static _handleDioErrorsignup(dynamic error){
    success = "error";
    throw Exception('Failed to Fetch Vendors Products');
  }

}