import 'package:flutter/material.dart';
import 'package:foodie_delivery/provider/auth_provider.dart';
import 'package:foodie_delivery/screens/login_screen.dart';
import 'package:foodie_delivery/widgets/image_picker.dart';
import 'package:foodie_delivery/widgets/register_form.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  static const String id = 'register-screen';
  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  ShopPicCard(),
                  RegisterForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
