// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:tara_app/common/constants/colors.dart';
import 'package:tara_app/common/constants/font_family.dart';
import 'package:tara_app/common/constants/strings.dart';
import 'package:tara_app/common/constants/styles.dart';
import 'package:tara_app/common/widgets/underline_text.dart';
import 'package:tara_app/controller/auth_controller.dart';
import 'package:tara_app/common/constants/values.dart';
import 'package:tara_app/screens/base/base_state.dart';
import 'package:tara_app/screens/signin_screen.dart';
import 'package:tara_app/services/config/api.dart';
import 'package:tara_app/utils/locale/utils.dart';

import '../routes.dart';
import 'base/base_state.dart';
import 'consumer/common_webview.dart';

class CreateAccountScreen extends StatefulWidget {
  final bool isFromMobileVerification;
  final bool isFromCreateAccount;
  final bool isFromCreatePassword;
  final bool isSingInClicked;
  final bool isFromCompleteProfile;
  final String mobileNumber;

  const CreateAccountScreen(
      {Key key,
        this.isFromMobileVerification = false,
        this.isFromCreateAccount = false,
        this.isFromCreatePassword = false,
        this.isSingInClicked = false,
        this.isFromCompleteProfile = false,
        this.mobileNumber})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CreateAccountScreenState();
  }
}

class _CreateAccountScreenState extends BaseState<CreateAccountScreen> {
  AuthController controller = Get.find();
  bool value=false;
  PhoneNumber number = PhoneNumber(isoCode: 'ID'); //change default country

  // var hasAcceptedTerms = true.obs;

  @override
  void initState() {
    controller.errorMessage.value = "";
    controller.mobileNumber.value = "";
    controller.mobileNumberTextEditController.clear();
    Utils().getPrivacyUrl();
    Utils().getTermsUrl();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Routes.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslation(Strings.CREATE_AN_ACCOUNT),
          style: TextStyles.headline6222,
        ),
        centerTitle: false,
        leading: Container(
          height: 24,
          width: 24,
          child: SvgPicture.asset(
            Assets.assets_icon_b_back_arrow,
            fit: BoxFit.scaleDown,
          ),
        ).onTap(onPressed: () {
          controller.mobileNumberTextEditController.clear();
          controller.passwordTextEditController.clear();
          Get.toNamed(Routes.LOGIN_OPTIONS);
        }),

        backgroundColor: AppColors.scaffold_color,
        elevation: 0,
      ),
      backgroundColor: AppColors.scaffold_color,
      body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslation(Strings.HELLO).split("!").first +
                            " 👋",
                        style: TextStyles.headline52,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        getTranslation(Strings.create_account_subtext),
                        style: TextStyles.body1222,
                      ),
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
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[400],
                                      width: 1.0,
                                    ),
                                  ),
                                  color: Colors.transparent,
                                ),
                                child: InternationalPhoneNumberInput(
                                  countries: server == "prod" ? ["ID"] : null,
                                  onInputChanged: (PhoneNumber number) {
                                    print(number.phoneNumber);
                                    controller.errorMessage.value = "";
                                    controller.mobileNumber.value =
                                        number.phoneNumber;
                                    if (controller
                                        .mobileNumber.value.length ==
                                        10 + 3) hideKeyboard();
                                  },
                                  onInputValidated: (bool value) {
                                    print(value);
                                  },
                                  selectorConfig: SelectorConfig(
                                    selectorType:
                                    PhoneInputSelectorType.DROPDOWN,
                                  ),
                                  ignoreBlank: false,
                                  selectorTextStyle:
                                  TextStyle(color: Colors.black),
                                  initialValue: number,
                                  textFieldController: controller
                                      .mobileNumberTextEditController,
                                  inputDecoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText:
                                    getTranslation(Strings.PHONE_NUMBER),
                                  ),
                                ),
                              ),
                              //  Divider(),
                              controller.errorMessage.value.isEmpty
                                  ? Container(
                                height: 8,
                              )
                                  : Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Container(
                                      margin: EdgeInsets.only(top: 8),
                                      child: Text(
                                        getTranslation(controller
                                            .errorMessage.value) ??
                                            controller
                                                .errorMessage.value,
                                        style:
                                        BaseStyles.error_text_style,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 24,
                                      width: 63,
                                      child: SvgPicture.asset(
                                        Assets.tara_logo_grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 16),
                        child: Row(
                          children: [
                            // Checkbox(
                            //            materialTapTargetSize:
                            //                MaterialTapTargetSize.shrinkWrap,
                            //            // value: val.value,
                            //            // onChanged: (v) {
                            //            //   val.value = v;
                            //            // },
                            //            activeColor: AppColors.white,
                            //            checkColor: AppColors.primaryText,
                            //          ),

                            Checkbox(
                              value: this.value,
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                              onChanged: (bool value) {
                                setState(() {
                                  this.value = value;
                                });
                              },
                              activeColor: AppColors.white,
                              checkColor: AppColors.primaryText,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: FittedBox(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Accept ',
                                    style: TextStyles.subtitle2222.copyWith(
                                        fontFamily: FontFamily.tara_sans),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'T&C',
                                          style: TextStyles.subtitle2222
                                              .copyWith(
                                            decoration:
                                            TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Get.to(CommonWebViewScreen(
                                                  title: getTranslation(
                                                      Strings
                                                          .terms_condition),
                                                  type: WebViewType.COMMON,
                                                  url:
                                                  Utils().getTermsUrl()));
                                            }),
                                      TextSpan(text: " and "),
                                      TextSpan(
                                          text: 'Privacy policy',
                                          style: TextStyles.subtitle2222
                                              .copyWith(
                                            decoration:
                                            TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Get.to(CommonWebViewScreen(
                                                  title: getTranslation(
                                                      Strings.privacy_policy),
                                                  type: WebViewType.COMMON,
                                                  url: Utils()
                                                      .getPrivacyUrl()));
                                            }),
                                      TextSpan(text: " to continue."),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      getContinueButtonWidget(),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getTranslation(Strings.already_have_account),
                            style: TextStyles.subtitle2222,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                            child: UnderlineText(
                              text: Text(
                                  getTranslation(Strings.login).toUpperCase(),
                                  style: BaseStyles
                                      .bottomSheetLocationChangeTextStyle,
                                  textAlign: TextAlign.left),
                              underlineColours:
                              AppColors.header_top_bar_color,
                            ),
                          ).onTap(onPressed: ()  {
                            controller.mobileNumberTextEditController.clear();
                            controller.passwordTextEditController.clear();
                            Get.offNamed(Routes.LOGIN);
                            // push(SignInScreen());
                          })

                        ],
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      getCopyrightLabel()
                    ]),
              )).onTap(onPressed: () {
            hideKeyboard();
          })),
    ).withProgressIndicator(showIndicator: controller.showProgress.value);
  }

  @override
  BuildContext getContext() {
    return context;
  }

  Widget getContinueButtonWidget() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: controller.mobileNumber.value.length >= 9 + 3 &&
             value
              ? AppColors.button_background_color
              : AppColors.grey2),
      alignment: Alignment.center,
      child: Text(
        getTranslation(Strings.CONTINUE),
        textAlign: TextAlign.center,
        style: controller.mobileNumber.value.length >= 9 + 3 &&
            value
            ? BaseStyles.contactsTextStyle
            : BaseStyles.saveAndContinueDisableTextStyle,
      ),
    ).onTap(onPressed: () {
      if (controller.mobileNumber.value.length >= 9 + 3 &&
          value) {
        FocusScope.of(context).requestFocus(FocusNode());
        hideKeyboard();
        controller.getOtp();
      }
    });
  }

  Widget getCopyrightLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              child: Icon(
                Icons.copyright,
                size: 14,
              )),
          SizedBox(
            width: 8,
          ),
          Text(getTranslation(Strings.copyright_setara),
              style: BaseStyles.copyright)
        ],
      ),
    );
  }
}
