import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:hello_me/service_repos/auth_repository.dart';
import 'package:hello_me/service_repos/user_general_db_repository.dart';
import 'package:hello_me/service_repos/saved_suggestions_repository.dart';
import 'package:hello_me/screens/login_screen.dart';
import 'package:hello_me/screens/saved_suggestions_screen.dart';

import '../style.dart';

class AllSuggestionsScreen extends StatefulWidget {
  @override
  _AllSuggestionsScreenState createState() => _AllSuggestionsScreenState();
}

class _AllSuggestionsScreenState extends State<AllSuggestionsScreen> {
  final _suggestions = <String>[];

  Widget _rowBuilder(
      BuildContext context, int row, SavedSuggestionsRepository savedRepo) {
    if (row.isOdd) {
      return Divider();
    }

    final int index = row ~/ 2;
    if (index >= _suggestions.length) {
      _suggestions
          .addAll(generateWordPairs().take(10).map((e) => e.asPascalCase));
    }

    final suggestion = _suggestions[index];
    return ListTile(
        title: rowText(suggestion),
        trailing: FutureBuilder(
            future: savedRepo.isSaved(suggestion),
            builder: (context, AsyncSnapshot<bool> snapshot) {
              final alreadySaved = snapshot.data ?? false;
              return Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
                  color: alreadySaved ? Colors.red : null);
            }),
        onTap: () => savedRepo.toggleSelection(suggestion));
  }

  Widget _build(BuildContext context, AuthRepository auth,
      SavedSuggestionsRepository savedRepo) {
    var actions = [
      IconButton(
          icon: Icon(Icons.list),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SavedSuggestionsScreen().build(context))))
    ];

    actions.add(auth.isAuthenticated
        ? IconButton(icon: Icon(Icons.exit_to_app), onPressed: auth.signOut)
        : IconButton(
            icon: Icon(Icons.login),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LoginScreen().build(context)))));

    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: actions,
      ),
      body: LoggedInBottomSheet(
        child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, row) =>
                _rowBuilder(context, row, savedRepo)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthRepository, SavedSuggestionsRepository>(
        builder: (context, auth, saved, _) => _build(context, auth, saved));
  }
}

class LoggedInBottomSheet extends StatelessWidget {
  LoggedInBottomSheet({required this.child});
  final Widget child;

  Future<void> _setNewAvatar(
      BuildContext context, UserGeneralDataRepository userData) async {
    log("tried to change avatar");
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No image selected")));
    } else {
      userData.setAvatar(File(pickedFile.path));
    }
  }

  Widget getAvatar(BuildContext context, UserGeneralDataRepository userData,
      String userName) {
    return FutureBuilder(
        future: userData.getAvatar(),
        builder: (context, AsyncSnapshot<Uint8List> snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return CircleAvatar(
              foregroundImage: MemoryImage(snapshot.data!),
              radius: 40,
              backgroundColor: Colors.blueGrey[200],
            );
          }
          return CircleAvatar(
            child: Text(userName[0].toUpperCase()),
            radius: 40,
            backgroundColor: Colors.blueGrey[200],
          );
        });
  }

  Widget _build(BuildContext context, AuthRepository auth,
      UserGeneralDataRepository userData) {
    if (auth.user == null) {
      return child;
    }

    final userName = auth.user?.email ?? "WHO ARE YOUUU";
    return SnappingSheet(
      child: child,
      grabbing: Container(
        color: Colors.blueGrey[100],
        child: ListTile(
          title:
              Text('Welcome back, $userName', style: TextStyle(fontSize: 14)),
          trailing: Icon(Icons.expand_less),
        ),
      ),
      grabbingHeight: 50,
      sheetBelow: SnappingSheetContent(
          child: ColoredBox(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: getAvatar(context, userData, userName),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(userName, style: TextStyle(fontSize: 18)),
                    ),
                    ElevatedButton(
                      child: Text(
                        "Change avatar",
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.teal,
                      ),
                      onPressed: () => _setNewAvatar(context, userData),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      )),
      snappingPositions: [
        SnappingPosition.factor(
          positionFactor: 0.0,
          snappingDuration: Duration(milliseconds: 500),
          grabbingContentOffset: GrabbingContentOffset.top,
          snappingCurve: Curves.bounceOut
        ),
        SnappingPosition.factor(
          positionFactor: 0.25,
          snappingDuration: Duration(milliseconds: 500),
          snappingCurve: Curves.bounceOut
        ),
        SnappingPosition.factor(
          positionFactor: 0.9,
          snappingDuration: Duration(milliseconds: 500),
          grabbingContentOffset: GrabbingContentOffset.bottom,
          snappingCurve: Curves.easeOut

        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthRepository, UserGeneralDataRepository>(
        builder: (context, auth, userData, _) =>
            _build(context, auth, userData));
  }
}
