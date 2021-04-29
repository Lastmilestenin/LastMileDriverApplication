import 'package:json_annotation/json_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../data/equatable.dart';

part 'get_routes_request_model.g.dart';

@JsonSerializable(nullable: true)
class GetRoutesRequestModel extends Equatable {
  @JsonKey(ignore: true)
  LatLng fromLocation;
  @JsonKey(name: 'origin')
  String origin;

  @JsonKey(ignore: true)
  LatLng toLocation;
  @JsonKey(name: 'destination')
  String destination;

  @JsonKey(name: 'mode')
  String mode;

  GetRoutesRequestModel({this.fromLocation, this.origin, this.toLocation, this.destination, this.mode = "driving"}) : super([origin, destination, mode]){
    if(this.origin == null && fromLocation != null){
      this.origin = fromLocation.latitude.toString()+","+fromLocation.longitude.toString();
     // origin= "${fromLocation.latitude},${fromLocation.longitude}";
    }
    if(this.destination == null && toLocation != null){

       //destination = "${toLocation.latitude},${toLocation.longitude}";
      this.destination = toLocation.latitude.toString()+","+toLocation.longitude.toString();
    }
    if(this.origin != null && fromLocation == null){
      final data = this.origin.split(',');
      if(data.length == 2) fromLocation = LatLng(double.parse(data[0]), double.parse(data[1]));
    }
    if(this.destination != null && toLocation == null){
      final data = this.destination.split(',');
      if(data.length == 2) toLocation = LatLng(double.parse(data[0]), double.parse(data[1]));
    }
  }

  factory GetRoutesRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GetRoutesRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetRoutesRequestModelToJson(this);
}
