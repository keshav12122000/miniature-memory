import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tara_app/common/constants/colors.dart';
import 'package:tara_app/common/constants/gradients.dart';
import 'package:tara_app/common/constants/strings.dart';
import 'package:tara_app/common/constants/styles.dart';
import 'package:tara_app/common/widgets/circle_shape.dart';
import 'package:tara_app/common/widgets/otp_text_field_widget.dart';
import 'package:tara_app/common/widgets/sign_in_flow_bg.dart';
import 'package:tara_app/common/widgets/snackbars.dart';
import 'package:tara_app/common/widgets/text_with_bottom_overlay.dart';
import 'package:tara_app/screens/base/base_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:tara_app/controller/auth_controller.dart';
import 'package:tara_app/common/constants/values.dart';

class MobileVerificationScreen extends StatefulWidget {
  final bool isFromForgotPassword;
  final bool isFromLogin;

  MobileVerificationScreen()
      : this.isFromForgotPassword =
            Get.arguments?.isFromForgotPassword ?? false,
        this.isFromLogin = Get.arguments?.isFromLogin ?? true;

  @override
  _MobileVerificationScreenState createState() =>
      _MobileVerificationScreenState();
}

class _MobileVerificationScreenState
    extends BaseState<MobileVerificationScreen> {
  bool isOtpEntered = false;

  AuthController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        appBar: AppBar(
          title: Text(
            getTranslation(widget.isFromForgotPassword
                ? Strings.reset_password
                : widget.isFromLogin
                    ? Strings.login
                    : Strings.CREATE_AN_ACCOUNT),
            style: TextStyles.headline6222,
          ),
          leading: Container(
            height: 24,
            width: 24,
            child: SvgPicture.asset(
              Assets.assets_icon_b_back_arrow,
              fit: BoxFit.scaleDown,
            ),
          ).onTap(onPressed: () => Get.back()),
          backgroundColor: AppColors.scaffold_color,
          elevation: 0,
        ),
        backgroundColor: AppColors.scaffold_color,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              getTranslation(Strings.mobile_verification),
              style: TextStyles.headline52,
            ),
            SizedBox(
              height: 8,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  style: BaseStyles.mobileSubTextStyle,
                  text: getTranslation(Strings.mobile_verification_subtext) +
                      " "),
              TextSpan(
                  style: BaseStyles.mobileNoTextStyle,
                  text: controller.mobileNumber.value
                      .replaceRange(3, 11, "********"))
            ])),
            SizedBox(
              height: 24,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
                color: Colors.white,
                boxShadow: Shadows.shadows_list_2,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Wrap(
                        children: <Widget>[
                          Column(
                            children: [
                              Container(
                                height: 40,
                                child: OTPTextFieldWidget(
                                  width: MediaQuery.of(context).size.width,
                                  length: 6,
                                  fieldWidth: 40,
                                  textFieldAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  fieldStyle: FieldStyle.underline,
                                  obscureText: false,
                                  style: BaseStyles.otpunderlineTextStyle,
                                  onCompleted: (pin) {
                                    print("Completed: " + pin);
                                    setState(() {
                                      controller.otp.value = pin;
                                      isOtpEntered = true;
                                    });
                                  },
                                  onChanged: (pin) {
                                    print("Completed: " + pin);
                                    setState(() {
                                      if (pin.trim().length < 6) {
                                        controller.errorMessage.value = "";
                                        isOtpEntered = false;
                                      }
                                    });
                                  },
                                ),
                              ),
                              Container(
                                height: 10,
                                margin: EdgeInsets.only(
                                  bottom: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    getBorderContainer(),
                                    getBorderContainer(),
                                    getBorderContainer(),
                                    getBorderContainer(),
                                    getBorderContainer(),
                                    getBorderContainer(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // controller.errorMessage.value.isEmpty
                          //   ? Container()
                          //   : Center(
                          //       child: Text(
                          //         getTranslation(controller.errorMessage.value) ?? controller.errorMessage.value,
                          //         style: BaseStyles.error_text_style,
                          //       ),
                          //     ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 6.5.toInt(),
                                  child: Container(
                                      margin: EdgeInsets.only(top: 8),
                                      child: RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            style: BaseStyles.sentOtpTextStyle,
                                            text: getTranslation(
                                                Strings.sent_otp_text)),
                                        TextSpan(
                                            style:
                                                BaseStyles.sentOtpTimeTextStyle,
                                            text: controller
                                                .countDownTimeString.value)
                                      ]))),
                                ),
                                Expanded(
                                  flex: 3.5.toInt(),
                                  child: Container(
                                      padding: EdgeInsets.only(
                                        top: 8,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                              getTranslation(
                                                  Strings.resend_otp),
                                              style: (controller
                                                              .countDownTimeString
                                                              .value ==
                                                          "00:00" &&
                                                      controller
                                                              .seconds.value ==
                                                          0)
                                                  ? BaseStyles
                                                      .bottomSheetLocationChangeTextStyle
                                                  : BaseStyles
                                                      .requestNowTextStyle,
                                              textAlign: TextAlign.center),
                                          Container(
                                            height: 2,
                                            margin: EdgeInsets.only(
                                                top: 4, left: 8, right: 8),
                                            decoration: BoxDecoration(
                                              gradient:
                                                  Gradients.primaryGradient,
                                            ),
                                          ),
                                        ],
                                      )).onTap(onPressed: () async {
                                    if (controller
                                            .mobileNumber.value.isNotEmpty &&
                                        controller.countDownTimeString.value ==
                                            "00:00") {
                                      controller.seconds.value = 120;
                                      controller.startTimer();
                                      bool status =
                                          await controller.resetPassword();
                                      if (status)
                                        Get.showSnackbar(
                                            Snackbars.successSnackbarDark(
                                                "OTP sent successfully"));
                                      else
                                        Get.showSnackbar(
                                            Snackbars.errorSnackbar(
                                                "error sending OTP again"));
                                    }
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // controller.errorMessage.value.isEmpty
                    //   ? Container()
                    //   : Container(
                    //       margin: EdgeInsets.all(8),
                    //       child: Text(
                    //         controller.errorMessage.value,
                    //         style: BaseStyles.error_text_style,
                    //       ),
                    //     ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            getVerifyWidget()
          ]
                  //  + (MediaQuery.of(context).viewInsets.bottom == 0
                  //   ? [
                  //       Expanded(
                  //         child: Container(),
                  //       ),
                  //       getVerifyWidget(),
                  //   ]
                  // : []),
                  ),
        )).withProgressIndicator(showIndicator: controller.showProgress.value));
  }

  Widget getBorderContainer() {
    return Container(
      height: 3,
      width: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              //                   <--- left side
              color: isOtpEntered
                  ? AppColors.button_background_color
                  : AppColors.light_grey_blue,
              width: 2.0,
              style: BorderStyle.solid),
        ),
        color: Colors.transparent,
      ),
    );
  }

  Widget getVerifyWidget() {
    return Container(
      height: 48,
      margin: EdgeInsets.only(
          // bottom: 16,
          // top: 36,
          ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: isOtpEntered
              ? AppColors.button_background_color
              : AppColors.grey2),
      alignment: Alignment.center,
      child: Text(
        getTranslation(Strings.verify),
        textAlign: TextAlign.center,
        style: isOtpEntered
            ? BaseStyles.chatItemHeaderTextStyle
            : BaseStyles.verifyTextStyle,
      ),
    ).onTap(onPressed: () {
      if (isOtpEntered) {
        controller.validateOtp(
            isFromForgotPassword: widget.isFromForgotPassword,
            isFromLogin: widget.isFromLogin);
      }
    });
  }

  @override
  BuildContext getContext() {
    // TODO: implement getContext
    return context;
  }

  @override
  void initState() {
    controller.showProgress.value = false;
    controller.seconds.value = 120;
    controller.startTimer();
    super.initState();
  }
}
