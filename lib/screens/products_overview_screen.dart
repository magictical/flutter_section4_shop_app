import 'package:flutter/material.dart';

import '../widgets/product_grid.dart';

enum FilterName { Favorites, All }

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterName selectedValue) {
              setState(() {
                if (selectedValue == FilterName.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterName.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterName.All,
              ),
            ],
          ),
        ],
      ),
      body: ProductsGrid(_showOnlyFavorites),
    );
  }
}
