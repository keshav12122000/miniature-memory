// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:retrofit/http.dart';
import 'package:tara_app/arguments.dart';
import 'package:tara_app/common/constants/values.dart';
import 'package:tara_app/common/helpers/enums.dart';
import 'package:tara_app/screens/inventory/edit_product.dart';
import 'package:tara_app/common/helpers/get_helper.dart';
import 'package:tara_app/common/helpers/mixpanel_helper.dart';
import 'package:tara_app/common/widgets/chat_widgets/dynamic_order_detail_page.dart';
import 'package:tara_app/common/widgets/error_state_info_widget.dart';
import 'package:tara_app/common/widgets/in_dev_popup.dart';
import 'package:tara_app/controller/inventory_controller.dart';
import 'package:tara_app/common/widgets/snackbars.dart';
import 'package:tara_app/controller/auth_controller.dart';
import 'package:tara_app/controller/inventory_controller.dart';
import 'package:tara_app/controller/order_controller.dart';
import 'package:tara_app/controller/store_controller.dart';
import 'package:tara_app/flavors.dart';
import 'package:tara_app/models/auth/auth_response.dart';
import 'package:tara_app/models/order_management/item/item.dart';
import 'package:tara_app/models/order_management/orders/order_response.dart';
import 'package:tara_app/models/order_management/orders/order_types.dart';
import 'package:tara_app/models/order_management/orders/statuses.dart';
import 'package:tara_app/utils/locale/utils.dart';
import '../injector.dart';
import '../routes.dart';
import 'base/base_state.dart';
import 'pos_screen.dart';

import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';

import 'consumer/home_customer_widget.dart';
import 'order_details_screen.dart';

class pos_screen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends BaseState<pos_screen> {
  // get storeController => null;
  StoreController storeController = Get.put(StoreController());
  InventoryController inventoryController = Get.find();
  @override
  void initState() {
    super.initState();
    getData();
    // pagination
    // paginate();
  }

  Future getData() async {
    inventoryController.getMetrics();
    storeController.getCategories();
    storeController.getCatalogue();
    await inventoryController.getMerchantsStore();
    storeController.getItems(
        inventoryController.stores.value.first.catalogue.id.toString());
  }

  static const double buttonPadding = 90;

  ListTab listTab = ListTab.inStore;
  RenderType renderType = RenderType.list;

  PayOptions payOption = PayOptions.cash;

  List<Item> itemsInCart = [];
  Map<String, int> itemsTally = {};

  var inventoryItems = [].cast<Item>().obs;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController controller;

  var isCartOpen = false.obs;
  double minimumExtent = 80;
  TextEditingController search_controller = TextEditingController();
  String filterQuery = "";

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.button_background_color,
          title: Text(
            "Create New Order",
            style: TextStyle(color: AppColors.white),
          ),
        ),
        key: _scaffoldKey,
        body: Stack(
          children: [
            Column(
              children: [
                searchBarWidget(getContext()).onTap(
                    onPressed: () => listTab == ListTab.online
                        ? getInDevPopup(getTranslation(Strings.feature_title),
                            getTranslation(Strings.feature_sub_title))
                        : null),

                Container(
                  child: Expanded(child: buildProductList()),
                ),

                // Container(
                //     child: Stack(
                //   children: [

                //   ],
                // ))
              ],
            ),
            MediaQuery.of(context).viewInsets.bottom == 0
                ? Obx(() => !isCartOpen.value
                    ? Column(
                        children: [Spacer(), getBottomSheetPreview()],
                      )
                    : SizedBox())
                : SizedBox(),
          ],
        ),
      ).withProgressIndicator(
          showIndicator: storeController.showProgress.value),
    );
  }

  buildProductList() {
    return Container(
      child: storeController.filteredItemsList?.isEmpty ?? false
          ? Center(
              child: Text("No Products"),
            )
          : ListView.separated(
              shrinkWrap: true,
              // controller: _scrollController,
              itemBuilder: (_, i) {
                var inventoryItems;
                return saleItemListCell(storeController.filteredItemsList[i]);
              },
              itemCount: storeController.filteredItemsList.length,
              separatorBuilder: (BuildContext context, int index) => Divider(
                thickness: 1,
                height: 1,
                color: AppColors.light_grey_bg_color,
              ),
            ),
    );
  }

  Padding buildInventoryItem(
    Item item,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 40,
              width: 40,
              child: Image.network(
                "${item.itemThumbnailUrl}",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Icon(Icons.error);
                },
                // loadingBuilder: (_, __, ___) {
                //   return CircularProgressIndicator();
                // },
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 16,
                ),
                Text(
                  "${item.itemName}",
                  style: TextStyles.bUTTONSmallBlack222,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "${item.category.isNullOrBlank ? "" : item.category.length > 0 ? item.category[0].name : "-NA-"}",
                  style: TextStyles.caption222,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  getTranslation(Strings.stock) + " : ${item.quantityInStock}",
                  style: TextStyles.bUTTONSmallBlack222
                      .copyWith(fontWeight: FontWeight.normal),
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
          Text(
            "${item.price.toCurrency()}/${item.metric ?? "Kgs"}",
            style: TextStyles.subtitle3222,
          ),
          SizedBox(
            width: 12,
          ),
          InkWell(
            onTap: () => Get.to(EditProduct(
              item: item,
            )),
            borderRadius: BorderRadius.circular(2),
            splashColor: AppColors.primaryText.withOpacity(0.2),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: getSvgImage(
                  imagePath: Assets.assets_icon_e_edit,
                  height: 16.0,
                  width: 16.0),
            ),
          )
        ],
      ),
    );
  }

  Widget saleItemListCell(Item item) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: Container(
                  height: 40,
                  width: 40,
                  child: Image.network(
                    "${item.itemImgUrl}",
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: AppColors.header_top_bar_color,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) {
                      return Icon(Icons.error);
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: TextStyles.bUTTONBlack2,
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      item.price.toCurrency(),
                      style: BaseStyles.sentOtpTextStyle,
                    ),
                  ],
                ),
              ),
              // Icon(
              //   Icons.delete,
              //   color: Colors.red,
              // ),
              Container(
                width: 50,
                height: 35,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                        size: 20,
                      )),
                ),
              ).onTap(
                  onPressed: () => setState(() {
                        if (controller != null) {
                          controller.close();
                          controller = null;
                        }
                        if (itemsTally[item.id.toString()] == 1) {
                          itemsTally.remove(item.id.toString());
                          itemsInCart.remove(item);
                        } else if (itemsTally.containsKey(item.id.toString())) {
                          itemsTally[item.id.toString()]--;
                        }
                      })),
              Text(
                (itemsTally[item.id.toString()] ?? 0).toString(),
                style: TextStyles.bUTTONBlack2,
              ),
              Container(
                width: 50,
                height: 35,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.add_circle,
                        color: AppColors.header_top_bar_color,
                        size: 20,
                      )),
                ),
              ).onTap(
                  onPressed: () => setState(() {
                        if (controller != null) {
                          controller.close();
                          controller = null;
                        }
                        if (itemsTally.containsKey(item.id.toString())) {
                          itemsTally[item.id.toString()]++;
                        } else {
                          itemsInCart.add(item);
                          itemsTally.putIfAbsent(item.id.toString(), () => 1);
                        }
                      })),
            ],
          ),
        ),
        Divider()
      ],
    ).onTap(onPressed: () => print("cell tapped"));
  }

  Widget getBottomSheetPreview() {
    return Container(
      height: buttonPadding,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          boxShadow: [
            BoxShadow(
                color: AppColors.box_shadow_color_1,
                offset: Offset(0, -2),
                blurRadius: 6,
                spreadRadius: 0),
            BoxShadow(
                color: AppColors.box_shadow_color_2,
                offset: Offset(0, 0),
                blurRadius: 2,
                spreadRadius: 0)
          ]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.grey2,
                        borderRadius: BorderRadius.all(Radius.circular(32))),
                    width: 50,
                    height: 4,
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalCartAmount().toCurrency(),
                      style: TextStyles.headline4222,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      itemsInCart.length == 0
                          ? getTranslation(Strings.no_items)
                          : totalCartCount().toString() +
                              " " +
                              getTranslation(Strings.items),
                      style: TextStyles.bUTTONSmallGrey32,
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      color: itemsInCart.length == 0
                          ? AppColors.grey2
                          : AppColors.button_background_color,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        getSvgImage(
                            imagePath: Assets.assets_icon_c_cart,
                            color: itemsInCart.length == 0
                                ? Color(0xff889aac)
                                : Colors.white),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          getTranslation(Strings.cart),
                          style: itemsInCart.length == 0
                              ? BaseStyles.saveAndContinueDisableTextStyle
                              : TextStyles.subtitle1222,
                        ),
                      ],
                    ),
                  ),
                ).onTap(onPressed: () {
                  if (itemsInCart.isNotEmpty) {
                    isCartOpen.value = true;
                    controller =
                        _scaffoldKey.currentState.showBottomSheet((context) {
                      return StatefulBuilder(
                        builder: (innercontext, setsState) {
                          return getBottomSheet(setsState);
                        },
                      );
                    });
                    controller.closed.then((value) {
                      isCartOpen.value = false;
                      if (controller != null) {
                        // controller.close();
                        controller = null;
                      }
                    });
                  } else {
                    isCartOpen.value = false;
                    Get.showSnackbar(Snackbars.errorSnackbar(
                        getTranslation(Strings.no_items_in_cart_message)));
                  }
                }
                    // showGeneralDialog(
                    //   context: getContext(),
                    //   barrierDismissible: true,
                    //   transitionDuration: Duration(milliseconds: 200),
                    //   barrierLabel: MaterialLocalizations.of(context).dialogLabel,
                    //   barrierColor: Colors.black.withOpacity(0.5),
                    //   pageBuilder: (context, animation, secondaryAnimation) => StatefulBuilder(
                    //     builder: (BuildContext innercontext, void Function(void Function()) setsState) => Padding(
                    //       padding: const EdgeInsets.only(top: 120),
                    //       child: Scaffold(body: getBottomSheet(setsState)),
                    //     ),
                    //   ),
                    // )
                    )
              ],
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget searchBarWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(color: Color(0xfff7f7f7)))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                border: Border.all(
                  color: search_controller.text.length == 0
                      ? AppColors.light_grey_blue
                      : AppColors.fareColor,
                ),
              ),
              child: TextField(
                controller: search_controller,
                onTap: () => isCartOpen.value ? pop() : null,
                enabled: listTab == ListTab.online ? false : true,
                onChanged: (value) {
                  if (listTab == ListTab.inStore) {
                    filterQuery = value;
                    // if(value.length > 2)
                    //   filterQuery = value;
                    // else
                    //   filterQuery = "";
                    setState(() {
                      if (value.length > 2)
                        storeController.filteredItemsList = storeController
                            .itemsList
                            .where((element) => element.itemName
                                .toLowerCase()
                                .contains(filterQuery.toLowerCase()))
                            .toList();
                      else
                        storeController.filteredItemsList =
                            storeController.itemsList;
                    });
                  } else if (listTab == ListTab.online) {
                    //
                  }
                },
                style: TextStyle(color: AppColors.fareColor),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: getTranslation(Strings.search_items),
                    contentPadding: EdgeInsets.only(top: 15),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.light_grey_blue,
                    ),
                    suffixIcon: Icon(
                      Icons.cancel_outlined,
                      color: search_controller.text.length == 0
                          ? AppColors.light_grey_blue
                          : AppColors.fareColor,
                    ).onTap(
                        onPressed: () => setState(() {
                              resetSearch();
                            }))
                    // suffixIcon: listTab == ListTab.online
                    //   ? SizedBox()
                    //   : Padding(
                    //       padding: const EdgeInsets.only(right: 8),
                    //       child: SvgPicture.asset(
                    //         Assets.assets_icon_s_scan,
                    //         fit: BoxFit.scaleDown,
                    //       ),
                    //     )
                    ),
                onSubmitted: (value) {
                  resetSearch();
                },
              ),
            )),
            // SizedBox(
            //   width: 16,
            // ),
            // listTab == ListTab.online
            //   ? Icon(
            //       Icons.filter_alt_outlined,
            //       color: AppColors.header_top_bar_color,
            //     ).onTap()
            //   : Row(
            //       children: [
            //         Icon(
            //           renderType != RenderType.grid
            //             ? Icons.grid_view
            //             : Icons.list,
            //           color: AppColors.header_top_bar_color,
            //         ),
            //         SizedBox(
            //           width: 8,
            //         ),
            //         Container(
            //           width: 35,
            //           child: Center(
            //             child: Text(
            //               renderType != RenderType.grid
            //                 ? getTranslation(Strings.grid)
            //                 : getTranslation(Strings.list),
            //               style: TextStyles.subtitle12,
            //             ),
            //           ),
            //         )
            //       ],
            //     ).onTap(onPressed: () => setState(() {
            //       renderType == RenderType.grid
            //         ? renderType = RenderType.list
            //         : renderType = RenderType.grid;
            //     })),
          ],
        ),
      ),
    );
  }

  Widget getBottomSheet(void Function(void Function()) setsState) {
    return Container(
      height: MediaQuery.of(context).size.height * 3 / 4,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          boxShadow: [
            BoxShadow(
                color: AppColors.box_shadow_color_1,
                offset: Offset(0, -2),
                blurRadius: 6,
                spreadRadius: 0),
            BoxShadow(
                color: AppColors.box_shadow_color_2,
                offset: Offset(0, 0),
                blurRadius: 2,
                spreadRadius: 0)
          ]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.grey2,
                        borderRadius: BorderRadius.all(Radius.circular(32))),
                    width: 50,
                    height: 4,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslation(Strings.cart),
                    style: TextStyles.headline62,
                  ),
                  // PopupMenuButton(
                  //   itemBuilder: (context) => [
                  //     // PopupMenuItem<String>(
                  //     //   child: popupButton(Strings.save_cart_later,
                  //     //           getSvgImage(imagePath: Assets.ic_folder))
                  //     //       .onTap(onPressed: () {
                  //     //     Navigator.pop(context);
                  //     //     getInDevPopup(getTranslation(Strings.feature_title),
                  //     //         getTranslation(Strings.feature_sub_title));
                  //     //   }),
                  //     //   // value: 'Save cart for later'
                  //     // ),
                  //     // PopupMenuItem<String>(
                  //     //   child: popupButton(Strings.save_cart_items,
                  //     //           getSvgImage(imagePath: Assets.ic_save))
                  //     //       .onTap(onPressed: () {
                  //     //     Navigator.pop(context);
                  //     //     getInDevPopup(getTranslation(Strings.feature_title),
                  //     //         getTranslation(Strings.feature_sub_title));
                  //     //   }),
                  //     //   // value: 'Saved cart items'
                  //     // ),

                  //     // PopupMenuItem<String>(
                  //     //   child: popupButton(
                  //     //           Strings.clear_cart,
                  //     //           Icon(
                  //     //             Icons.delete_outline_outlined,
                  //     //             color: Color(0xfff95074),
                  //     //           ),
                  //     //           colour: Color(0xfff95074))
                  //     //       .onTap(onPressed: () {
                  //     //     setsState(() {
                  //     //       setState(() {
                  //     //         if (controller != null) {
                  //     //           controller.close();
                  //     //           controller = null;
                  //     //         }
                  //     //         isCartOpen.value = false;
                  //     //         itemsInCart.clear();
                  //     //         itemsTally.clear();
                  //     //         Navigator.pop(context);
                  //     //         // Navigator.pop(context);
                  //     //       });
                  //     //     });
                  //     //   }),
                  //     //   // value: 'Clear cart',
                  //     // ),
                  //   ],
                  //   child: Icon(
                  //     Icons.more_vert_rounded,
                  //     color: AppColors.header_top_bar_color,
                  //   ),
                  // ),
                ],
              ),
            ),
            Divider(),
            Flexible(
              child: Container(
                height: MediaQuery.of(context).size.height * 2 / 7,
                child: itemsInCart.length == 0
                    // ? buildEmptyView(Assets.illustration_no_order_yet, getTranslation(Strings.no_items))
                    ? Center(
                        child: Text(
                          getTranslation(Strings.no_items),
                          style: BaseStyles.subHeaderTextStyle,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: itemsInCart.length,
                        itemBuilder: (context, index) => Column(
                          children: [
                            cartCellUnit(itemsInCart[index]),
                            SizedBox(
                              height: 8,
                            )
                          ],
                        ),
                      ),
              ),
            ),
            Divider(),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.grey2,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslation(Strings.total),
                      style: TextStyles.subtitle12,
                    ),
                    Text(
                      totalCartAmount().toCurrency(),
                      style: TextStyles.subtitle12,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    getTranslation(Strings.pay_with),
                    style: TextStyles.caption2,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: payOptions(Strings.cash, Assets.assets_cash,
                          payOption == PayOptions.cash)
                      .onTap(
                          onPressed: () => setState(() {
                                payOption = PayOptions.cash;
                              })),
                ),
                SizedBox(
                  width: 8,
                ),
                // Expanded(
                //   child: payOptions(Strings.card, Assets.assets_card,
                //           payOption == PayOptions.card)
                //       .onTap(
                //           onPressed: () => Get.showSnackbar(Snackbars.errorSnackbar(
                //         getTranslation(Strings.payment_method_unavailable)))
                //           // onPressed: () => setState(() {
                //           //   payOption = PayOptions.card;
                //           // })
                //           ),
                // ),
                Spacer(),
                SizedBox(
                  width: 8,
                ),
                Spacer(),
                // Expanded(
                //   child: payOptions(Strings.qr_code, Assets.assets_icon_s_scan,
                //           payOption == PayOptions.qrcode)
                //       .onTap(
                //           onPressed: () => Get.showSnackbar(Snackbars.errorSnackbar(
                //         getTranslation(Strings.payment_method_unavailable)))
                //           // onPressed: () => setState(() {
                //           //   payOption = PayOptions.qrcode;
                //           // })
                //           ),
                // ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            SafeArea(
              child: getProceedButton().onTap(onPressed: () async {
                if (itemsInCart.isNotEmpty) {
                  await Get.toNamed(Routes.CASH_CALCULATION,
                      arguments: CustomArguments(
                          amount: totalCartAmount(),
                          itemsList: itemsInCart,
                          itemsTally: itemsTally,
                          totalItems: totalCartCount()));
                  // setState(() {
                  //   isCartOpen.value = false;
                  //   filterQuery = "";
                  //   search_controller.clear();
                  //   store_controller.filteredItemsList =
                  //       store_controller.itemsList;
                  //   Navigator.pop(context);
                  // }
                  // );
                }
              }),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget cartCellUnit(Item item) {
    return Row(
      children: [
        Row(
          children: [
            Text(
              itemsTally[item.id.toString()].toString(),
              style: TextStyles.bUTTONBlack2,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              "x",
              style: BaseStyles.purchaseLabelTextStyle,
            )
          ],
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.itemName,
                style: TextStyles.subtitle22,
              ),
              Text(
                item.price.toCurrency(),
                style: BaseStyles.purchaseLabelTextStyle,
              )
            ],
          ),
        ),
        Text(
          (item.price * itemsTally[item.id.toString()]).toCurrency(),
          style: TextStyles.subtitle12,
        ),
      ],
    );
  }

  Widget payOptions(String label, String asset, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.box_shadow_color,
                      offset: Offset(0, 2),
                      spreadRadius: 0,
                      blurRadius: 6),
                  BoxShadow(
                    color: AppColors.box_shadow_color_3,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                    blurRadius: 2,
                  )
                ]
              : [],
          color: isSelected ? Colors.white : AppColors.background_color),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
        child: Column(
          children: [
            getSvgImage(imagePath: asset),
            SizedBox(
              height: 8,
            ),
            Text(
              getTranslation(label),
              maxLines: 1,
              style: TextStyles.subtitle22,
            )
          ],
        ),
      ),
    );
  }

  Widget popupButton(String label, Widget icon,
      {Color colour = AppColors.header_top_bar_color}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          icon,
          SizedBox(
            width: 16,
          ),
          Text(
            getTranslation(label),
            style: colour == Color(0xfff95074)
                ? BaseStyles.declineButtonTextStyle
                : TextStyles.subtitle2222,
          ),
        ],
      ),
    );
  }

  Widget getProceedButton() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: itemsInCart.isNotEmpty
              ? AppColors.button_background_color
              : AppColors.grey2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            getTranslation(Strings.proceed),
            style: itemsInCart.isNotEmpty
                ? TextStyles.subtitle1234
                : BaseStyles.saveAndContinueDisableTextStyle,
          ),
        ),
      ),
    );
  }

  resetSearch() {
    filterQuery = "";
    search_controller.clear();
    storeController.filteredItemsList = storeController.itemsList;
  }

  double totalCartAmount() {
    double amount = 0;
    for (int i = 0; i < itemsInCart.length; i++) {
      amount += itemsInCart[i].price * itemsTally[itemsInCart[i].id.toString()];
    }
    return amount;
  }

  int totalCartCount() {
    int count = 0;
    for (int i = 0; i < itemsInCart.length; i++) {
      count += itemsTally[itemsInCart[i].id.toString()];
    }
    return count;
  }

  @override
  BuildContext getContext() {
    return context;
  }
}
