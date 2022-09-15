import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tara_app/common/constants/assets.dart';
import 'package:tara_app/common/constants/strings.dart';
import 'package:tara_app/common/constants/values.dart';
import 'package:tara_app/common/constants/styles.dart';
import 'package:tara_app/common/helpers/mixpanel_helper.dart';
import 'package:tara_app/utils/locale/utils.dart';

import 'base/base_state.dart';

class CreateAccountSuccess extends StatefulWidget {
  _CreateAccountSuccessState createState() => _CreateAccountSuccessState();
}

class _CreateAccountSuccessState extends BaseState<CreateAccountSuccess> {
  @override
  void initState() {
    super.initState();
    // update the profile on mixpanel
    MixPanelHelper.createProfileOnMixpanel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslation(Strings.success),
          textAlign: TextAlign.left,
          style: TextStyles.headline62,
        ),
        automaticallyImplyLeading: false,
        // leading: Container(
        //   height: 24,
        //   width: 24,
        //   child: SvgPicture.asset(
        //     Assets.assets_icon_b_back_arrow,
        //     fit: BoxFit.scaleDown,
        //   ),
        // ).onTap(onPressed: () => Get.back()),
        backgroundColor: AppColors.scaffold_color,
        elevation: 0,
      ),
      backgroundColor: AppColors.scaffold_color,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getSvgImage(
                imagePath: Assets.assets_icon_account_successfully_created,
                height: 136,
                width: 136),
            SizedBox(
              height: 8,
            ),
            Text(
              getTranslation(Strings.account_created),
              style: TextStyles.headline52,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              getTranslation(Strings.account_success_msg),
              style: TextStyles.inputFieldOn2,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: getStartedWidget(),
      ),
    );
  }

  Widget getStartedWidget() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: AppColors.button_background_color),
      alignment: Alignment.center,
      child: Text(
        getTranslation(Strings.get_started),
        textAlign: TextAlign.center,
        style: BaseStyles.contactsTextStyle,
      ),
    ).onTap(onPressed: () {
      Get.offAllNamed(Utils().getLandingScreen());
    });
  }

  @override
  BuildContext getContext() {
    return context;
  }
}
