// @dart=2.9
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tara_app/common/constants/phone_code.dart';
import 'package:tara_app/common/widgets/snackbars.dart';
import 'package:tara_app/controller/home_controller.dart';
import 'package:tara_app/controller/inventory_controller.dart';
import 'package:tara_app/controller/order_controller.dart';
import 'package:tara_app/flavors.dart';
import 'package:tara_app/models/auth/customer_profile.dart';
import 'package:tara_app/models/merchant_table.dart';
import 'package:tara_app/models/order_management/catalogue_category/catalogue.dart';
import 'package:tara_app/models/order_management/item/item.dart';
import 'package:tara_app/models/order_management/store/banner_data.dart';
import 'package:tara_app/models/order_management/store/staff/staff.dart';
import 'package:tara_app/models/order_management/store/store.dart';
import 'package:tara_app/models/order_management/store/store_type_model.dart';
import 'package:tara_app/repositories/auth_repository.dart';
import 'package:tara_app/services/error/failure.dart';
import 'package:tara_app/repositories/stores_repository.dart';
import '../injector.dart';
import 'package:tara_app/repositories/order_repository.dart';
import 'package:tara_app/models/order_management/catalogue_category/category.dart';

class StoreController extends GetxController {
  List<Store> arrStores;
  String merch_storeId;
  CustomerProfile merchantProfile;
  var itemsList = List<Item>().obs;
  var filteredList = List<Item>().obs;
  var bannersList = List<BannerData>().obs;
  var categoryList = List<Category>().obs;
  var catalogues = List<Catalogue>().obs;
  var merchantTables = List<MerchantTable>().obs;
  var staff = List<Staff>().obs;
  var catalogueId = "".obs;
  var showProgress = false.obs;
  var itemsFetched = false.obs;

  List<Item> filteredItemsList = [];

  setMerchant(num merchantId) async {
    Either<Failure, CustomerProfile> response = await getIt
        .get<AuthRepository>()
        .getCustomerInfoByCustomerId(merchantId.toString());
    response.fold((l) => print(l.message), (r) => {merchantProfile = r});
  }

  Future getAllStoreTypes() async {
    Either<Failure, List<StoreTypeModel>> response =
        await getIt.get<StoresRepository>().getStoreTypes();
    response.fold(
        (l) => print(l.message),
        (r) => {
              Get.put(r),
            });
  }

  Future getAllStore(LatLng latLng, String industry) async {
    showProgress.value = true;
    Either<Failure, List<Store>> response = await getIt
        .get<StoresRepository>()
        .getAllStores("merchant", latLng, industry);
    response.fold(
        (l) => {print(l.message), showProgress.value = false},
        (r) => {
              arrStores = r,
              // fnbStoresList = r.where((element) => element.industry.id == 2).toList().reversed.toList(),
              showProgress.value = false
            });
  }

  Future getSuppliersStores() async {
    Either<Failure, List<Store>> response =
        await getIt.get<StoresRepository>().getSuppliersStores();
    response.fold(
        (l) => print(l.message),
        (r) => {
              print(r.toString()),
              arrStores = r,
            });
  }

  Future getCategories({Function implement}) async {
    showProgress.value = true;
    var response = await getIt.get<OrderRepository>().getCategories();
    if (response.isRight()) {
      response.getOrElse(() => null);
    }
    response.fold((l) => {print(l.message), showProgress.value = false}, (r) {
      if (F.appFlavor == Flavor.CONSUMER) {
        categoryList.clear();
        categoryList.add(Category(name: "All", id: -1));
        categoryList.value.addAll(r);
      } else {
        categoryList.value = r;
        implement(categoryList.value);
      }
      print(r);
      filteredList.value = itemsList.toList();
      showProgress.value = false;
    });
    return response;
  }

  Future<int> getMerchantTables() async {
    showProgress.value = true;

    await Get.find<InventoryController>().getMerchantsStore();
    if(Get.find<InventoryController>().stores.value.first.storeTablesList != null)
    {
      merchantTables.value=Get.find<InventoryController>().stores.value.first.storeTablesList;
    }
    else
    {
      merchantTables.value=[];
    }
    showProgress.value = false;
    return 1;
  }

  createMerchantTable(MerchantTable table) async {
    merchantTables.value.add(table);
    showProgress.value = true;
    var response = await getIt.get<StoresRepository>().createTable(merchantTables.value, Get.find<InventoryController>().stores[0].id);
    response.fold(
      (l) => null,
      (r) async {
        await getMerchantTables();
        Get.back();
        showProgress.value = false;
        Get.showSnackbar(Snackbars.successSnackbarDark("table added successfully"));
      }
    );
  }

  deleteMerchantTable(MerchantTable table) async {
    merchantTables.value.remove(table);
    showProgress.value = true;
    var response = await getIt.get<StoresRepository>().createTable(merchantTables.value, Get.find<InventoryController>().stores[0].id);
    response.fold(
      (l) => null,
      (r) async {
        await getMerchantTables();
        Get.back();
        showProgress.value = false;
        Get.showSnackbar(Snackbars.successSnackbarDark("table removed successfully"));
      }
    );
  }

  void getBanners() async {
    var response = await getIt.get<OrderRepository>().getBanners("41825412");
    if (response.isRight()) {
      response.getOrElse(() => null);
    }
    response.fold(
        (l) => print(l.message),
        (r) => {
              bannersList.value = r,
              print(r),
            });
    print(response);
  }

  void getCatalogue() async {
    var response = await getIt.get<OrderRepository>().getCatalogue();
    response.fold(
        (l) => print(l.message),
        (r) => {
              catalogues.value = r,
              print(r),
            });
    print(response);
  }

  Future<Store> getStoreById(storeId) async {
    showProgress.value = true;
    var response = await getIt.get<StoresRepository>().getStore(storeId);
    showProgress.value = false;
    response.fold((l) {
      print("efefe");
      return;
    }, (r) {
      print("niniun ${r.toJson()}");
      return r;
    });
  }

  Future<bool> getItems(String storeId, {Function implement}) async {
    showProgress.value = true;
    var response =
        await getIt.get<OrderRepository>().getItemsByCatalogue(storeId);

    if (response.isRight()) {
      showProgress.value = false;
      response.getOrElse(() => null);
    }
    response.fold((l) {
      showProgress.value = false;
      itemsFetched.value = true;
      print(l.message);
      return false;
    }, (r) {
      itemsList.value = r;
      filteredItemsList = r;
      itemsFetched.value = true;
      showProgress.value = false;
      print(r);
      if (r.length >= 1) {
        setMerchant(itemsList[0].merchantId);
        merch_storeId = itemsList[0].merchantId.toString();
      }
      if(implement != null)
        implement(itemsList.value);
      return true;
    });
    print(response);
  }

  addStaffMember(String phoneNumber, {Function onInviteSent}) async {
    showProgress.value = true;

    Staff req = Staff(
        staffMobileNumber:
            "${phoneCodes['${WidgetsBinding.instance.window.locale.countryCode}']}$phoneNumber",
        storeId: Get.find<InventoryController>().stores[0].id,
        staffStatus: MerchantStaffStatus.INVITED);
    var res = await getIt.get<AuthRepository>().addStaffRequest(req);
    res.fold((l) {
      showProgress.value = false;
      Get.showSnackbar(Snackbars.errorSnackbar(l.message));
    }, (r) {
      showProgress.value = false;
      if (onInviteSent != null) {
        onInviteSent();
      }
      getStaff();
    });
  }

  updateStaff(Staff staff, MerchantStaffStatus status,
      {Function onUpdate}) async {
    showProgress.value = true;
    staff.staffStatus = status;
    var res = await getIt.get<AuthRepository>().updateStaffRequest(staff);
    res.fold((l) {
      showProgress.value = false;
      Get.showSnackbar(Snackbars.errorSnackbar(l.message));
    }, (r) {
      if (status == MerchantStaffStatus.ACCEPTED) {
        Get.find<HomeController>().haveAccessToShop.value = true;
        Get.find<OrderController>()
            .getMerchantOrders(merchantId: staff.merchantId);
      }
      showProgress.value = false;
      if (onUpdate != null) onUpdate();
    });
  }

  getStaff() async {
    showProgress.value = true;
    var res = await getIt
        .get<AuthRepository>()
        .getStaffMembers(Get.find<InventoryController>().stores[0].id);
    res.fold((l) {
      showProgress.value = false;
    }, (r) {
      staff.value.clear();
      staff.value = r;
      showProgress.value = false;
      return r;
    });
  }
}
