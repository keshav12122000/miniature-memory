// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tara_app/common/constants/values.dart';
import 'package:tara_app/common/helpers/api_keys.dart';
import 'package:tara_app/common/widgets/text_field_widget.dart';
import 'package:tara_app/common/widgets/underline_text.dart';
import 'package:tara_app/controller/address_controller.dart';
import 'package:tara_app/controller/auth_controller.dart';
import 'package:tara_app/models/auth/address.dart';
import 'package:tara_app/screens/base/base_state.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:tara_app/screens/map_screen.dart';
import '../routes.dart';
import 'address/address_dropdown.dart';
import 'maps_screen.dart';

// locality ~ city
// administrativeArea ~ state

class SignupAddress extends StatefulWidget {
  final int currentPageIndex = 3;

  @override
  _SignupAddressState createState() => _SignupAddressState();
}

class _SignupAddressState extends BaseState<SignupAddress> {
  AuthController controller = Get.find<AuthController>();
  AddressController addressController = Get.find<AddressController>();

  AddressDropdown addressDropdown = AddressDropdown();

  var address = "".obs;
  var placeMark = Placemark().obs;
  var latLng = LatLng(0, 0).obs;

  @override
  void initState() {
    controller.isEnterAllTheFields.value = false;
    // inflateAddressWithCurrentLocation(null);
    addressDropdown.setCountry("Indonesia", setState);
    super.initState();
  }

  inflateAddressWithCurrentLocation(PickResult pickResult) async {
    if (pickResult != null) {
      bool hasPostal = false;
      bool hasState = false;
      bool hasCity = false;
      bool hasCountry = false;

      pickResult.addressComponents.forEach((element) {
        print(element.toJson());
        var types = element.types;
        if (types.contains('postal_code')) {
          controller.postcodeEditController.text = element.longName;
          hasPostal = true;
        }
        if (types.contains('locality')) {
          if (!controller.citiesList.contains(element.longName)) {
            controller.citiesList.add(element.longName);
          }
          controller.city.value = element.longName;
          hasCity = true;
        }
        if (types.any((t) =>
            t == 'administrative_area' || t == "administrative_area_level_1")) {
          if (!controller.states.contains(element.longName)) {
            controller.states.add(element.longName);
          }
          controller.state.value = element.longName;
          hasState = true;
        }
        if (types.contains('country')) {
          if (!controller.countries.contains(element.longName)) {
            controller.countries.add(element.longName);
          }
          controller.country.value = element.longName;
          hasCountry = true;
        }
      });

      if (!hasState) {
        controller.state.value = null;
      }
      if (!hasCountry) {
        controller.country.value = null;
      }
      if (!hasCity) {
        controller.city.value = null;
      }
      if (!hasPostal) {
        controller.postcodeEditController.clear();
      }
      address.value = pickResult.formattedAddress;
      controller.addressEditController.text = pickResult.formattedAddress;
    } else {
      addressController.showProgress.value = true;
      try {
        latLng.value = await addressController.getCurrentLocation();
        placeMark.value =
            await addressController.getPlaceFromLatLang(latLng.value);
        address.value = addressController.getFormattedText(placeMark.value);
        if (!controller.citiesList.contains(placeMark.value.locality)) {
          controller.citiesList.add(placeMark.value.locality);
        }
        controller.city.value = placeMark.value.locality;
        if (!controller.states.contains(placeMark.value.administrativeArea)) {
          controller.states.add(placeMark.value.administrativeArea);
        }
        controller.state.value = placeMark.value.administrativeArea;
        if (!controller.countries.contains(placeMark.value.country)) {
          controller.countries.add(placeMark.value.country);
        }
        controller.country.value = placeMark.value.country;
        controller.addressEditController.text = address.value;
        controller.postcodeEditController.text = placeMark.value.postalCode;
        addressController.showProgress.value = false;
      } catch (e) {
        addressController.showProgress.value = false;
      }
    }
    controller.postcode.value = controller.postcodeEditController.text.trim();
    controller.address.value = controller.addressEditController.text.trim();
    controller.isEnterAllTheFieldsInAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(
            getTranslation(Strings.complete_profile),
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
          // ).onTap(onPressed: () => Get.offNamed(Routes.UPLOAD_IMAGE)),
          backgroundColor: AppColors.button_background_color,
          elevation: 0,
          // actions: [
          //   GestureDetector(
          //     onTap: () => Get.offNamed(Routes.CREATE_ACCOUNT_SUCCESS),
          //     child: Container(
          //       child: Center(
          //         child: Padding(
          //           padding: const EdgeInsets.only(right: 16),
          //           child: UnderlineText(
          //             text: Text(
          //               Strings.skip.toUpperCase(),
          //               style: TextStyles.bUTTONBlack2,
          //             ),
          //             underlineColours: AppColors.header_top_bar_color,
          //           ),
          //         ),
          //       ),
          //     ),
          //   )
          // ],
        ),
        backgroundColor: AppColors.white,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                widget.currentPageIndex.toString() +
                    getTranslation(Strings.page_number_index) +
                    controller.totalPagesIndex.toString(),
                style: TextStyles.inputFieldOn2,
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                getTranslation(Strings.address),
                style: TextStyles.headline52,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                getTranslation(Strings.enter_your_address),
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
                  child: Column(
                    children: [
                      // getAddressWidget(),
                      // SizedBox(
                      //   height: 16,
                      // ),
                      // Align(
                      //   child: Text(getTranslation(Strings.or)),
                      //   alignment: Alignment.centerLeft,
                      // ),
                      // SizedBox(
                      //   height: 16,
                      // ),
                      textFormFieldContainer(
                        getTranslation(Strings.address),
                        getTranslation(Strings.enter_address),
                        TextInputType.text,
                        controller.addressEditController,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      // genericDropdownWidget(Strings.country),
                      Row(
                        children: [
                          Text(getTranslation(Strings.country),
                              style:
                                  BaseStyles.textFormFieldHeaderTitleTextStyle,
                              textAlign: TextAlign.left),
                          Text(
                            " *",
                            style: TextStyles.bUTTONRed222,
                          )
                        ],
                      ),
                      addressDropdown.countryDropdown(
                          setState,
                          getTranslation(Strings.select_country),
                          getTranslation(Strings.select_country_warning)),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Text(getTranslation(Strings.state),
                              style:
                                  BaseStyles.textFormFieldHeaderTitleTextStyle,
                              textAlign: TextAlign.left),
                          addressDropdown.doesContainStates
                              ? Text(
                                  " *",
                                  style: TextStyles.bUTTONRed222,
                                )
                              : SizedBox()
                        ],
                      ),
                      addressDropdown.stateDropdown(
                          setState,
                          getTranslation(Strings.select_state),
                          getTranslation(Strings.select_state_warning)),
                      SizedBox(
                        height: 24,
                      ),
                      Row(
                        children: [
                          Text(getTranslation(Strings.city),
                              style:
                                  BaseStyles.textFormFieldHeaderTitleTextStyle,
                              textAlign: TextAlign.left),
                          addressDropdown.doesContaineCities
                              ? Text(
                                  " *",
                                  style: TextStyles.bUTTONRed222,
                                )
                              : SizedBox()
                        ],
                      ),
                      addressDropdown.cityDropdown(
                          setState,
                          getTranslation(Strings.select_city),
                          getTranslation(Strings.select_city_warning)),
                      SizedBox(
                        height: 24,
                      ),
                      textFormFieldContainer(
                        getTranslation(Strings.postcode),
                        getTranslation(Strings.enter_postcode),
                        TextInputType.number,
                        controller.postcodeEditController,
                      ),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       // child: genericDropdownWidget(Strings.city),
                      //       child: addressDropdown.cityDropdown(setState),
                      //     ),
                      //     SizedBox(
                      //       width: 8,
                      //     ),
                      //     Expanded(
                      //       child: textFormFieldContainer(
                      //         getTranslation(Strings.postcode),
                      //         getTranslation(Strings.enter_postcode),
                      //         TextInputType.number,
                      //         controller.postcodeEditController,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: 24,
                      // ),
                      // controller.errorMessage.value.isEmpty
                      //     ? Container()
                      //     : Container(
                      //         margin: EdgeInsets.only(top: 24),
                      //         child: Text(
                      //           getTranslation(controller.errorMessage.value),
                      //           style: BaseStyles.error_text_style,
                      //         ),
                      //       ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 32,
              ),
              getContinueWidget()
            ],
          ),
        ),
      ).withProgressIndicator(
          showIndicator: controller.showProgress.value ||
              addressController.showProgress.value),
    );
  }

  Widget getContinueWidget() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: controller.isEnterAllTheFields.value &&
                  addressDropdown.validatorForOnboarding()
              ? AppColors.button_background_color
              : AppColors.grey2),
      alignment: Alignment.center,
      child: Text(
        getTranslation(Strings.CONTINUE),
        textAlign: TextAlign.center,
        style: controller.isEnterAllTheFields.value &&
                addressDropdown.validatorForOnboarding()
            ? BaseStyles.contactsTextStyle
            : BaseStyles.verifyTextStyle,
      ),
    ).onTap(onPressed: () {
      var dropdownValidation = addressDropdown.validatorForOnboarding();
      if (controller.isEnterAllTheFields.value && dropdownValidation) {
        var result = addressDropdown.getValues();
        hideKeyboard();
        Address address = Address(
            name: controller.user.value.customerProfile.firstName,
            phoneNumber:
                controller.user.value.customerProfile.mobileNumber.trim(),
            // city: controller.city.value,
            city: result["city"],
            addressLineOne: controller.addressEditController.text.trim(),
            // addressLineTwo: addressLineTwoController.text.trim(),
            // state: controller.state.value,
            state: result["state"],
            // country: controller.country.value,
            country: result["country"],
            pinCode: controller.postcodeEditController.text.trim());
        address.toJson();
        addressController.addAddressForSignup(
            address, controller.postcodeEditController.text, AddressType.HOME);
      }
    });
  }

  // how is this generic? how can I pass the changing variable here(dropdownValue) :/
  Widget genericDropdownWidget(String headerTitle, {bool isMandatory = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            color: Colors.transparent,
          ),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 4, bottom: 4),
                  child: Row(
                    children: [
                      Text(getTranslation(headerTitle),
                          style: BaseStyles.textFormFieldHeaderTitleTextStyle,
                          textAlign: TextAlign.left),
                      isMandatory
                          ? Text(
                              " *",
                              style: TextStyles.bUTTONRed222,
                            )
                          : SizedBox()
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: headerTitle == Strings.city
                              ? controller.city.value
                              : headerTitle == Strings.state
                                  ? controller.state.value
                                  : controller.country.value,
                          items: (headerTitle == Strings.city
                                  ? controller.citiesList
                                  : headerTitle == Strings.state
                                      ? controller.states
                                      : controller.countries)
                              .map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.light_grey_blue))),
                          onChanged: (updatedValue) {
                            print("changling dropdown");
                            setState(() {
                              if (headerTitle == Strings.country) {
                                controller.country.value = updatedValue;
                              } else if (headerTitle == Strings.state) {
                                controller.state.value = updatedValue;
                              } else if (headerTitle == Strings.city) {
                                controller.city.value = updatedValue;
                              }
                              controller.isEnterAllTheFieldsInAddress();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  Widget textFormFieldContainer(String headerTitle, String hint,
      TextInputType inputType, TextEditingController textEditingController,
      {bool isSecureText = false,
      bool enableInteractiveSelection = false,
      placeHolderStyle: BaseStyles.subHeaderTextStyle,
      bool isMandatory = true}) {
    return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          color: Colors.transparent,
        ),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 4, bottom: 4),
                child: Row(
                  children: [
                    Text(headerTitle,
                        style: BaseStyles.textFormFieldHeaderTitleTextStyle,
                        textAlign: TextAlign.left),
                    isMandatory
                        ? Text(
                            " *",
                            style: TextStyles.bUTTONRed222,
                          )
                        : SizedBox()
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFieldWidget(
                          placeHolderStyle: placeHolderStyle,
                          enableInteractiveSelection:
                              enableInteractiveSelection,
                          isObscure: isSecureText,
                          hint: hint,
                          inputType: inputType,
                          textController: textEditingController,
                          isIcon: false,
                          onChanged: (value) {
                            onChanged(textEditingController);
                          }),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  void onChanged(TextEditingController textEditingController) {
    controller.errorMessage.value = "";
    if (textEditingController == controller.addressEditController) {
      controller.address.value = textEditingController.text;
    } else if (textEditingController == controller.postcodeEditController) {
      controller.postcode.value = textEditingController.text;
    }
    controller.isEnterAllTheFieldsInAddress();
  }

  Widget getAddressWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 4, bottom: 6),
          child: Text(getTranslation(Strings.address_optional),
              style: BaseStyles.textFormFieldHeaderTitleTextStyle,
              textAlign: TextAlign.left),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            border: Border.all(color: AppColors.grey2),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  color: AppColors.header_top_bar_color,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    address.value == null
                        ? "Something went wrong"
                        : addressController.showProgress.value
                            ? "Loading..."
                            : address.value,
                    style: TextStyles.subtitle22,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                UnderlineText(
                  text: Text(
                    getTranslation(Strings.CHANGE),
                    style: TextStyles.subtitle22,
                  ),
                  underlineColours: Color(0xff4afbc3),
                  onTap: placeMark.value == null
                      ? null
                      : () {
                          hideKeyboard();
                          push(
                            PlacePickerCustom(
                              onPlacePicked: inflateAddressWithCurrentLocation,
                              initialPosition: latLng.value,
                            ),
                          );
                        },
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  BuildContext getContext() {
    return context;
  }
}
