import 'package:flutter/material.dart';
import '../providers/product.dart';
import '../widgets/product_grid.dart';

class ProductOverviewScreen extends StatelessWidget {
  final List<Product> loadedProduct = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
      ),
      body: ProductsGrid(),
    );
  }
}
