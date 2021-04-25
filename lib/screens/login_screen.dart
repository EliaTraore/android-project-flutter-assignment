import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/service_repos/auth_repository.dart';
import 'package:hello_me/service_repos/user_general_db_repository.dart';

class LoginScreen extends StatelessWidget {
  void _showSignUpInterface(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController pwdController,
      AuthRepository auth,
      UserGeneralDataRepository userData) {
    final TextEditingController verifyPwdController = TextEditingController();
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  title: Text('Please confirm your password below:'),
                ),
                Divider(),
                TextFormField(
                  decoration: InputDecoration(labelText: "Password"),
                  controller: verifyPwdController,
                ),
                ElevatedButton(
                    child: Text("Confirm"),
                    style: ElevatedButton.styleFrom(primary: Colors.teal),
                    onPressed: () async {
                      if (pwdController.text == verifyPwdController.text) {
                        final success = await auth.signUp(
                            emailController.text, pwdController.text);
                        if (success) {
                          userData.createDbEntry();
                        }
                        Navigator.of(context).pop();
                      } else {
                        log("failed verification");
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Passwords must match")));
                      }
                      Navigator.of(context).pop();
                    })
              ],
            ),
          );
        });
  }

  Widget _build(BuildContext context, AuthRepository auth,
      UserGeneralDataRepository userData) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController pwdController = TextEditingController();

    final children = [
      Text("Welcome to Startup Names Generator, please log in below",
          style: TextStyle(fontSize: 16)),
      TextFormField(
        decoration: InputDecoration(labelText: "Email"),
        controller: emailController,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: "Password"),
        controller: pwdController,
      ),
      auth.isAuthenticating
          ? LinearProgressIndicator()
          : ElevatedButton(
              child: Text("Log in"),
              onPressed: () async {
                final success =
                    await auth.signIn(emailController.text, pwdController.text);
                if (success) {
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text("There was an error logging into the app")));
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                primary: Theme.of(context).primaryColor,
              )),
      ElevatedButton(
          child: Text("New user? Click to sign up"),
          onPressed: () => _showSignUpInterface(
              context, emailController, pwdController, auth, userData),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            primary: Colors.teal,
          ))
    ];

    return Scaffold(
        appBar: AppBar(title: Text("Login")),
        body: ListView(
            padding: const EdgeInsets.all(20),
            children: children
                .map((c) =>
                    Container(margin: EdgeInsets.only(top: 15), child: c))
                .toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthRepository, UserGeneralDataRepository>(
        builder: (context, auth, userData, _) =>
            _build(context, auth, userData));
  }
}
