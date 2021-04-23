import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/service_repos/saved_suggestions_repository.dart';
import 'package:hello_me/screens/login_screen.dart';
import 'package:hello_me/screens/saved_suggestions_screen.dart';
import 'package:hello_me/service_repos/auth_repository.dart';

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
              return Icon(
                  alreadySaved ? Icons.favorite : Icons.favorite_border,
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
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, row) => _rowBuilder(context, row, savedRepo),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthRepository, SavedSuggestionsRepository>(
        builder: (context, auth, saved, _) => _build(context, auth, saved));
  }
}
