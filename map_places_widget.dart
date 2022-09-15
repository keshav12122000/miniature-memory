// @dart=2.9
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tara_app/common/constants/assets.dart';
import 'package:tara_app/common/constants/colors.dart';
import 'package:tara_app/common/constants/strings.dart';
import 'package:tara_app/common/constants/styles.dart';
import 'package:tara_app/screens/merchant/merchant_home_screen.dart';
import 'package:tara_app/screens/base/base_state.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

const kGoogleApiKey = "AIzaSyA3MQya4H0GvCjliTfeGqNuDt6pVOcocSI";

class MapPlacesWidget extends StatefulWidget {
  final Function(String, String) addressCallback;
  MapPlacesWidget({Key key, this.addressCallback}) : super(key: key);

  @override
  _MapPlacesWidgetState createState() => new _MapPlacesWidgetState();
}

class _MapPlacesWidgetState extends BaseState<MapPlacesWidget> {
  TextEditingController _searchQuery = TextEditingController();
  String _searchText = "";
  final key = new GlobalKey<ScaffoldState>();
  List<dynamic> _placeList = [];
  var uuid = new Uuid();
  Uuid _sessionToken = new Uuid();

  @override
  BuildContext getContext() {
    // TODO: implement getContext
    return context;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
              child: _buildAppBar(context),
              preferredSize: Size.fromHeight(65.0)),
          body: SingleChildScrollView(
            child: Wrap(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        child: getTabImageWithSize(
                            Assets.ic_current_location, 24, 24),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16, right: 16),
                        child: Text(
                            getTranslation(Strings.use_current_location),
                            style: BaseStyles.backAccountHeaderTextStyle),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 4,
                        ),
                        height: 1,
                        color: AppColors.grey2,
                      ),
                    ],
                  ),
                ),
                placeListWidget()
              ],
            ),
          )),
    );
  }

  _buildAppBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12),
      child: AppBar(
        elevation: 0.8,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 24,
          ),
          onPressed: () {
            pushReplacement(MerchantHomeScreen());
          },
        ),
        title: Container(
          height: 40,
          margin: EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: new Border.all(color: Colors.grey, width: 1),
          ),
          child: TextField(
            controller: _searchQuery,
            keyboardType: TextInputType.text,
            style: BaseStyles.baseTextStyle,
            cursorColor: Colors.black,
            autofocus: false,
            onChanged: (value) {
              _searchText = value;
              if (_searchText != null &&
                  _searchText.toString().trim().isNotEmpty &&
                  _searchText.toString().trim().length > 2) {
                _onChanged();
              } else {
                if (_searchQuery.text == "") {
                  setState(() {
                    _searchText = "";
                    _searchQuery.text = "";
                  });
                }
              }
            },
            decoration: new InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Colors.black54,
                size: 20,
              ),
              fillColor: Colors.white,
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.transparent, width: 0.1)),
              hintText: getTranslation(Strings.search_location),
              hintStyle: BaseStyles.hintTextStyle,
              focusedBorder: new UnderlineInputBorder(
                  borderSide: new BorderSide(color: Colors.transparent)),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear,
                    color: (_searchText != null &&
                            _searchText.toString().isNotEmpty &&
                            _searchText.toString().length > 0)
                        ? Colors.black54
                        : Colors.transparent),
                onPressed: () {
                  setState(() {
                    _searchText = "";
                    _searchQuery.text = "";
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4().toString() as Uuid;
      });
    }
    getSuggestion(_searchQuery.text);
  }

  void getSuggestion(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/queryautocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kGoogleApiKey'; //&sessiontoken=$_sessionToken
    var response = await http.get(Uri.parse(request));
    print(response);
    if (response.statusCode == 200) {
      setState(() {
        _placeList = json.decode(response.body)['predictions'];
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  placeListWidget() {
    return _placeList.length > 0
        ? Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _placeList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: getTabImageWithSize(
                            Assets.ic_location_place, 24, 24),
                        title: Text(
                          getPlaceNameString(index),
                          style: BaseStyles.backAccountHeaderTextStyle,
                        ),
                        subtitle: Text(
                          getPlaceLocationString(index),
                          style: BaseStyles.saveToMyContactTextStyle,
                        ),
                        onTap: () {
                          widget.addressCallback(getPlaceNameString(index),
                              getPlaceLocationString(index));
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          )
        : Container();
  }

  getPlaceNameString(int index) {
    var placeName =
        (_placeList[index]["structured_formatting"]["main_text"] != null &&
                _placeList[index]["structured_formatting"]["main_text"]
                    .toString()
                    .isNotEmpty)
            ? _placeList[index]["structured_formatting"]["main_text"]
            : _placeList[index]["description"].toString().isNotEmpty
                ? _placeList[index]["description"]
                : "";

    return placeName;
  }

  getPlaceLocationString(int index) {
    var placeLocationName =
        (_placeList[index]["structured_formatting"]["secondary_text"] != null &&
                _placeList[index]["structured_formatting"]["secondary_text"]
                    .toString()
                    .isNotEmpty)
            ? _placeList[index]["structured_formatting"]["secondary_text"]
            : _placeList[index]["description"].toString().isNotEmpty
                ? _placeList[index]["description"]
                : "";

    return placeLocationName;
  }
}
