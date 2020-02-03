import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// use Order class only in this file
import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    // commented below to prevent infinite loof
    // final orderData = Provider.of<Orders>(context);
    // check rebuild only once or not
    print('Building Orders');

    return Scaffold(
        appBar: AppBar(
          title: Text('Your Oders'),
        ),
        drawer: AppDrawer(),
        // Use FutureBuilder, compare to product overview if want to see the diff
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, dataSnapShot) {
            if (dataSnapShot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapShot.error != null) {
                return Center(
                  child: Text('Error occurred'),
                );
              } else {
                return Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                  ),
                );
              }
            }
          },
        ));
  }
}
