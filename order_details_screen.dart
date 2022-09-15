// @dart=2.9
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tara_app/common/constants/colors.dart';
import 'package:tara_app/common/constants/styles.dart';
import 'package:tara_app/common/widgets/handle.dart';
import 'package:tara_app/models/chat/order.dart';
import 'package:tara_app/models/order_management/orders/order_items.dart';
import '../common/widgets/extensions.dart';

class OrderDetailsScreen extends StatefulWidget {
  final List<OrderItems> orderItems;
  final num amount;

  const OrderDetailsScreen({Key key, this.orderItems, this.amount})
      : super(key: key);
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Get.width,
              decoration: BoxDecoration(
                color: AppColors.black100,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Handle(),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, top: 14, bottom: 16, right: 16),
                      child: Text(
                        'Order Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'SctoGroteskA',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: getItemsListWidget()),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    "${widget.amount.toCurrency()}",
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getItemsListWidget() {
    return ListView.separated(
      itemBuilder: (context, index) =>
          getOrderItemWidget(widget.orderItems[index]),
      itemCount: widget.orderItems.length,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) => Container(
        height: 1,
        color: AppColors.grey2,
      ),
    );
  }

  Widget getOrderItemWidget(OrderItems itemOrderModel) {
    return ListTile(
      title: Text(
        itemOrderModel.name,
        style: BaseStyles.itemOrderTextStyle,
      ),
      subtitle: Container(
        // margin: EdgeInsets.only(bottom: 8, top: 8, right: 8),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(itemOrderModel.quantity.toString(),
                style: BaseStyles.itemOrderQuantityTextStyle),
            Text(itemOrderModel.metric.toString(),
                style: BaseStyles.itemOrderQuantityTextStyle),
          ],
        ),
      ),
      trailing: Text(itemOrderModel.price.toCurrency(),
          style: BaseStyles.itemOrderQuantityTextStyle),
    );
    return Container(
        padding: EdgeInsets.all(16),
        child: Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  // margin: EdgeInsets.only(bottom: 8, top: 8, left: 8, right: 8),
                  child: Text(
                    itemOrderModel.name,
                    style: BaseStyles.itemOrderTextStyle,
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Container(
                  // margin: EdgeInsets.only(bottom: 8, top: 8, right: 8),
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(itemOrderModel.quantity.toString(),
                          style: BaseStyles.itemOrderQuantityTextStyle),
                      Text(itemOrderModel.metric.toString(),
                          style: BaseStyles.itemOrderQuantityTextStyle),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Text(itemOrderModel.price.toString(),
                  style: BaseStyles.itemOrderQuantityTextStyle),
            ],
          ),
        ));
  }
}
