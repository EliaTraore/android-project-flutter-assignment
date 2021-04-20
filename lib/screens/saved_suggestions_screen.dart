import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/service_repos/saved_suggestions_repository.dart';

import '../style.dart';

class SavedSuggestionsScreen extends StatelessWidget {
  Widget _build(BuildContext context, List<String> allSaved,
      SavedSuggestionsRepository savedRepo) {
    final tiles = allSaved.map((String suggestion) => ListTile(
          title: rowText(suggestion),
          trailing:
              Icon(Icons.delete_outline, color: Theme.of(context).primaryColor),
          onTap: () => savedRepo.remove(suggestion),
        ));

    return Scaffold(
        appBar: AppBar(title: Text('Saved Suggestions')),
        body: ListView(
            children:
                ListTile.divideTiles(context: context, tiles: tiles).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedSuggestionsRepository>(
        builder: (context, saved, _) => FutureBuilder(
            future: saved.getAll(),
            builder: (context, AsyncSnapshot<Set<String>> snapshot) =>
                _build(context, snapshot.data?.toList() ?? [], saved)));
  }
}
