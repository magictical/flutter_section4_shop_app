import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';
import '../config.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

// geter token확인 하고 Auth 받음!
  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    // get apikey from Firebase
    final apiKey = ApiKeyStore.fireBaseKey;
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:${urlSegment}key=$apiKey';

    try {
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
      final responseData = json.decode(response.body);
      print(responseData);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      // managing auth responseData and get Auth
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      // set expiry timer when login
      autoLogout();
      // update change in <Auth> -this will trigger the Consumer<Auth> in main.dart line 38
      notifyListeners();
      // preference use async(Fufure) too
      final prefs = await SharedPreferences.getInstance();
      //get data from json data
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      // set data to prefs
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp?');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword?');
  }

  // use Future<bool> cuz need to know that login has succeeded or not
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    // get time remaining on the token
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    autoLogout();
    return true;
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void autoLogout() {
    if (_authTimer != null) {
      // reset timer before logout
      _authTimer.cancel();
    }
    // reset timer and set expiry time
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    // set timer for _expiryDate
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
