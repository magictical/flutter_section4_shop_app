import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;

  final String authTokens;
  // userId for each user's items
  final String userId;

  Products(this.authTokens, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((item) => item.isFavorite).toList();
    // }
    // return copy of _item
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoriteItemsOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

// fetch data from DB
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    // send request with token
    var url =
        'https://flutter-update-97117.firebaseio.com/products.json?auth=$authTokens&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://flutter-update-97117.firebaseio.com/userFavorite/$userId.json?auth=$authTokens';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite:
              // ?? is second alternative check for favorite is null or not
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

// to use loading spinner, use Future, .then() while save data to DB

// use async and await keyword instead of .then() and .catchError
  Future<void> addProduct(Product product) async {
    // url for 'Products' in firebase
    final url =
        'https://flutter-update-97117.firebaseio.com/products.json?auth=$authTokens';
    // create product json data and post to firebase
    try {
      final response = await http.post(
        url,
        // convert product to json format
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId
        }),
      );

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        // firebase가 유니크 id를 생성하기 때문에 .then을 사용해서 그 값만
        // product의 id에 저장하고 이 id로 조건 검색해서 firebase DB에서
        // 원하는 product를 불러온다
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); //at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // save data in DB not in the memory so need to use async with http connection
  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-update-97117.firebaseio.com/products/$id.json?auth=$authTokens';
      // send http request to patch the product data that is changed only
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('Error in updating Product list');
    }
  }

  // change to async keyword
  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-update-97117.firebaseio.com/products/$id.json?auth=$authTokens';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    // delete product data in the memory
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
    // send http request to delete data
    final response = await http.delete(url);
    // check http response erorr code, if error - roll back data
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete the product.');
    }
    existingProduct = null;
  }
}
