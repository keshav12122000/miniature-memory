// @dart=2.9
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:tara_app/common/helpers/mixpanel_helper.dart';
import 'package:tara_app/common/helpers/get_helper.dart';
import 'package:tara_app/common/widgets/error_state_info_widget.dart';
import 'package:tara_app/common/widgets/snackbars.dart';
import 'package:tara_app/models/auth/address.dart';
import 'package:tara_app/models/core/base_response.dart';
import 'package:tara_app/repositories/auth_repository.dart';
import 'package:tara_app/screens/consumer/transfer/bills_payment_soucres_screen.dart';
import 'package:tara_app/services/error/failure.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tara_app/common/constants/strings.dart';
import 'package:tara_app/services/config/api.dart';
import '../injector.dart';
import '../routes.dart';
import 'package:flutter/services.dart';

class AddressController extends GetxController {
  var address = Address().obs;

  var showProgress = false.obs;

  var savedAddresses = [].cast<AddressWithType>().obs;

  var defaultAddress = AddressWithType().obs;

  var selectedLatLang = Position().obs;

  var selectedAddress = AddressWithType().obs;

  var fetched = false.obs;

  var placemark = Placemark().obs;

  addAddress(Address a, AddressType addressType) async {
    //validate empty state here for the text fields
    showProgress.value = true;
    AddressWithType request = AddressWithType(
        address: a, addressType: addressType.toString().split('.').last);
    // print(jsonEncode(request.toJson()));
    Either<Failure, BaseResponse> response =
        await getIt.get<AuthRepository>().addAddress(request);
    showProgress.value = false;
    print("address ${response.toString()}");
    response.fold((l) {
      print("error adding address");
            MixPanelHelper.trackEvent(MixpanelEvents.address_not_added_successfully,eventProperties: {
        "message":"Unable to add the address",
         "Address Line":address.value.addressLineOne,
          "Server":server
      });
      // Get.showSnackbar(Snackbars.errorSnackbar(l.message));
    }, (r) {
      MixPanelHelper.trackEvent(MixpanelEvents.address_added_successfully,eventProperties:{
        "Address Line One":a.addressLineOne,
        "Phone NUmber":a.phoneNumber,
        "PinCode":a.pinCode,
         "City":a.city,
          "State":a.state,
           "Server":server
      });
      getAddress();
      Get.back(result: request);
      Get.back(result: request);
      Get.showSnackbar(Snackbars.productAdditionSnackbar("Address added"));
    });
  }

  getDefaultAddress() {
    try {
      var a = savedAddresses.singleWhere((e) => e.defaultAddress);
      if (a.id != defaultAddress?.value?.id) defaultAddress.value = a;
    } catch (e) {
      print(e);
      print("either no defualt address or no address saved at all");
      return null;
    }
  }

  updateAddress(id, Address a, AddressType addressType) async {
    //validate empty state here for the text fields
    showProgress.value = true;

    AddressWithType request = AddressWithType(
        id: id,
        address: a,
        addressType: addressType.toString().split('.').last);
    Either<Failure, BaseResponse> response =
        await getIt.get<AuthRepository>().updateAddress(request);
    showProgress.value = false;
    response.fold((l) {
      // Get.showSnackbar(Snackbars.errorSnackbar(l.message));
    }, (r) {
      getAddress();
      Get.back(result: request);
      Get.showSnackbar(Snackbars.productAdditionSnackbar("Address updated"));
    });
  }

  setAsDefault(AddressWithType addressWithType) async {
    showProgress.value = true;
    Either<Failure, BaseResponse> response = await getIt
        .get<AuthRepository>()
        .updateAddress(addressWithType..defaultAddress = true);
    showProgress.value = false;
    response.fold((l) {
      // Get.showSnackbar(Snackbars.errorSnackbar(l.message));
    }, (r) {
      Get.showSnackbar(
          Snackbars.productAdditionSnackbar("Default address set"));
    });
  }

  deleteAddress(AddressWithType addressWithType) async {
    showProgress.value = true;
    Either<Failure, BaseResponse> response =
        await getIt.get<AuthRepository>().deleteAddress(addressWithType);
    showProgress.value = false;
    response.fold((l) {
      // Get.showSnackbar(Snackbars.errorSnackbar(l.message));
    }, (r) {
      getAddress();
    });
  }

  getAddress() async {
    showProgress.value = true;
    Either<Failure, List<AddressWithType>> response =
        await getIt.get<AuthRepository>().getAddress();
    showProgress.value = false;
    response.fold((l) {
      print(l.message);
      print("error fetching addresses");
      fetched.value = true;
    }, (r) {
      savedAddresses.value = r;
      fetched.value = true;
      // getDefaultAddress();
      setDefaultAddress();
    });
  }

  setDefaultAddress() {
    try {
      if (selectedAddress.value.id != savedAddresses.last.id &&
          selectedAddress?.value?.id == null)
        selectedAddress.value = savedAddresses.last;
    } catch (e) {
      selectedAddress.value = null;
    }
  }

  addAddressForSignup(
      Address address, String pincode, AddressType addressType) async {
    showProgress.value = true;
    AddressWithType request = AddressWithType(
        address: address,
        addressType: addressType.toString().split('.').last,
        defaultAddress: true);
    Either<Failure, BaseResponse> response =
        await getIt.get<AuthRepository>().addAddress(request);
    print("address ${response.toString()}");
    response.fold((l) {
      showProgress.value = false;
      print("error adding address");
      // Get.showSnackbar(Snackbars.errorSnackbar(l.message));
    }, (r) {
      // savedAddresses.insert(0, request);
      // Get.back(result: request);
      // Get.showSnackbar(Snackbars.productAdditionSnackbar("Address added"));
      showProgress.value = false;
      // Get.to(CreateAccountSuccess());
      Get.offNamed(Routes.CREATE_ACCOUNT_SUCCESS);
      getAddress();
    });
  }

  Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        getIt.get<GetHelper>().getDialog(
                content: ErrorStateInfoWidget(
              desc:
                  "Location permission is required to work smoothly with this application. Enable it now?",
              onTap: () {
                //getCurrentLocation();
                Get.showSnackbar(Snackbars.errorSnackbar("Location permissions are denied"));
                return null;
              },
            ));
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      getIt.get<GetHelper>().getDialog(
              content: ErrorStateInfoWidget(
            desc:
                "Location permissions are permanently denied, please enable it from device settings",
            onTap: () {
/*
              Get.back();
              Geolocator.openAppSettings();
*/
              Get.showSnackbar(Snackbars.errorSnackbar("Location permissions are permanently denied, please enable it from device settings"));
              return null;
            },
          ));
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.



    showProgress.value=true;
    //_onLoading(loadingMessage);
    Position position,temp;
   // for(int i=0;i<10;i++){
      //showProgress.value=true;
      // loadingMessage="Getting device location....";
//      await Future.delayed(Duration(milliseconds: 1000),() async{
//        Text(loadingMessage);
        var locAccuracy= Platform.isAndroid?LocationAccuracy.high:LocationAccuracy.medium;
        try {
          temp = await Geolocator.getCurrentPosition(
              desiredAccuracy: locAccuracy, timeLimit: Duration(seconds: 10));
          print(temp.toString());
/*
            temp = await Future.delayed(Duration(milliseconds: 1000),() async {
              var pos=Geolocator.getCurrentPosition(
                  desiredAccuracy: locAccuracy,
                  timeLimit: Duration(seconds: 10));
              print(pos.toString());
              return pos;
            });

          temp = await Future.delayed(Duration(milliseconds: 1000),() async {
            var pos=Geolocator.getCurrentPosition(
                desiredAccuracy: locAccuracy,
                timeLimit: Duration(seconds: 10));
            print(pos.toString());
            return pos;
          });
*/

          }
        catch(ex){
          showProgress.value=false;
          Get.showSnackbar(Snackbars.errorSnackbar("Unable to get accurate GPS location. Please move to location where we can get accurate location"));
          return null;
        }

//      });
  //    if(i==0){
   //     position=temp;
     //   continue;
     // }
     // if(position.accuracy>temp.accuracy){
      //  position=temp;
     // }
      print("Log Something ${temp.accuracy}");
   // }
    print("Final Accuracy ${temp.accuracy}");
/*
    if(temp.accuracy>50){
      showProgress.value=false;
      Get.showSnackbar(Snackbars.errorSnackbar("Unable to get accurate GPS location. Please move to location where we can get accurate location"));
      return null;
    }
*/
    Get.showSnackbar(Snackbars.successSnackbarDark("Getting device location : Accurate upto ${temp.accuracy}"));

    showProgress.value=false;
    return LatLng(temp.latitude, temp.longitude);
  }

  Future<Placemark> getPlaceFromLatLang(LatLng latLng) async {
    return (await placemarkFromCoordinates(latLng.latitude, latLng.longitude))
        .first;
  }

  void getLocationFromCoordinates(LatLng coordinates) async {
    // showProgress.value = true;
    List<Placemark> _placemark = await placemarkFromCoordinates(
        coordinates.latitude, coordinates.longitude);
    placemark.value = _placemark.first;
    // showProgress.value = false;
  }

  Future<LatLng> getLatLngFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    return LatLng(locations[0].latitude, locations[0].longitude);
  }

  String getFormattedText(Placemark placeMark) {
    String name = placeMark.name;
    String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;
    String address =
        "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

    return address;
  }
}
