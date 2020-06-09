import 'dart:io';

import 'package:chatapp/Widgets/user_image_picker.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(String email, String username, String password,
      bool isLogin, BuildContext ctx, File userImageFile) submitFn;
  final bool isLoading;
  AuthForm(this.submitFn, this.isLoading);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  var email = new TextEditingController();
  var name = new TextEditingController();
  var password = new TextEditingController();
  var _formKey = new GlobalKey<FormState>();
  String userEmail = "";
  String userName = "";
  String userPassword = "";
  File userImageFile;
  var isLogin = true;

  void pickedImage(File pickedImage) {
    userImageFile = pickedImage;
  }

  void submit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (userImageFile == null && !isLogin) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Plz pick an image."),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }
    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(userEmail.trim(), userName.trim(), userPassword, isLogin,
          context, userImageFile);
      return;
    }
  }

  String validator(String text, Function extraValidations) {
    if (text == "" || text == null) {
      return "Please fill this field";
    }
    return extraValidations();
  }

  Widget changingWidgetLoginButton() {
    if (widget.isLoading)
      return Center(child: CircularProgressIndicator());
    else
      return Column(
        children: <Widget>[
          RaisedButton(
            onPressed: submit,
            animationDuration: Duration(milliseconds: 300),
            child: Text(isLogin ? "Login" : "SignUp"),
          ),
          FlatButton(
            textColor: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                isLogin = !isLogin;
              });
            },
            child: Text(
                isLogin ? "Create new account" : "I have created an account"),
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: AnimatedContainer(
          height: isLogin ? 285 : 450,
          curve: Curves.easeIn,
          duration: Duration(milliseconds: 300),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (!isLogin)
                      UserImagePicker(
                        imagePickFn: pickedImage,
                      ),
                    TextFormField(
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      enableSuggestions: false,
                      key: ValueKey("email"),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email address",
                      ),
                      validator: (value) => validator(
                        value,
                        () {
                          RegExp exp = new RegExp(".+\@.+\..+");
                          if (!exp.hasMatch(value))
                            return "Email is not valid";
                          else
                            return null;
                        },
                      ),
                      onSaved: (value) {
                        userEmail = value;
                      },
                    ),
                    if (!isLogin)
                      TextFormField(
                        autocorrect: true,
                        textCapitalization: TextCapitalization.words,
                        enableSuggestions: false,
                        key: ValueKey("name"),
                        decoration: InputDecoration(
                          labelText: "Name",
                        ),
                        validator: (value) => validator(
                          value,
                          () {
                            RegExp exp = new RegExp(".+\b.+\b.+");
                            RegExp exp2 = new RegExp(".+\b.+");
                            if (exp.hasMatch(value) || exp2.hasMatch(value))
                              return "Please only write first name";
                            else
                              return null;
                          },
                        ),
                        onSaved: (value) {
                          userName = value;
                        },
                      ),
                    TextFormField(
                      key: ValueKey("password"),
                      decoration: InputDecoration(
                        labelText: "Password",
                      ),
                      obscureText: true,
                      validator: (value) => validator(
                        value,
                        () {
                          RegExp exp = new RegExp("(?=[A-Z])(?=[a-z])");
                          if (value.length < 8)
                            return "The password should be atleast 8 characters long";
                          else if (exp.hasMatch(value))
                            return "The password should be combination of captial and small letters.";
                          else
                            return null;
                        },
                      ),
                      onSaved: (value) {
                        userPassword = value;
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    AnimatedSwitcher(
                      child: changingWidgetLoginButton(),
                      duration: Duration(seconds: 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
