// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tara_app/common/constants/assets.dart';
import 'package:tara_app/common/constants/colors.dart';
import 'package:tara_app/common/constants/radii.dart';
import 'package:tara_app/common/constants/strings.dart';
import 'package:tara_app/common/constants/styles.dart';
import 'package:tara_app/common/widgets/login_flow_widgets/account_confirmation.dart';
import 'package:tara_app/common/widgets/sign_in_flow_bg.dart';
import 'package:tara_app/common/widgets/text_field_widget.dart';
import 'package:tara_app/common/widgets/text_with_bottom_overlay.dart';
import 'package:tara_app/screens/base/base_state.dart';
import 'package:tara_app/screens/consumer/home_customer_screen.dart';
import 'package:tara_app/screens/create_account_screen.dart';

class CreatePassword extends StatefulWidget {
  @override
  _CreatePasswordState createState() => _CreatePasswordState();
}

class _CreatePasswordState extends BaseState<CreatePassword> {
  OverlayEntry _overlayEntry;
  GlobalKey _newPass = GlobalKey();
  GlobalKey _confirmPass = GlobalKey();

  TextEditingController createPass = TextEditingController();
  TextEditingController confirmPass = TextEditingController();
  bool isFailedValidation = false;

  @override
  void init() {
    // TODO: implement init
    super.init();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SignInFlowBg(child: getCreatePasswordWidget()),
    );
  }

  Widget getCreatePasswordWidget() {
    return Container(
      height: 400,
      margin: EdgeInsets.only(left: 32),
      padding: EdgeInsets.only(left: 24, top: 16, right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Radii.border(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context, false);
            },
            child: Container(
              width: 32,
              height: 24,
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(bottom: 8, top: 8),
              child: Image.asset(
                "assets/images/icon-5.png",
                fit: BoxFit.none,
              ),
            ),
          ),
          TextWithBottomOverlay(titleStr: Strings.create_password),
          Container(
            color: Colors.grey[200],
            height: 1,
          ),
          Container(
            margin: EdgeInsets.only(top: 16),
            child: Text(getTranslation(Strings.create_pass_sub_heading),
                style: BaseStyles.subHeaderTextStyle),
          ),
          Container(
            margin: EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                color: AppColors.light_grey_blue,
                width: 1.0,
              ),
            )),
            child: Row(children: [
              Expanded(
                flex: 1,
                child: InkWell(
                  key: _newPass,
                  onTap: () {
                    showOverLay(true);
                  },
                  child: Image.asset(Assets.ic_lock,
                      color: AppColors.light_grey_blue),
                ),
              ),
              Expanded(
                  flex: 9,
                  child: TextFieldWidget(
                    isObscure: true,
                    hint: getTranslation(Strings.new_pass),
                    placeHolderStyle: BaseStyles.subHeaderTextStyle,
                    textController: createPass,
                  )),
            ]),
          ),
          Container(
            margin: EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                color: isFailedValidation == false
                    ? AppColors.light_grey_blue
                    : AppColors.badge_color,
                width: 1.0,
              ),
            )),
            child: Row(children: [
              Expanded(
                flex: 1,
                child: InkWell(
                  key: _confirmPass,
                  onTap: () {
                    showOverLay(false);
                  },
                  child: Image.asset(Assets.ic_lock,
                      color: AppColors.light_grey_blue),
                ),
              ),
              Expanded(
                  flex: 9,
                  child: TextFieldWidget(
                    isObscure: true,
                    hint: getTranslation(Strings.confirm_pass),
                    placeHolderStyle: BaseStyles.subHeaderTextStyle,
                    textController: confirmPass,
                  )),
            ]),
          ),
          isFailedValidation == false
              ? Container()
              : Text(
                  "Password didn’t match. Please try again.",
                  style: BaseStyles.error_text_style,
                ),
          _getContinueWidget()
        ],
      ),
    );
  }

  void showOverLay(bool isNewPass) async {
    if (_overlayEntry == null) {
      _overlayEntry = getOverLayWidget(isNewPass);
      Overlay.of(context).insert(_overlayEntry);
    } else {
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  getOverLayWidget(bool isNewPass) {
    RenderBox renderBox;
    if (isNewPass)
      renderBox = _newPass.currentContext.findRenderObject();
    else
      renderBox = _confirmPass.currentContext.findRenderObject();

    final position = renderBox.localToGlobal(Offset.zero);
    print(position);

    return OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Positioned(
                        top: position.dy - 170,
                        left: position.dx,
                        child: GestureDetector(
                          child: Container(
                            width: 328,
//                          height: 150,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColors.shadow_list_color_1,
                                      offset: Offset(0, 6),
                                      blurRadius: 14,
                                      spreadRadius: 0),
                                  BoxShadow(
                                      color: const Color(0x1a000000),
                                      offset: Offset(0, 0),
                                      blurRadius: 4,
                                      spreadRadius: 0)
                                ],
                                color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getTranslation(Strings.pass_heading),
                                  style: BaseStyles.overLayTextStyle_heading,
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 16, right: 8),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        Assets.ic_pass_fail,
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: 16, right: 8),
                                      ),
                                      Text(
                                        getTranslation(Strings.capital_letter),
                                        style: BaseStyles.overLayTextStyle_grey,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 16, right: 8),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        Assets.ic_pass_pass,
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: 16, right: 8),
                                      ),
                                      Text(
                                        getTranslation(Strings.number),
                                        style:
                                            BaseStyles.overLayTextStyle_satisfy,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 16, right: 8),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        Assets.ic_pass_fail,
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: 16, right: 8),
                                      ),
                                      Text(
                                        getTranslation(Strings.special_char),
                                        style: BaseStyles.overLayTextStyle_grey,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                            _overlayEntry.remove();
                            _overlayEntry = null;
                          },
                        ),
                      ),
                      Positioned(
                        top: position.dy - 16,
                        left: position.dx + 5,
                        child: SvgPicture.asset(
                          Assets.triangle,
                          color: Colors.white,
                          width: 24,
                          height: 24,
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {
                  _overlayEntry.remove();
                  _overlayEntry = null;
                }));
      },
    );
  }

  _getContinueWidget() {
    return InkWell(
      onTap: () {
        if (confirmPass.text != createPass.text) {
          setState(() {
            isFailedValidation = true;
          });
        } else {
          push(CreateAccountScreen(
            isFromCreatePassword: true,
          ));
        }
      },
      child: Container(
        height: 48,
        margin: EdgeInsets.only(
          bottom: 16,
          top: 24,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: AppColors.bottom_border_color),
        alignment: Alignment.center,
        child: Text(
          getTranslation(Strings.CONTINUE),
          textAlign: TextAlign.center,
          style: BaseStyles.addNewBankAccount,
        ),
      ),
    );
  }

  @override
  BuildContext getContext() {
    // TODO: implement getContext
    return context;
  }
}
