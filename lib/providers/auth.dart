import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    // get apikey from Firebase
    final apiKey = ApiKeyStore.fireBaseKey;
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:${urlSegment}key=${apiKey}';

    final response = await http.post(
      url,
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    print(json.decode(response.body));
  }

  Future<void> signUp(String email, String password) async {
    _authenticate(email, password, 'signUp?');
  }

  Future<void> login(String email, String password) async {
    _authenticate(email, password, 'signInWithPassword?');
  }
}
