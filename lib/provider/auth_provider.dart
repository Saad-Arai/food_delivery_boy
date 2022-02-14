import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodie_delivery/screens/home_screen.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class AuthProvider extends ChangeNotifier {
  File image = File('image');
  bool isPicAvail = false;
  String pickerError = '';
  String error = '';
  late double shopLatitude;
  late double shopLongitude;
  String shopAddress = '';
  String placeName = '';
  String email = '';
  bool loading = false;
  CollectionReference _boys = FirebaseFirestore.instance.collection('boys');

  Future<File> getImage() async {
    final picker = ImagePicker();
    // ignore: deprecated_member_use
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'no image selected';
      print('no image selected');
      notifyListeners();
    }
    return this.image;
  }

  getEmail(email) {
    this.email = email;
    notifyListeners();
  }

  Future getCurrentAddress() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    this.shopLatitude = _locationData.latitude!;
    this.shopLongitude = _locationData.longitude!;
    notifyListeners();

    final coordinates =
        Coordinates(_locationData.latitude, _locationData.longitude);
    var _addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var shopAddress = _addresses.first;
    this.shopAddress = shopAddress.addressLine;
    this.placeName = shopAddress.featureName;
    notifyListeners();
    return shopAddress;
  }

//register vendor using email

  Future<UserCredential> registerBoys(email, password) async {
    this.email = email;
    notifyListeners();
    late UserCredential userCredential;
    try {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        error = 'The password provided is too weak.';
        notifyListeners();
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        error = 'The account already exists for that email.';
        notifyListeners();
        print('The account already exists for that email.');
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

//Login

  Future<UserCredential?> loginBoys(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

//Reset Password
  Future<void> ResetPassword(email) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .whenComplete(() {});
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      print(e);
    }
  }

//save vendor data to firestore
  Future<void> saveBoysDataToDb({
    required String url,
    required String name,
    required String mobile,
    required String password,
    context,
  }) async {
    User user = FirebaseAuth.instance.currentUser!;

    _boys.doc(this.email).update({
      'uid': user.uid,
      'name': name,
      'password': password,
      'mobile': mobile,

      'address': '${this.placeName}:${this.shopAddress}',
      'location': GeoPoint(this.shopLatitude, this.shopLongitude),
      //keep initial value false
      'imageUrl': url,
      'accVerified': false, //keep initial value false
    }).whenComplete(() {
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    });
  }
}
