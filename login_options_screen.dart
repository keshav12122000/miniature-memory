import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:new_version/new_version.dart';
import 'package:tara_app/common/constants/strings.dart';

import 'package:tara_app/common/constants/styles.dart';
import 'package:tara_app/screens/base/base_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:tara_app/common/constants/values.dart';
import 'package:tara_app/screens/merchant/create_store_screen.dart';
import 'package:tara_app/screens/signin_screen.dart';
import 'package:tara_app/utils/locale/utils.dart';

import '../routes.dart';
import 'create_account_screen.dart';
import 'mobile_verification_screen.dart';

class LoginOptions extends StatefulWidget {
  @override
  _LoginOptionsState createState() => _LoginOptionsState();
}

class _LoginOptionsState extends BaseState<LoginOptions> {

  @override
  void initState() {
    super.initState();

    _checkVersion();
  }

  void _checkVersion() async {
    final newVersion = NewVersion(
      androidId: Utils.package,
      // androidId: "com.snapchat.android",
    );
    newVersion.showAlertIfNecessary(context: context);
    // final status = await newVersion.getVersionStatus();
    // if(status!=null)
    //   {
    //     newVersion.showUpdateDialog(
    //       context: context,
    //       versionStatus: status,
    //       dialogTitle: "UPDATE!!!",
    //       dismissButtonText: "Skip",
    //       dialogText: "Please update the app from " + "${status.localVersion}" + " to " + "${status.storeVersion}",
    //       dismissAction: () {
    //         SystemNavigator.pop();
    //       },
    //       updateButtonText: "Lets update",
    //     );
    //     print("DEVICE : " + status.localVersion);
    //     print("STORE : " + status.storeVersion);
    //   }



  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.login_option_background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //logo
          Expanded(
            flex: 12,
            child: Image.asset(
              Assets.tara_logo,
              height: 64,
              width: 168,
            ),
          ),
          //create
          Expanded(child: getCreateAccountButton()),
          SizedBox(
            height: 16,
          ),
          //login
          Expanded(child: getLoginButtonWidget()),
          SizedBox(
            height: 16,
          ),
          //copyright
          getCopyrightLabel()
        ],
      ),
    );
  }

  Widget getCreateAccountButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: AppColors.button_background_color),
        alignment: Alignment.center,
        child: Text(
          getTranslation(Strings.CREATE_AN_ACCOUNT),
          textAlign: TextAlign.center,
          style: BaseStyles.contactsTextStyle,
        ),
      ).onTap(onPressed: () {
        print("create account pressed");
        Get.offNamed(Routes.SIGN_UP);
      }),
    );
  }

  Widget getLoginButtonWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 48,
        // margin: EdgeInsets.only(bottom: 16, top: 24,),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Colors.white),
        alignment: Alignment.center,
        child: Text(
          getTranslation(Strings.login),
          textAlign: TextAlign.center,
          style: TextStyles.bUTTONBlack2,
        ),
      ).onTap(onPressed: () {
        print("login pressed");
        Get.offNamed(Routes.LOGIN);
      }),
    );
  }

  Widget getCopyrightLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
              style: TextStyles.subtitle3222)
        ],
      ),
    );
  }

  @override
  BuildContext getContext() {
    return context;
  }
}
