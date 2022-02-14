import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:foodie_delivery/provider/auth_provider.dart';
import 'package:foodie_delivery/screens/home_screen.dart';
import 'package:foodie_delivery/screens/login_screen.dart';

import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  var _cPasswordTextController = TextEditingController();
  var _addressTextController = TextEditingController();
  var _nameTextController = TextEditingController();
  var _dialogTextController = TextEditingController();
  String email = '';
  String password = '';
  String mobile = '';
  String name = '';
  bool _isLoading = false;

  Future<String> uploadFile(filePath) async {
    File file = File(filePath);

    FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      await _storage
          .ref('boyProfilePic/${_nameTextController.text}')
          .putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    String downloadURL = await _storage
        .ref('boyProfilePic/${_nameTextController.text}')
        .getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    setState(() {
      _emailTextController.text = _authData.email;
      email = _authData.email;
    });
    scaffoldMessage(message) {
      return ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    return _isLoading
        ? CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          )
        : Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Name';
                      }
                      setState(() {
                        _nameTextController.text = value;
                      });
                      setState(() {
                        name = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                      labelText: 'Name',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Mobile Number';
                      }
                      setState(() {
                        mobile = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixText: '+92',
                      prefixIcon: Icon(Icons.phone_android),
                      labelText: 'Mobile Number',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    enabled: false,
                    controller: _emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                      labelText: 'Email',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Password';
                      }
                      if (value.length < 6) {
                        return 'minimum 6 character';
                      }
                      setState(() {
                        password = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      labelText: 'New Password',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Comfirm Password';
                      }
                      if (value.length < 6) {
                        return 'minimum 6 character';
                      }
                      if (_passwordTextController.text !=
                          _cPasswordTextController.text) {
                        return 'Password doesn\'t match';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      labelText: 'Confirm Password',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    maxLines: 5,
                    controller: _addressTextController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Press Navigation Button';
                      }
                      if (_authData.shopLatitude == null) {
                        return 'Please Press Navigation Button';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.contact_mail_outlined),
                      labelText: 'Business Location',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.location_searching),
                        onPressed: () {
                          _addressTextController.text =
                              'Locating...\n Please wait... ';
                          _authData.getCurrentAddress().then((address) {
                            if (address != null) {
                              setState(() {
                                _addressTextController.text =
                                    '${_authData.placeName}\n${_authData.shopAddress}';
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Could not find location.. Try again')));
                            }
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.deepOrangeAccent),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (_authData.isPicAvail == true) {
                            //first will validate profile picture
                            //! added
                            if (_formKey.currentState!.validate()) {
                              //then validate forms
                              setState(() {
                                _isLoading = true;
                              });
                              _authData
                                  .registerBoys(email, password)
                                  .then((credential) {
                                if (credential.user!.uid != null) {
                                  uploadFile(_authData.image.path).then((url) {
                                    // ignore: unnecessary_null_comparison
                                    if (url != null) {
                                      //save vendor details to database.

                                      _authData.saveBoysDataToDb(
                                        url: url,
                                        mobile: mobile,
                                        name: name,
                                        password: password,
                                        context: context,
                                      );

                                      setState(() {
                                        _isLoading = false;
                                      });

                                      //After finish all the process will navigate to Home Screen

                                    } else {
                                      scaffoldMessage(
                                          'Failed to upload Profile pic');
                                    }
                                  });
                                } else {
                                  //register failed
                                  scaffoldMessage(_authData.error);
                                }
                              });
                            }
                          } else {
                            scaffoldMessage('Profile pic need to be added');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      child: RichText(
                        text: TextSpan(text: '', children: [
                          TextSpan(
                              text: 'Already have an account?',
                              style: TextStyle(color: Colors.black)),
                          TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        ]),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, LoginScreen.id);
                      },
                    ),
                  ],
                )
              ],
            ),
          );
  }
}
