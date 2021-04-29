import 'dart:math';

import 'package:flutter/material.dart';

class DistanceP{
  int distance1(double lat1, double lon1, double lat2, double lon2)
  {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1); // deg2rad below
    var dLon = deg2rad(lon2 - lon1);
    var a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(deg2rad(lat1)) *
                cos(deg2rad(lat2)) *
                sin(dLon / 2) *
                sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    //d=( d * 1000);
    d = d * 1000;
    return d.ceil();
  }
  double deg2rad(double deg)
  {
    return deg * (pi / 180);
  }
  double rad2deg(double rad)
  {
    return (rad * 180) / pi;
  }
}