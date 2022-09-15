// @dart=2.9
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tara_app/common/constants/assets.dart';
import 'package:tara_app/common/constants/colors.dart';
import 'package:tara_app/common/constants/styles.dart';
import 'package:tara_app/common/constants/values.dart';
import 'package:tara_app/common/helpers/mixpanel_helper.dart';
import 'package:tara_app/controller/inventory_controller.dart';
import 'package:tara_app/controller/store_controller.dart';
import 'package:tara_app/models/order_management/catalogue_category/category.dart';
import 'package:tara_app/models/order_management/item/item.dart';
import 'package:tara_app/models/order_management/item/metric.dart';
import 'package:tara_app/models/supercatalog/supercatalog_response.dart';
import 'package:tara_app/screens/base/base_state.dart';
import 'package:tara_app/services/util/image_picker_helper.dart';

import '../../models/order_management/catalogue_category/catalogue.dart';
// import 'auto_complete_text_view.dart';
import 'choose_category_sheet.dart';

class SingleProductField extends StatefulWidget {
  final Item tempItem;
  final bool editingItem;

  const SingleProductField({Key key, this.tempItem, this.editingItem})
      : super(key: key);
  @override
  _SingleProductFieldState createState() => _SingleProductFieldState();
}

class _SingleProductFieldState extends BaseState<SingleProductField> {
  InventoryController _controller = Get.find();
  // ProductController _productController;


  var pcs = "".obs;

  @override
  void initState() {
    super.initState();
    // _productController = Get.put(ProductController(widget.tempItem),tag: widget.tempItem.hashCode.toString());
    var item = widget.tempItem;
    productController.text = item.itemName ?? "";
    priceController.text = (item.price ?? "").toString();
    stockController.text = item.quantityInStock == 0
        ? null
        : (item.quantityInStock ?? "").toString();
    pcs.value = item.metric ?? _controller.metrics.first.name;
    selectedCategory.value = item.category ?? [];
    descriptionController.text = item.description ?? "";
    categoryController.text =
        item?.category?.map((e) => e.name)?.join(", ") ?? "";
    if (widget.editingItem) {
      isNetworkImage = true;
      isImageSelected = true;
    }

    trackQuantity = item.checkStockQty ?? true;
    inStock = item.inStock ?? true;
    item.checkStockQty = trackQuantity;
    item.inStock = inStock;
  }

  var isImageSelected = false;
  var isNetworkImage = false;
  var filePath = "";

  bool trackQuantity = true;
  bool inStock = true;
  SuperCatalogResponse suggestion;

  var selectedCategory = [].cast<Category>().obs;

  final productController = TextEditingController();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeleteButton(),
          SizedBox(
            height: 5,
          ),
          _buildUploadImgContainer(),
          SizedBox(
            height: 17,
          ),
          Text("ENTER PRODUCT NAME",style: TextStyles.bUTTONBlack222,),
          TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
                controller: productController,
                // autofocus: true,
                // style: DefaultTextStyle.of(context).style.copyWith(
                //     fontStyle: FontStyle.italic
                // ),
                decoration: InputDecoration(
                  hintText: "Search Your Product",
                  // border: OutlineInputBorder()
                )
            ),
            suggestionsCallback: (pattern) async {
              widget.tempItem.itemName = pattern;
              if(pattern.isEmpty) return [];
              return _controller.getSuperCatalogProducts(pattern);
              // return ["Burger", "Something", "Nothing"].where((element) => element.toLowerCase().startsWith(pattern.toLowerCase()));
            },
            itemBuilder: (context, suggestion) {
              var a =suggestion as SuperCatalogResponse;
              return ListTile(
                leading:
                // widget.tempItem.itemImgUrl=suggestion
                // Image.network("${a.itemThumbnailUrl}"),
                Image.asset(Assets.ic_camera,),

                // title: Text(suggestion.productName),
                title: Text("${a.productName}"),
              );
            },
            onSuggestionSelected: ( suggestion) {

              var  a = suggestion as SuperCatalogResponse;
              widget.tempItem.itemName = productController.text=a.productName.toString();
              stockController.text  =  a.stock.toString();
              widget.tempItem.quantityInStock =a.stock;
              //widget.tempItem.itemImgUrl=a.itemImgUrl.toString();
              // categoryController.text=a.category.name.toString();
              // widget.tempItem.category = [a.category];
              widget.tempItem.description = descriptionController.text=a.productDescription.toString();
              // pcs.value=a.price_per_unit;
             // isImageSelected = true;
             // isNetworkImage = true;
              // widget.tempItem.itemImgUrl=a.itemImgUrl;
              //widget.tempItem.itemImgUrl="https://en.wikipedia.org/wiki/Image#/media/File:Image_created_with_a_mobile_phone.png";
              //

              // _controller.metrics.add(a.price_per_unit.toString());
            },
          ),
          // _buildField(getTranslation(Strings.product_name),
          //     getTranslation(Strings.ener_product_name),
          //     controller: nameController,
          //     onChanged: (value)
          //     {
          //         widget.tempItem.itemName = value;
          //     },
          //     max: 50),
          SizedBox(
            height: 17,
          ),
          _controller.stores.value.first.industry.id != 2
              ? SizedBox()
              : Container(
            decoration: BoxDecoration(
              color: AppColors.grey3,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslation(Strings.track_stock).split(" ").last,
                  style: TextStyles.subtitle12,
                ),
                Container(
                  height: 1,
                  margin: EdgeInsets.only(top: 8),
                  color: AppColors.grey2,
                ),
                Row(
                  children: [
                    Text(
                      getTranslation(Strings.in_stock),
                      style: TextStyles.bUTTONBlack2,
                    ),
                    Spacer(),
                    SizedBox(
                      width: 16,
                    ),
                    Switch(
                      activeColor: AppColors.button_background_color,
                      value: inStock,
                      onChanged: (value) => setState(() {
                        inStock = !inStock;
                        stockController.clear();
                        if (!inStock) {
                          trackQuantity = false;
                          widget.tempItem.checkStockQty = trackQuantity;
                          widget.tempItem.quantityInStock = 0;
                        }
                        widget.tempItem.inStock = inStock;
                      }),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          getSvgImage(
                              imagePath: trackQuantity
                                  ? Assets.ic_check_filled
                                  : Assets.ic_check_un_select),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            getTranslation(Strings.track_stock),
                            style: TextStyles.bUTTONBlack2,
                          ),
                        ],
                      ),
                    ).onTap(
                        onPressed: () => inStock
                            ? setState(() {
                          stockController.clear();
                          trackQuantity = !trackQuantity;
                          if (!trackQuantity)
                            widget.tempItem.quantityInStock = 0;
                          widget.tempItem.checkStockQty =
                              trackQuantity;
                          widget.tempItem.inStock = true;
                        })
                            : null),
                    Spacer(),
                    // Text(
                    //   getTranslation(Strings.stock),
                    //   style: TextStyles.bUTTONBlack2,
                    // ),
                    // SizedBox(
                    //   width: 12,
                    // ),
                    !trackQuantity
                        ? Expanded(
                        child: _buildField(
                            getTranslation(Strings.stock),
                            getTranslation(Strings.stock_not_tracked),
                            showHeader: false,
                            inputType: TextInputType.number,
                            enabled: false))
                        : Expanded(
                        child: _buildField(
                            getTranslation(Strings.stock),
                            getTranslation(Strings.enter_stock),
                            showHeader: false,
                            inputType: TextInputType.number,
                            controller: stockController,
                            onChanged: (s) {
                              widget.tempItem.quantityInStock =
                                  int.tryParse(s);
                            }, max: 9)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 17,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                  child: _buildField(getTranslation(Strings.price),
                      getTranslation(Strings.enter_price),
                      inputType: TextInputType.number,
                      controller: priceController, onChanged: (s) {
                        widget.tempItem.price = double.tryParse(s);
                      }, max: 10)),
              Container(
                margin: EdgeInsets.only(left: 24, right: 8, top: 8, bottom: 8),
                child: Text(
                  "/",
                  style: TextStyle(
                    color: AppColors.light_grey_blue,
                    fontSize: 24,
                  ),
                ),
              ),
              _getDropDownList(),
              SizedBox(
                width: 16,
              ),
              _controller.stores.value.first.industry.id == 2
                  ? SizedBox()
                  : Expanded(
                  child: _buildField(getTranslation(Strings.stock),
                      getTranslation(Strings.enter_stock),
                      inputType: TextInputType.number,
                      controller: stockController, onChanged: (s) {
                        widget.tempItem.quantityInStock = int.tryParse(s);
                      }, max: 9)),
            ],
          ),
          SizedBox(
            height: 17,
          ),
          _buildField(
            getTranslation(Strings.category).capitalize,
            getTranslation(Strings.select_category),
            suffixIcon: getSvgImage(
              imagePath: Assets.assets_icon_a_arrow_down,
            ),
            controller: categoryController,
            focusNode: new AlwaysDisabledFocusNode(),
            onTap: () => chooseCategory(),
          ),
          SizedBox(
            height: 17,
          ),
          _buildField(getTranslation(Strings.description),
              getTranslation(Strings.optional),
              controller: descriptionController, onChanged: (s) {
                widget.tempItem.description = s;
              }, max: 500, lines: 8),
        ],
      ),
    );
  }

  _buildUploadImgContainer() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.light_grey_bg_color, width: 1)),
      padding: EdgeInsets.only(bottom: 12, left: 8, right: 8, top: 6),
      child: Row(
        children: [
          Container(
              width: 112,
              height: 114,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    child: isImageSelected
                        ? _buildImageView()
                        : _buildEmptyImageView(),
                  ),
                  if (isImageSelected) buildCrossIcon()
                ],
              )),
          SizedBox(
            width: 5,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslation(Strings.upload_product_photo),
                style: TextStyles.subtitle1222,
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 156),
                child: Text(
                  getTranslation(Strings.minimum_photo_size),
                  style: BaseStyles.sentOtpTimeTextStyle
                      .copyWith(fontWeight: FontWeight.normal),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Positioned buildCrossIcon() {
    return Positioned(
      right: 0,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onRemoveImage(),
          child: CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: getSvgImage(imagePath: Assets.close_icon),
            ),
          ),
        ),
      ),
    );
  }

  _buildEmptyImageView() {
    return InkWell(
      // onTap: () => uploadImage(),
      onTap: () => _showSelectionDialog(context),
      child: DottedBorder(
        radius: Radius.circular(56),
        dashPattern: [3, 1],
        // color: Colors.red,
        // strokeCap: StrokeCap.round,
        color: AppColors.light_grey_blue,
        padding: EdgeInsets.zero,
        child: Container(
          height: 104,
          width: 104,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(8),
            color: AppColors.light_grey_bg_color,
          ),
          child: CircleAvatar(
            radius: 28,
            child: getSvgImage(
                imagePath: Assets.assets_icon_p_product_photo,
                width: 36.0,
                height: 36.0),
          ),
        ),
      ),
    );
  }

  Container _buildImageView() {
    return Container(
      height: 104,
      width: 104,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.light_grey_blue)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.editingItem | isNetworkImage
                ? Image.network(
              "${widget.tempItem.itemImgUrl}",
              fit: BoxFit.cover,
              width: 104,
              errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Icons.error,
                    size: 56,
                  )),
            )
                : Image.file(
              File(filePath ?? ""),
              fit: BoxFit.cover,
              width: 104,
              errorBuilder: (_, __, ___) => Icon(Icons.error),
            ),
            if (widget.tempItem.uploadingImage ?? false)
              Container(
                  color: Colors.black.withOpacity(0.2),
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                  width: 104,
                  height: 104
              )
          ],
        ),
      ),
    );
  }

  Align _buildDeleteButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          highlightColor: Colors.pink.withOpacity(0.1),
          splashColor: Colors.pink.withOpacity(0.2),
          onTap: () {
            if (widget.editingItem) {
              MixPanelHelper.trackEvent(MixpanelEvents.removed_product,
                  eventProperties: widget.tempItem.toMap());
              _controller.removeItem([widget.tempItem]);
            } else {
              _controller.deleteEmptyItem(widget.tempItem);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                getSvgImage(
                    imagePath: Assets.assets_icon_t_trash,
                    color: Colors.pink,
                    height: 16.0,
                    width: 16.0),
                SizedBox(
                  width: 5,
                ),
                Text(
                  getTranslation(Strings.delete).toUpperCase(),
                  style: TextStyles.bUTTONSmallRed2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  BuildContext getContext() {
    return context;
  }

  _buildField(String text, String hint,
      {TextInputType inputType,
        VoidCallback onTap,
        bool enabled,
        TextEditingController controller,
        Widget suffixIcon,
        FocusNode focusNode,
        bool showHeader,
        onChanged(String s),
        max,
        int lines}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showHeader ?? true
            ? Text(
          "$text",
          style: TextStyles.bUTTONSmallBlack222,
        )
            : SizedBox(),
        TextFormField(
          keyboardType: inputType ?? TextInputType.text,
          onTap: onTap,
          controller: controller,
          enabled: enabled ?? true,
          focusNode: focusNode,
          onChanged: onChanged,
          maxLines: lines ?? 1,
          minLines: lines ?? 1,
          inputFormatters: [LengthLimitingTextInputFormatter(max ?? 50)],
          decoration: InputDecoration(hintText: "$hint", suffix: suffixIcon),
        ),
      ],
    );
  }

  //TODO Search in categories
  // for showing the choose category sheet and return the list of the selected categories
  void chooseCategory() async {
    List<Category> lc = await Get.bottomSheet(
      ChooseCategorySheet(
        // previously selected category if exist
        previouslySelected: selectedCategory.value,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
    if (lc != null) {
      StoreController storeController = Get.find();
      // widget.tempItem.catalogue =
      //     // Catalogue.fromJson({"id": 237, "name": "Catalogue Demo Test"})
      //     storeController.catalogues.value;
      widget.tempItem.category = lc;
      categoryController.text = lc.map((e) => e.name).toList().join(', ');
    }
  }

  uploadImage({ImageSource imageSource}) async {
    setState(() {
      widget.tempItem.uploadingImage = true;
    });
    // method for taking image from the camera and returns the path
    await ImagePickerHelper.takeImageFromCamera(
        imageSource: imageSource ?? ImageSource.camera)
        .then((value) async {
      if (value != null) {
        isImageSelected = true;
        isNetworkImage = false;
        filePath = value;
        setState(() {});
        var r;
        if (widget.editingItem) {
          r = await _controller.updateDocument(File(filePath),
              widget.tempItem.itemMainImgId, widget.tempItem.itemThumbnailId);
        } else {
          r = await _controller.uploadImage(File(filePath));
        }
        if (r != null) {
          widget.tempItem.itemMainImgId = r.documentDetails[0].documentId;
          widget.tempItem.itemThumbnailId = r.thumbnailList[0].documentId;
        }
      }
    });

    setState(() {
      widget.tempItem.uploadingImage = false;
    });
  }

  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                getTranslation(Strings.take_picture_dialog),
                style: BaseStyles.mobileNoTextStyle,
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      height: 1,
                      color: Colors.grey[300],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        getTranslation(Strings.gallery),
                        style: BaseStyles.itemOrderTextStyle,
                      ),
                    ).onTap(onPressed: () {
                      Navigator.of(context).pop();
                      uploadImage(imageSource: ImageSource.gallery);
                    }),
                    Padding(padding: EdgeInsets.all(8.0)),
                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        getTranslation(Strings.camera),
                        style: BaseStyles.itemOrderTextStyle,
                      ),
                    ).onTap(onPressed: () {
                      Navigator.of(context).pop();
                      // Get.off();
                      uploadImage();
                    }),
                  ],
                ),
              ));
        });
  }

  onRemoveImage() {
    // widget.tempItem.itemMainImgId = null;
    // widget.tempItem.itemThumbnailId = null;
    // widget.tempItem.itemImgUrl = null;
    // widget.tempItem.itemImgUrl = null;
    isImageSelected = false;
    filePath = "";
    setState(() {});
  }

  Widget _getDropDownList() {
    // for handling the old hardcoded metric
    if (widget.editingItem &&
        !_controller.metrics
            .map((e) => e.name)
            .toList()
            .contains(widget.tempItem.metric)) {
      pcs.value = "";
    }
    return Obx(
          () => Container(
        width: 100,
        // color: Colors.red,
        child: Center(
          child: DropdownButton(
            value: pcs.value == "" ? null : pcs.value,
            isExpanded: false,
            icon: getSvgImage(
                imagePath: Assets.assets_icon_a_arrow_down,
                width: 24.0,
                height: 24.0),
            hint: Text(
              "units",
              style: BaseStyles.secondaryHintTextStyle,
            ),
            underline: Container(),
            onChanged: (String val) {
              widget.tempItem.metric = val;
              setState(() {
                pcs.value = val;
              });
            },
            items: _getDropdownItems(),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDropdownItems() {
    return _controller.metrics.map<DropdownMenuItem<String>>((Metric value) {
      return DropdownMenuItem(
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value.name, style: TextStyles.inputFieldOn2),
            ],
          ),
        ),
        value: value.name,
      );
    }).toList();
  }
}

///Disabling the focus on text field, but still make the onTap function work
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
