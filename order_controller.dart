// @dart=2.9
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tara_app/common/constants/strings.dart';
import 'package:tara_app/common/helpers/crypto_helper.dart';
import 'package:tara_app/common/helpers/enums.dart';
import 'package:tara_app/common/helpers/mixpanel_helper.dart';
import 'package:tara_app/common/widgets/primary_button.dart';
import 'package:tara_app/common/widgets/snackbars.dart';
import 'package:tara_app/controller/address_controller.dart';
import 'package:tara_app/controller/cart_controller.dart';
import 'package:tara_app/controller/inventory_controller.dart';
import 'package:tara_app/data/user_local_data_source.dart';
import 'package:tara_app/flavors.dart';
import 'package:tara_app/models/auth/auth_response.dart';
import 'package:tara_app/models/auth/customer_profile.dart';
import 'package:tara_app/models/core/base_response.dart';
import 'package:tara_app/models/order_management/item/metric.dart';
import 'package:tara_app/models/order_management/item/out_of_stock_item.dart';
import 'package:tara_app/models/order_management/kyc/bank_account_model.dart';
import 'package:tara_app/models/order_management/kyc/key_request.dart';
import 'package:tara_app/models/order_management/orders/order.dart' as order;
import 'package:tara_app/models/order_management/orders/order_items.dart';
import 'package:tara_app/models/order_management/orders/order_types.dart';
import 'package:tara_app/models/order_management/orders/statuses.dart';
import 'package:tara_app/models/order_management/store/industry.dart';
import 'package:tara_app/models/order_management/store/store.dart';
import 'package:tara_app/models/order_management/store/store.dart';
import 'package:tara_app/models/order_management/store/store.dart';
import 'package:tara_app/models/order_management/store/store_type_model.dart';
import 'package:tara_app/models/search/search_results.dart';
import 'package:tara_app/repositories/auth_repository.dart';
import 'package:tara_app/repositories/order_repository.dart';
import 'package:tara_app/repositories/stores_repository.dart';
import 'package:tara_app/screens/chat/chat_conversation.dart';
import 'package:tara_app/screens/consumer/Data.dart';
import 'package:tara_app/screens/consumer/transfer/bills_payment_soucres_screen.dart';
import 'package:tara_app/services/error/failure.dart';
import 'package:tara_app/models/order_management/store/store.dart';
import 'package:tara_app/models/order_management/orders/order.dart'
    as OrderModel;
import 'package:tara_app/models/order_management/orders/order_request.dart';
import 'package:tara_app/models/order_management/orders/order_response.dart';

import '../arguments.dart';
import '../injector.dart';
import '../routes.dart';

class OrderController extends GetxController {
  var showProgress = false.obs;
  var orderList = List<OrderResponse>().obs;
//  var storeTypeRes = StoreTypeResponse();
  List<StoreTypeModel> storeTypesList = [];
  var arrStores = List<Store>().obs;
  // for create order
  var items = List<OrderItems>().obs;
  var outOfStockItems = List<int>().obs;
  // for changing state of Save Item Button
  var nameTextController = TextEditingController().obs;

  var industries = List<Industry>().obs;

  var onlineOrders = List<OrderResponse>().obs;
  var totalOrder = List<OrderResponse>().obs;
  var metrics = List<Metric>().obs;

  var posOrders = List<OrderResponse>().obs;

  var searchResult = SearchResult().obs;

  var accountAdded = true.obs;

  getMetrics() async {
    showProgress.value = true;
    Either<Failure, List<Metric>> response =
        await getIt.get<OrderRepository>().getMetrics();
    response.fold((l) => print, (r) => metrics.value = r);
    showProgress.value = false;
    return response;
  }

  getIndustries() async {
    Either<Failure, List<Industry>> response =
        await getIt.get<StoresRepository>().getIndustries();
    response.fold(
        (l) => print(l.message),
        (r) => {
              industries.value = r,
            });
    return industries;
  }

  String getIndustryById(id) {
    try {
      return industries.singleWhere((t) => t.id == id).name;
    } catch (e) {
      return "";
    }
  }

  var addressController = Get.find<AddressController>();

  @override
  void onInit() {
    if (F.appFlavor == Flavor.CONSUMER)
      addressController.selectedAddress.listen((v) async {
        getAllStore(selectedIndustry.value);
      });
  } //Example to get the orders this need to be called in future builder

  Future getMerchantOrders({merchantId}) async {
    showProgress.value = true;
    var mercId = merchantId;
    if (mercId == null) {
      // only in case of merchant
      AuthResponse user = await getIt.get<UserLocalDataStore>().getUser();
      mercId = user.customerProfile.id;
    }
    Either<Failure, List<OrderResponse>> response =
        await getIt.get<OrderRepository>().getOrdersByMerchantId(mercId);
    showProgress.value = false;
    response.fold(
        (l) => print,
        (r) => {
              // posOrders.clear(),
              totalOrder.clear(),
              onlineOrders.clear(),
              r.sort((a, b) => b.orderDate.compareTo(a.orderDate)),
              r.forEach((element) {
                totalOrder.add(element);
                if (element.orderType != OrderTypes.POS) {
                  onlineOrders.add(element);
                }
              }),
              // remove pending state order on merchant side
              //     orderList.value = r.where((element) => element.status != Statuses.PENDING).toList(),
            });
  }

  Future getNonPosOrders() async {
    showProgress.value = true;
    AuthResponse user = await getIt.get<UserLocalDataStore>().getUser();
    Either<Failure, List<OrderResponse>> response = await getIt
        .get<OrderRepository>()
        .getOrdersByMerchantId(user.customerProfile.id);
    showProgress.value = false;
    response.fold(
        (l) => print,
        (r) => {
              r.forEach((element) {
                posOrders.add(element);
              }),
              orderList.value += r,
              posOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate)),
            });
  }

  Future search(String query, String storeType) async {
    showProgress.value = true;
    Either<Failure, SearchResult> response =
        await getIt.get<OrderRepository>().search(query, storeType: storeType);
    showProgress.value = false;
    response.fold((l) => print, (r) => searchResult.value = r);
  }

  Future getPOSOrders() async {
    showProgress.value = true;
    AuthResponse user = await getIt.get<UserLocalDataStore>().getUser();
    Either<Failure, List<OrderResponse>> response = await getIt
        .get<OrderRepository>()
        .getPOSOrdersByMerchantId(user.customerProfile.id);
    showProgress.value = false;
    response.fold(
        (l) => print,
        (r) => {
              // posOrders.clear(),
              // orderList.value.clear(),
              // totalOrder.clear(),
              // onlineOrders.clear(),
              // r.sort((a, b) => b.orderDate.compareTo(a.orderDate)),
              r.forEach((element) {
                posOrders.add(element);
              }),
              orderList.value += r,
              posOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate)),
            });
  }

  //Example to get the orders this need to be called in future builder
  Future getConsumerOrders({bool isFnbType}) async {
    showProgress.value = true;
    AuthResponse user =
        await getIt.get<UserLocalDataStore>().getUser(); //Get.find();
    Either<Failure, List<OrderResponse>> response = await getIt
        .get<OrderRepository>()
        .getOrdersByConsumerId(user.customerProfile.id);
    showProgress.value = false;
    response.fold((l) => print(l.message), (r) {
      List<OrderResponse> orders = [];
      if(isFnbType == null) {
        orders = r;
      }else {
        if (isFnbType)
          orders = r.where((element) => element.storeId.industry.id == 2).toList();
        else
          orders = r.where((element) => element.storeId.industry.id != 2).toList();
      }
      
      orders.sort((a, b) => a.orderDate.compareTo(b.orderDate));
      orderList.value = orders.reversed.toList();
    });
  }

  var selectedIndustry = "FMCG".obs;

  Future getAllStore(String industry) async {
    showProgress.value = true;
    selectedIndustry.value = industry;

    Either<Failure, List<Store>> response;
    response = await getIt.get<StoresRepository>().getAllStores(
        F.appFlavor == Flavor.CONSUMER ? 'merchant' : 'supplier',
        LatLng(
            double.tryParse(addressController.selectedAddress.value.latitude),
            double.tryParse(addressController.selectedAddress.value.longitude)),
        industry);
    showProgress.value = false;
    response.fold(
        (l) => print(l.message),
        (r) => {
              arrStores.value = r,
            });
  }

  Future getSuppliersStores() async {
    showProgress.value = true;
    Either<Failure, List<Store>> response =
        await getIt.get<StoresRepository>().getSuppliersStores();
    showProgress.value = false;
    response.fold((l) => print(l.message),
        (r) => {arrStores.value = r, print(r.toString())});
  }

  Future<Either<Failure, CustomerProfile>> getCustomerInfo(
      String custId) async {
    showProgress.value = true;
    Either<Failure, CustomerProfile> response =
        await getIt.get<AuthRepository>().getCustomerInfoByCustomerId(custId);
    showProgress.value = false;
//    response.fold((l) => print(l.message), (r) => {
//    });
    return response;
  }

  Future<Either<Failure, OrderResponse>> createOrder(
      OrderRequest orderReq, CustomerProfile merchantProfile,
      {bool isTypePOS = false}) async {
    showProgress.value = true;
    outOfStockItems.clear();
    loadingMessage = "Contacting merchant...";
    Either<Failure, OrderResponse> response =
        await getIt.get<OrderRepository>().createOrder(orderReq);
    showProgress.value = false;
    response.fold((l) {
      MixPanelHelper.trackEvent(MixpanelEvents.cannot_create_order,eventProperties: {
        "message":"Order cannot be created",
        "Order Id":orderReq.orderId,
        "Store Id":orderReq.storeId
      });
      Get.showSnackbar(Snackbars.errorSnackbar(l.message));
      try {
        l.response.forEach((e) {
          outOfStockItems.add(e.itemId);
        });
      } catch (e) {}
    },
        (r) => {
              //  Navigator.pop(context, false)
              // getMerchantOrders(),
          // Get.back(),

              loadingMessage = "Creating order...",

              if (isTypePOS)
                {
                  items?.clear(),
                  showProgress.value = false,
                  Get.find<CartController>().clearCart(),
                  Get.offNamed(Routes.ADD_SALES),
                  Get.showSnackbar(
                      Snackbars.productAdditionSnackbar("Order Created")),
                }
            });
    return response;
  }

  // Future<String> addBankAtTaraBackend(
  //     String bankName, String ownerName, accountNumber) async {
  //   KeyResponse r = KeyResponse.fromJson({
  //     "salt": "B5PuXWodPJZhO*%UAWoPxlh*!",
  //     "iv": "1eJpZGlwq+aLxuFS",
  //     "key": "YuVIUc5+bdVv9Z6ih6DQDQICz"
  //   });
  //   BankAccountModel accountModel = BankAccountModel(
  //       bankName: bankName,
  //       accountNumber: accountNumber,
  //       beneficiaryName: ownerName);
  //   String plainText = jsonEncode(accountModel);
  //   print("PlainText $plainText");
  //   var cipher = CryptoHelper.encryptBankDataAtTaraSide(
  //       jsonEncode(accountModel), r.key, r.salt, r.iv);
  //   var s = await cipher;
  //   var plain = CryptoHelper.decryptBankDataAtTaraSide(s, r.key, r.salt, r.iv);
  //   var sp = await plain;
  //   print("plain after dec $sp");
  // }

  Future<String> addBankAtTaraBackend(
      String bankName, String ownerName, accountNumber) async {
    showProgress.value = true;
    var inventoryController = Get.find<InventoryController>();
    Either<Failure, KeyResponse> response = await getIt
        .get<OrderRepository>()
        .getEncryptionKey(inventoryController.stores[0].id);
    response.fold((l) {
      showProgress.value = false;
      Get.showSnackbar(Snackbars.errorSnackbar(l.message));
    }, (r) async {
      BankAccountModel accountModel = BankAccountModel(
          bankName: bankName,
          accountNumber: accountNumber,
          beneficiaryName: ownerName);
      String plainText = jsonEncode(accountModel);
      print("PlainText $plainText");
      var cipher = CryptoHelper.encryptBankDataAtTaraSide(
          jsonEncode(accountModel), r.key, r.salt, r.iv);
      String s = await cipher;

      Either<Failure, BaseResponse> addBankResponse = await getIt
          .get<OrderRepository>()
          .addBank(s, inventoryController.stores[0].id);
      addBankResponse.fold(
          (l) => Get.showSnackbar(Snackbars.errorSnackbar(l.message)), (r) {
        accountAdded.value = true;
        // get the new data with accountDetailsAvailable to true
        inventoryController.getMerchantsStore();
        showProgress.value = false;
        Get.back();
        Get.showSnackbar(Snackbars.productAdditionSnackbar(r.message));
      });
      return r.key;
    });

    return null;
  }
//  Future getOrderByOrderId(String orderId) async{
//    showProgress.value = true;
//    Either<Failure,OrderModel.Order> response = await getIt.get<OrderRepository>().getOrderByOrderId(orderId);
//    showProgress.value = false;
//    response.fold((l) => print(l.message), (r) => {
////        arrItems.value = r.items,
//    });
//
//  }

  addBank() {
    showProgress.value = true;
  }

  String getStoreType(Store store) {
    var storeName = "";
    for (StoreTypeModel storeType in storeTypesList) {
      if (store.storeTypeId != null) {
        if (store.storeTypeId.contains(storeType.id)) {
          storeName = storeType.type;
        }
//        for(int id in store.storeTypeId){
//          if(id == storeType.id){
//            storeName += storeType.type.toString() + ",";
//          }
//        }
      }
    }
    return storeName;
  }
}
