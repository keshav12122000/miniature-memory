// @dart=2.9
/*
*  auth_controller.dart
*
*  Created by Yakub Pasha.
*  Copyright © 2020 Tara.id. All rights reserved.
*/

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:tara_app/arguments.dart';
import 'package:tara_app/common/constants/strings.dart';
import 'package:tara_app/common/helpers/fcm_helper.dart';
import 'package:tara_app/services/config/api.dart';
import 'package:tara_app/common/helpers/get_helper.dart';
import 'package:tara_app/common/helpers/helpers.dart';
import 'package:tara_app/common/helpers/mixpanel_helper.dart';
import 'package:tara_app/common/widgets/error_state_info_widget.dart';
import 'package:tara_app/common/widgets/snackbars.dart';
import 'package:tara_app/controller/device_register_controller.dart';
import 'package:tara_app/controller/wallet_controller.dart';
import 'package:tara_app/data/session_local_data_source.dart';
import 'package:tara_app/data/user_local_data_source.dart';
import 'package:tara_app/flavors.dart';
import 'package:tara_app/models/auth/auth_put_request.dart';
import 'package:tara_app/models/auth/auth_request.dart';
import 'package:tara_app/models/auth/auth_response.dart';
import 'package:tara_app/models/auth/customer_profile.dart';
import 'package:tara_app/models/auth/get_otp_request.dart';
import 'package:tara_app/models/auth/registration_status.dart';
import 'package:tara_app/models/auth/to_address_response.dart';
import 'package:tara_app/models/core/base_response.dart';
import 'package:tara_app/models/document/document.dart';
import 'package:tara_app/repositories/auth_repository.dart';
import 'package:tara_app/repositories/document_repository.dart';
import 'package:tara_app/screens/merchant/create_store_screen.dart';
import 'package:tara_app/screens/authorization_error_screen.dart';
import 'package:tara_app/screens/complete_profile_details.dart';
import 'package:tara_app/screens/create_account_success_screen.dart';
import 'package:tara_app/screens/create_account_upload_image_screen.dart';
import 'package:tara_app/screens/dashboard/notification_settings_screen.dart';
import 'package:tara_app/screens/mobile_verification_screen.dart';
import 'package:tara_app/screens/password_reset_success.dart';
import 'package:tara_app/screens/reset_password_screen.dart';
import 'package:tara_app/services/config/firebase_path.dart';
import 'package:tara_app/services/error/failure.dart';
import 'package:tara_app/services/firebase/firebase_remote_service.dart';
import 'package:tara_app/utils/locale/utils.dart';

import '../injector.dart';
import '../models/auth/auth_request.dart';
import '../models/auth/auth_request.dart';
import '../models/auth/auth_request.dart';
import '../models/auth/auth_request.dart';
import '../models/auth/customer_profile.dart';
import '../models/auth/security_token.dart';
import '../routes.dart';
import '../utils/locale/utils.dart';
import '../utils/locale/utils.dart';
import 'package:device_info/device_info.dart';

class AuthController extends GetxController {
  ///listen for the progress bar changes
  var showProgress = false.obs;
  var mobileNumber = "".obs;
  var otp = "".obs;
  var confirmPwd = "".obs;
  var fullName = "".obs;
  var email = "".obs;
  var password = "".obs;
  var isEnterAllTheFields = false.obs;
  var errorMessage = "".obs;
  var countDownTimeString = "02:00".obs;
  var user = AuthResponse().obs;
  var displayImage = File("").obs;
  var displayStoreImage = File("").obs;
  var address = "".obs;
  var postcode = "".obs;
  var city = "Adoni".obs;
  var state = "Ache".obs;
  var country = "Afghanistan".obs;
  var referCode = "".obs;

  final List<String> citiesList = [
    "Adoni",
    "Amaravati",
    "Anantapur",
    "Chandragiri",
    "Chittoor",
    "Dowlaiswaram"
  ];
  final List<String> countries = [
    "Afghanistan",
    "Albania",
    "Algeria",
    "Andorra",
    "Angola"
  ];
  final List<String> states = [
    "Ache",
    "Bali",
    "Benten",
  ];

  final int totalPagesIndex = 3;

  Timer timer;
  var seconds = 120.obs;

  TextEditingController mobileNumberTextEditController = TextEditingController();
  TextEditingController passwordTextEditController = TextEditingController();
  TextEditingController otpTextEditController = TextEditingController();
  TextEditingController nameTextEditController = TextEditingController();
  TextEditingController emailTextEditController = TextEditingController();
  TextEditingController confirmPasswordTextEditController =
      TextEditingController();
  TextEditingController addressEditController = TextEditingController();
  TextEditingController postcodeEditController = TextEditingController();
  TextEditingController cityEditController = TextEditingController();
  TextEditingController stateEditController = TextEditingController();
  TextEditingController countryEditController = TextEditingController();

  ///on clicking on send otp
  void getOtp({
    bool isFromResendOtp = false,
    String contextyForOtp = "Register"
  }) async {
    //validate empty state here for the text fields
    if (isValidationSuccessInSignUp()) {
      showProgress.value = true;
      GetOtpRequest request = GetOtpRequest(
          mobileNumber: mobileNumber.value,
          customerType: Utils().getCustomerType(),
          otpContext: contextyForOtp);
      // print(jsonEncode(request.toJson()));
      Either<Failure, BaseResponse> response = await getIt
          .get<AuthRepository>()
          .getOtp(GetOtpRequestWithData(data: request));
      showProgress.value = false;
      response.fold(
        // (l) => GetHelper().getDialog(
        //     content: ErrorStateInfoWidget(
        //       desc: l.message,
        //     )),
        // (l) => errorMessage.value = l.message,
        (l) => null,
        (r) => !isFromResendOtp
            ? Get.toNamed(Routes.MOBILE_VERIFICATION,
                arguments: CustomArguments(isFromForgotPassword: false, isFromLogin: contextyForOtp == "Register" ? false : true))
            : print(r.message),
      );
    } else {
      //handle empty state error here
    }
  }

  ///on tapping the verify
  void validateOtp({bool isFromForgotPassword = false, bool isFromLogin = false}) async {
    //validate empty state here for the text fields
    if (isValidationSuccessInOtp()) {
      showProgress.value = true;
      String deviceIdentifier = await getDeviceIdentifier();
      AuthRequest request = AuthRequest(mobileNumber: mobileNumber.value, otp: otp.value, otpContext: isFromLogin ? "Login" : "Register", customerType: Utils().getCustomerType(), deviceIdentifier: deviceIdentifier, deviceToken: deviceToken ?? "");      Either<Failure, AuthResponse> response = await getIt
          .get<AuthRepository>()
          .validateOtp(AuthRequestWithData(data: request));
      // showProgress.value = false;
      response.fold(
          // (l) => GetHelper().getDialog(
          //     content: ErrorStateInfoWidget(
          //       desc: l.message,
          //     )),
          // (l) => errorMessage.value = l.message,
          (l) { showProgress.value = false;
          MixPanelHelper.trackEvent(MixpanelEvents.unable_to_validate_otp,eventProperties:{
            "message":"Unable to validate the otp",
            "Server":server
          });
          },
          (r) => isFromForgotPassword
              ? Get.dialog(
                  Dialog(
                    child: PasswordResetSuccess(),
                    insetPadding:
                        EdgeInsets.symmetric(horizontal: Get.width * .06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  barrierDismissible: true)
              : isFromLogin
                ? {
                  FirebaseAuth.instance.signInWithCustomToken(r.firebaseCustomToken).then((value) async {
                  registerToIntercom(r.customerProfile);
                  MixPanelHelper.createProfileOnMixpanel();
                  if (await getIt.get<SessionLocalDataStore>().getDeviceRegInfo() != null) {
                    showProgress.value = false;

                    Get.offAllNamed(Utils().getLandingScreen());
                  } else {
                    // await DeviceRegisterController().registerDevice();
                    showProgress.value = false;
                    MixPanelHelper.trackEvent(MixpanelEvents.login_successfull,eventProperties:{
                      "Name":fullName.value,
                      "Email":email.value,
                      "City":city.value,
                      "State":state.value,
                      "Mobile Number":mobileNumber.value,
                      "Server":server
                    });
                    Get.offAllNamed(Utils().getLandingScreen());
                  }
                }).catchError((e, stack) {
                  print(stack);
                  getIt.get<UserLocalDataStore>().clear();
                  showProgress.value = false;
                  Get.showSnackbar(Snackbars.errorSnackbar("Unable to login into firebase"));

                  MixPanelHelper.trackEvent(MixpanelEvents.unable_to_login_to_firebase,eventProperties:{
                     "message":"Unable to login into firebase",
                    "Server":server
                  });
                }),
                }
                : {
                  showProgress.value = false,
                  // Get.to(CompleteProfileScreen())
                  if (F.appFlavor == Flavor.MERCHANT)
                    {
                      MixPanelHelper.trackEvent(MixpanelEvents.otp_verified_registration_merchant,eventProperties:{
                        "Mobile Number":mobileNumber.value,
                        "Server":server
                      }),
                      Get.toNamed(Routes.MERCHANT_PROFILE)
                    }
                    // Get.offAllNamed(Routes.ONBOARDING_CAROUSEL)
                  else
                    {
                      MixPanelHelper.trackEvent(MixpanelEvents.otp_verified_registration_consumer,eventProperties:{
                        "Mobile Number":mobileNumber.value,
                        "Server":server
                      }),
                      Get.toNamed(Routes.COMPLETE_PROFILE)
                    }
                });
      // : UploadImage()));
    }
  }

  Future<AuthResponse> createTempAccount(
      RegistrationStatus status, String mobileNumber,
      [String customerName]) async {
    CustomerProfile customerProfile = CustomerProfile(
        customerType: "Consumer",
        registrationStatus: status,
        firstName:
            customerName); // Default to Consumer as customerType because in the merchant its  going as merchant
    SignUpRequest request = SignUpRequest(
      customerProfile: customerProfile,
      mobileNumber: mobileNumber,
    );
    print(request.toJson());
    Either<Failure, AuthResponse> response =
        await getIt.get<AuthRepository>().signUp(request, isBeneficiary: true);
    if (response.isRight()) {
      var signUpResponse = response.getOrElse(() => null);
      print(jsonEncode(signUpResponse.toJson()));
      return signUpResponse;
    } else {
      print("error while creating the user");
    }
    return Future.value(null);
  }

  static Future<String> getDeviceIdentifier() async {
    String deviceName;
    String deviceVersion;
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        deviceVersion = build.version.toString();
        identifier = build.androidId; //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor; //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }

//if (!mounted) return;
    print(identifier);
    return identifier;
  }

  void loginWithOtp() async {
    if (isValidationSuccessInSignIn()) {
      showProgress.value = true;
      String deviceIdentifier = await getDeviceIdentifier();
      var customerProfile = CustomerProfile(
        customerType: Utils().getCustomerType(),
        deviceToken: deviceToken,
        deviceIdentifier: deviceIdentifier
      );
      AuthRequest request = AuthRequest(
        mobileNumber: mobileNumber.value,
        password: null,
        customerProfile: customerProfile
      );
    }
  }

  void login() async {
    //validate empty state here for the text fields
    if (isValidationSuccessInSignIn()) {
      showProgress.value = true;
      String deviceIdentifier = await getDeviceIdentifier();
      print(deviceIdentifier);
      print(deviceToken);
      var customerProfile = CustomerProfile(
          customerType: Utils().getCustomerType(),
          deviceToken: deviceToken,
          deviceIdentifier: deviceIdentifier);
      print(customerProfile.toJson().toString());
      AuthRequest request = AuthRequest(
          mobileNumber: mobileNumber.value,
          password: null,
          customerProfile: customerProfile);
      print(jsonEncode(request.toJson()));
      Either<Failure, AuthResponse> response = await getIt.get<AuthRepository>().login(request);
      response.fold((l) {
        showProgress.value = false;
        confirmPwd.value = "";
        passwordTextEditController.clear();
      },
          (r) async => {
            FirebaseAuth.instance.signInWithCustomToken(r.firebaseCustomToken).then((value) async {
              registerToIntercom(r.customerProfile);
              MixPanelHelper.createProfileOnMixpanel();
              if (await getIt.get<SessionLocalDataStore>().getDeviceRegInfo() != null) {
                showProgress.value = false;
                Get.offAllNamed(Utils().getLandingScreen());
              } else {
                // await DeviceRegisterController().registerDevice();
                Get.offAllNamed(Utils().getLandingScreen());
              }
            }).catchError((e, stack) {
              print(stack);
              getIt.get<UserLocalDataStore>().clear();
              showProgress.value = false;
              Get.showSnackbar(Snackbars.errorSnackbar("Unable to login into firebase"));
            }),
          });
      // Get.to(Consumer())); //navigate to consumer home screen
    }
  }

  registerToIntercom(CustomerProfile user) {
    Intercom.registerIdentifiedUser(
      userId: user.firebaseId,
    ).then((value) {
      Intercom.updateUser(name: user.firstName);
      Intercom.updateUser(email: user.email);
      Intercom.updateUser(phone: user.mobileNumber);
      Intercom.updateUser(
          customAttributes: {"firebaseId": "${user.firebaseId}"});
    });
  }

  Future<bool> resetPassword() async {
    bool result = false;
    if (isValidatedPassword()) {
      showProgress.value = true;
      AuthPutRequest request = AuthPutRequest(
          mobileNumber.value,
          passwordTextEditController.text.trim(),
          true,
          CustomerProfile(customerType: Utils().getCustomerType()),
          "Forgot_Password");
      Either<Failure, SecurityToken> response =
          await getIt.get<AuthRepository>().resetPassword(request);
      showProgress.value = false;
      response.fold(
        (l) {
          result = false;
          // GetHelper().getDialog(
          //   content: ErrorStateInfoWidget(
          //     desc: l.message,
          //   ),
          // );
        },
        (r) async => {
          result = true,
          Get.toNamed(Routes.MOBILE_VERIFICATION,
              arguments: CustomArguments(isFromForgotPassword: true)),
        },
      );
      // Get.to(Consumer())); //navigate to consumer home screen
    }
    return result;
  }

  void signUp() async {
    //validate empty state here for the text fields
    if (isValidationSuccessInCompleteProfile()) {
      showProgress.value = true;
      String deviceIdentifier = await getDeviceIdentifier();
      CustomerProfile customerProfile = CustomerProfile(
          firstName: fullName.value,
          //TODO:Ashish hardcoded it as email is required during registration for ShopeePay integration to work
          //will need to change the registration screen to ensure email is a mandatory parameter
          // will also consumer to go to profile and update email address there
          email: "hardcoded@toberemoved.com",
          customerType: Utils().getCustomerType(),
          deviceToken: deviceToken,
          deviceIdentifier: deviceIdentifier);
      SignUpRequest request = SignUpRequest(
        customerProfile: customerProfile,
        mobileNumber: mobileNumber.value,
      );
      print(request.toJson());
      Either<Failure, AuthResponse> response =
          await getIt.get<AuthRepository>().signUp(request);
      // showProgress.value = false;
      response.fold(
          // (l) => {
          //   showProgress.value = false,
          // getIt.get<GetHelper>().getDialog(
          //         content: ErrorStateInfoWidget(
          //       desc: l.message,
          //     ))},
          (l) => {showProgress.value = false},
          //Get.defaultDialog(content: Text(l.message)),
          (r) async {
        // do firebase login
        await FirebaseAuth.instance
            .signInWithCustomToken(r.firebaseCustomToken)
            .then((value) {
          //Register Device in the background as we have enough time to create the store in the next step
          // await DeviceRegisterController().registerDevice(isAfterRegistration: true);
          registerToIntercom(r.customerProfile);
          showProgress.value = false;
          if (referCode.value != "") {
            Get.find<WalletController>().applyCode(referCode.value);
          }
          Get.put<AuthResponse>(r);
          if (F.appFlavor == Flavor.MERCHANT ||
              F.appFlavor == Flavor.SUPPLIER) {
            Get.to(CreateStoreScreen());
          } else {
            // Get.to(CreateAccountSuccess());
            Get.to(UploadImage());
          }
        }).catchError((e, stack) {
          print(stack);
          getIt.get<UserLocalDataStore>().clear();
          showProgress.value = false;
          Get.showSnackbar(
              Snackbars.errorSnackbar("Unable to login into firebase"));
          // errorMessage.value = "Unable to login into firebase";
        });
      });
      MixPanelHelper.createProfileOnMixpanel();
      // Get.to(Consumer())); //navigate to consumer home screen
    }
  }

  void merchantSignup(File imageFile) async {
    showProgress.value = true;
    String deviceIdentifier = await getDeviceIdentifier();
    CustomerProfile customerProfile = CustomerProfile(
      firstName: nameTextEditController.text,
      email: "hardcoded@toberemoved.com",
      customerType: Utils().getCustomerType(),
      deviceToken: deviceToken,
      deviceIdentifier: deviceIdentifier
    );
    SignUpRequest request = SignUpRequest(
      customerProfile: customerProfile,
      mobileNumber: mobileNumber.value,
    );
    print(request.toJson());
    Either<Failure, AuthResponse> response = await getIt.get<AuthRepository>().signUp(request);
    response.fold(
      (l) => {showProgress.value = false},
      (r) async {
        await FirebaseAuth.instance.signInWithCustomToken(r.firebaseCustomToken).then((value) {
        registerToIntercom(r.customerProfile);
        if(imageFile != null) {
          uploadMerchantImage(imageFile, r.customerProfile);
        }
        showProgress.value = false;
        if (referCode.value != "")
          Get.find<WalletController>().applyCode(referCode.value);
        Get.put<AuthResponse>(r);
        if (F.appFlavor == Flavor.MERCHANT || F.appFlavor == Flavor.SUPPLIER)
          // Get.to(CreateStoreScreen());
          Get.toNamed(Routes.MERCHANT_STORE_LOCATION);
        else
          Get.to(UploadImage());
      }).catchError((e, stack) {
        print(stack);
        getIt.get<UserLocalDataStore>().clear();
        showProgress.value = false;
        Get.showSnackbar(Snackbars.errorSnackbar("Unable to login into firebase"));
      });
    });
    MixPanelHelper.createProfileOnMixpanel();
  }

  //updating profile info
  void updateProfile(
      String name, String address, String email, AuthResponse user,
      {File file}) async {
    showProgress.value = true;
    CustomerProfile customerProfile = CustomerProfile(
        id: user.customerProfile.id,
        lastName: user.customerProfile.lastName,
        mobileNumber: user.customerProfile.mobileNumber,
        country: user.customerProfile.country,
        dateOfBirth: user.customerProfile.dateOfBirth,
        isKyc: user.customerProfile.isKyc,
        customerType: user.customerProfile.customerType,
        firebaseId: user.customerProfile.firebaseId,
        firstName: name,
        address: [],
        email: email);
    Either<Failure, BaseResponse> response = await getIt
        .get<AuthRepository>()
        .updateProfile(customerProfile, file: file);
    showProgress.value = false;
    response.fold(
        // (l) => Get.defaultDialog(content: Text(l.message)),
        (l) => null,
        (r) => {
              Get.defaultDialog(content: Text(r.message)),
            });
  }

  bool isValidationSuccessInCompleteProfile() {
    if (GetUtils.isNullOrBlank(fullName.value)) {
      errorMessage.value = Strings.enter_full_name;
      return false;
    } else if (GetUtils.isNullOrBlank(email.value)) {
      errorMessage.value = Strings.enter_email_address;
      // return false;
    } else if (Validator().email(email.value) != null) {
      errorMessage.value = Strings.invalid_email;
      // return false;
    // } else if (GetUtils.isNullOrBlank(password.value)) {
    //   errorMessage.value = Strings.enter_password;
    //   return false;
    // } else if (GetUtils.isNullOrBlank(confirmPwd.value)) {
    //   errorMessage.value = Strings.enter_confirm_password;
    //   return false;
    // } else if (password.value != confirmPwd.value) {
    //   errorMessage.value = Strings.password_not_match;
    //   return false;
    } else {
      errorMessage.value = "";
    }
    return true;
  }

  void isEnterAllTheFieldsInCompleteProfile() {
    if (!GetUtils.isNullOrBlank(fullName.value)) {
      isEnterAllTheFields.value = true;
    } else {
      isEnterAllTheFields.value = false;
    }
  }

  void isEnterAllTheFieldsInAddress() {
    if (!GetUtils.isNullOrBlank(address.value) &&
        !GetUtils.isNullOrBlank(postcode.value) &&
        !GetUtils.isNullOrBlank(city.value) &&
        !GetUtils.isNullOrBlank(state.value) &&
        !GetUtils.isNullOrBlank(country.value)) {
      isEnterAllTheFields.value = true;
    } else {
      isEnterAllTheFields.value = false;
    }
  }

  bool isPasswordFilled() {
    if (passwordTextEditController.text.isNotEmpty &&
        confirmPasswordTextEditController.text.isNotEmpty) return true;
    return false;
  }

  bool isValidationSuccessInSignIn() {
    if (GetUtils.isNullOrBlank(mobileNumber.value)) {
      errorMessage.value = Strings.enter_phone_number;
      return false;
    } /*else if (Validator().validateMobile(mobileNumber.value) != null) {
      errorMessage.value = Strings.invalid_number;
      return false;
    } */
    // else if (GetUtils.isNullOrBlank(confirmPwd.value)) {
    //   errorMessage.value = Strings.enter_password;
    //   return false;
    // } 
    else {
      errorMessage.value = "";
    }
    return true;
  }

  isSigninFieldsFilled() {
    if (GetUtils.isNullOrBlank(mobileNumber.value))
      return false;
    // else if (GetUtils.isNullOrBlank(confirmPwd.value)) return false;
    return true;
  }

  forgotPasswordValidator() {
    if (GetUtils.isNullOrBlank(mobileNumber.value) ||
        mobileNumber.value.trim().length < 13) return false;
    return true;
  }

  bool isValidatedPassword() {
    if (GetUtils.isNullOrBlank(passwordTextEditController.text.trim()) ||
        GetUtils.isNullOrBlank(confirmPasswordTextEditController.text.trim())) {
      errorMessage.value = Strings.enter_password;
      return false;
    } else if (passwordTextEditController.text.trim() !=
        confirmPasswordTextEditController.text.trim()) {
      errorMessage.value = Strings.password_not_match;
      return false;
    } else {
      errorMessage.value = "";
    }
    return true;
  }

  bool isValidationSuccessInSignUp() {
    if (GetUtils.isNullOrBlank(mobileNumber.value) ||
        mobileNumber.value.length < 9) {
      errorMessage.value = Strings.enter_phone_number;
      return false;
    } /*else if (Validator().validateMobile(mobileNumber.value) != null) {
      errorMessage.value = Strings.invalid_number;
      return false;
    } */
    else {
      errorMessage.value = "";
    }
    return true;
  }

  bool isValidationSuccessInOtp() {
    if (GetUtils.isNullOrBlank(otp.value)) {
      errorMessage.value = Strings.enter_otp_code;
      return false;
    } else if (otp.value.length < 6) {
      errorMessage.value = Strings.invalid_otp;
      return false;
    } else {
      errorMessage.value = "";
    }
    return true;
  }

  Future<Either<Failure, ToAddressResponse>> getToAddressForPayment(
      String mobileNUmber) async {
    return await getIt.get<AuthRepository>().getToAddress(mobileNUmber);
  }

  Future<Either<Failure, CustomerProfile>> getNonTaraCustomerInfo(
      String mobileNUmber) async {
    return await getIt
        .get<AuthRepository>()
        .getNonTaraCustomerInfo(mobileNUmber);
  }

  void startTimer() {
    // Set 1 second callback
    const period = const Duration(seconds: 1);
    timer = Timer.periodic(period, (timer) {
      // Update interface
      if (seconds.value == 0) {
        // Countdown seconds 0, cancel timer
        cancelTimer();
      } else {
        seconds.value = seconds.value - 1;
        constructTime(seconds.value);
      }
    });
  }

  void cancelTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }

  String constructTime(int seconds) {
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    countDownTimeString.value = formatTime(minute) + ":" + formatTime(second);
    return countDownTimeString.value;
  }

  String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  registerDevice() {}

  bool areMandatoryFieldsFilled() {
    if (!GetUtils.isNullOrBlank(postcodeEditController.text) &&
        !GetUtils.isNullOrBlank(addressEditController.text)) {
      return true;
    } else {
      return false;
    }
  }

  uploadMerchantImage(File imageFile, CustomerProfile profile) async {
    showProgress.value = true;
    Either<Failure, DocumentWithThumbnails> docResponse = await getIt
        .get<DocumentRepository>()
        .uploadDocument(imageFile, profile.id, "STORE_IMAGE");
    docResponse.fold((l) {
      showProgress.value = false;
      // getIt.get<GetHelper>().getDialog(
      //         content: ErrorStateInfoWidget(
      //       desc: l.message,
      //     ));
    }, (r) {
      showProgress.value = false;
      user.value.customerProfile.storeImageId = r.documentDetails.first.documentId;
      var controller = Get.find<AuthController>();
      controller.displayStoreImage.value = imageFile;
      profile.storeImageId = r.documentDetails.first.documentId;
      getIt.get<AuthRepository>().updateUserPersisted(profile);
    });
  }

  uploadImage(File imageFile, int ownerId) async {
    showProgress.value = true;
    Either<Failure, DocumentWithThumbnails> docResponse = await getIt
        .get<DocumentRepository>()
        .uploadDocument(imageFile, ownerId, "PROFILE_IMAGE");
    docResponse.fold((l) {
      showProgress.value = false;
      // getIt.get<GetHelper>().getDialog(
      //         content: ErrorStateInfoWidget(
      //       desc: l.message,
      //     ));
    }, (r) {
      showProgress.value = false;
      user.value.customerProfile.profileImageId =
          r.documentDetails.first.documentId;
      var controller = Get.find<AuthController>();
      controller.displayImage.value = imageFile;
      Get.to(CreateAccountSuccess());
    });
  }

  Future<String> fetchImageUrl(int profileImageId) async {
    Either<Failure, Document> docResponse =
        await getIt.get<DocumentRepository>().getDocument(profileImageId);
    String updatedPath = "";
    docResponse.fold((l) {
      showProgress.value = false;
      return "";
    }, (r) {
      updatedPath = r.documentPath;
      showProgress.value = false;
      return updatedPath;
    });
    return "";
  }

  // write initial notifications settings to the firebase
  writeNotificationSettingsToFDB() {
    var notificationsSettingsPath;
    switch (F.appFlavor) {
      case Flavor.CONSUMER:
        notificationsSettingsPath = FirebasePath.customerNotificationsSettings(
            user.value.customerProfile.firebaseId);
        break;
      case Flavor.AGENT:
        notificationsSettingsPath = FirebasePath.agentNotificationsSettings(
            user.value.customerProfile.firebaseId);
        break;
      case Flavor.MERCHANT:
        notificationsSettingsPath = FirebasePath.merchantNotificationsSettings(
            user.value.customerProfile.firebaseId);
        break;
      case Flavor.SUPPLIER:
        notificationsSettingsPath = FirebasePath.supplierNotificationsSettings(
            user.value.customerProfile.firebaseId);
        break;
    }

    Map<String, bool> data = Map();
    arrSettingTitles.forEach((element) {
      data.putIfAbsent(element, () => true);
    });
    getIt
        .get<FirebaseRemoteService>()
        .setData(path: notificationsSettingsPath, data: data, push: false);
  }
}
