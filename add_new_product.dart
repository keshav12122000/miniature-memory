import 'package:flutter/material.dart';
import 'package:flutter_flavorizr/parser/models/flavors/app.dart';
import 'package:tara_app/common/constants/colors.dart';
import 'package:tara_app/common/constants/styles.dart';
import 'package:tara_app/common/constants/values.dart';
import 'package:tara_app/common/widgets/primary_button.dart';
import 'package:tara_app/common/widgets/snackbars.dart';
import 'package:tara_app/controller/inventory_controller.dart';
import 'package:tara_app/controller/order_controller.dart';
import 'package:tara_app/screens/base/base_state.dart';
import 'package:get/get.dart';
import 'package:tara_app/screens/inventory/single_product_field.dart';
import '../../common/widgets/extensions.dart';

class AddNewProduct extends StatefulWidget {
  @override
  _AddNewProductState createState() => _AddNewProductState();
}

class _AddNewProductState extends BaseState<AddNewProduct> {
  InventoryController controller = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.items.clear();
    controller.addItem();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: _buildAppBar(context),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.button_background_color,
          mini: true,
          onPressed: () => controller.addItem(),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom == 0
            ? getActionButtons()
            : SizedBox(),
        body: ListView.builder(
          itemBuilder: (_, i) {
            if (i == controller.items.length + 1)
              return SizedBox(
                height: 60,
              );
            if (i == controller.items.length)
              return MediaQuery.of(context).viewInsets.bottom == 0
                  ? SizedBox()
                  : getActionButtons();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SingleProductField(
                tempItem: controller.items[i],
                editingItem: false,
              ),
            );
          },
          // itemCount: controller.productsController.length,
          itemCount: controller.items.length + 2,
        ).onTap(onPressed: () => hideKeyboard()),
      ).withProgressIndicator(showIndicator: controller.showProgress.value),
    );
  }

  Widget getActionButtons() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 17, horizontal: 15),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                isPrimary: false,
                text: getTranslation(Strings.cancel),
                onTap: () {
                  Get.back();
                },
              ),
            ),
            SizedBox(
              width: 17,
            ),
            Expanded(
              child: PrimaryButton(
                text: getTranslation(Strings.add_product),
                isPrimary: true,
                onTap: () {controller.addProducts();}
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.button_background_color,
      elevation: 1,
      centerTitle: false,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pop(context, false) //Navigator.pop(context, false),
          ),
      title: Align(
        alignment: Alignment.topLeft,
        child: Text(
          getTranslation(Strings.add_product),
          textAlign: TextAlign.left,
          style: BaseStyles.topsettingBarTextStyle,
        ),
      ),
    );
  }

  @override
  BuildContext getContext() {
    return context;
  }
}
