import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final String decsription;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.decsription,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite,
  });
}
