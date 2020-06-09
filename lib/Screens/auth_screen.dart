import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:chatapp/Widgets/auth_form.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var auth = FirebaseAuth.instance;
  var isLoading = false;
  void authFormSubmission(String email, String username, String password,
      bool isLogin, BuildContext ctx, File image) async {
    AuthResult result;
    try {
      setState(() {
        isLoading = true;
      });
      if (isLogin) {
        result = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        result = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child("${result.user.uid}.jpg");

        await ref.putFile(image).onComplete;

        final url = await ref.getDownloadURL();
        Firestore.instance
            .collection('users')
            .document(result.user.uid)
            .setData({
          'username': username,
          'email': email,
          'image_url': url,
        });
      }
    } on PlatformException catch (err) {
      var message = "Sorry an error occured";
      if (err.message != null) message = err.message;
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(authFormSubmission, isLoading),
    );
  }
}
