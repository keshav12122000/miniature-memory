// @dart=2.9
import 'dart:async';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tara_app/common/constants/assets.dart';
import 'package:tara_app/common/constants/colors.dart';
import 'package:tara_app/common/constants/strings.dart';
import 'package:tara_app/common/constants/styles.dart';
import 'package:tara_app/screens/base/base_state.dart';
import 'package:tara_app/screens/map_places_widget.dart';


class MapScreen extends StatefulWidget {

  final String address;

  final Function(String) addressCallback;
  MapScreen({Key key, this.address,this.addressCallback}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();

}

class _MapScreenState extends BaseState<MapScreen> {

  Completer<GoogleMapController> _controller = Completer();

  LatLng _center = const LatLng(45.521563, -122.677433);

  var placeName = "";
  var locationName = "";

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    placeName = "Pamulang Square";
    locationName = widget.address;

  }

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        body: Container(
          height: size.height,
          width: size.width,
          child: Stack(
            children: <Widget>[
              GoogleMap(
                padding: EdgeInsets.zero,
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                tiltGesturesEnabled: false,
                mapToolbarEnabled: false,
                onCameraMove: _onCameraMove,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 12.0,
                ),),
              Container(
                margin: EdgeInsets.only(right: 8,top: 35,left: 8),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 8,left: 8),
                      child: InkWell(child:getTabImageWithSize(Assets.ic_back_arrow,25,25),onTap: (){
                        Navigator.pop(context, false);
                      },),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          push(MapPlacesWidget(addressCallback: (place,location){
                            setState(() {
                              locationName = location;
                              placeName = place;
                            });
                          }));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child:Container(
                            margin: EdgeInsets.only(right: 8,left: 4),
                            height: 40,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.search,size: 24,), //Navigator.pop(context, false),
                                ),
                                Container(
                                  child: Text(getTranslation(Strings.select_location),
                                    style: BaseStyles.alreadyHaveAccountTextStyle,),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                width: double.infinity,
              ),
          Align(
            alignment: Alignment.bottomCenter,
            child:Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                  child: Wrap(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 4,bottom: 8),
                          alignment: Alignment.center,
                          child: Opacity(
                            opacity: 0.3,
                            child: Container(
                              width: 48,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.card_bg_color,
                                borderRadius: BorderRadius.all(Radius.circular(2)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(top: 8,left: 16,right: 16),
                          child: Text(
                            getTranslation(Strings.select_location_title),
                            style:BaseStyles.bottomSheetTitleStyle,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8,bottom: 16,left: 16,right: 16),
                          child:Row(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Image.asset(
                                  Assets.ic_location,
                                  fit: BoxFit.none,
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 16,right: 8,top: 6),
                                        child: Text(
                                          placeName,
                                          style:BaseStyles.backAccountHeaderTextStyle,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 16,right: 8,top: 6),
                                        child: Text(
                                          locationName ?? "",
                                          style: BaseStyles.bottomSheetLocationStyle,
                                          maxLines: 3,
                                        ),
                                      ),
                                    ],
                                  )
                              )
                            ],
                          ),
                        ),
                        selectLocationWidget(),
                      ])
              ),
          )
            ],
          ),
        ),
      ),
    );
  }

  selectLocationWidget()
  {
    return InkWell(
      onTap: (){

      },
      child: Container(
        height: 48,
        margin: EdgeInsets.only(bottom: 16,left: 16,right: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
                Radius.circular(8)
            ),
            color: AppColors.bottom_border_color
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(Strings.select_location_title),
          textAlign: TextAlign.center,
          style: BaseStyles.addNewBankAccount,
        ),
      ),
    );
  }

//  Future<LatLng> getUserLocation() async {
//    var currentLocation = <String, double>{};
//    final location = LocationManager.Location();
//    try {
//      currentLocation = await location.getLocation();
//      final lat = currentLocation["latitude"];
//      final lng = currentLocation["longitude"];
//      final center = LatLng(lat, lng);
//      return center;
//    } on Exception {
//      currentLocation = null;
//      return null;
//    }
//  }

  @override
  BuildContext getContext() {
    return context;
  }

  @override
  init() {

  }
}