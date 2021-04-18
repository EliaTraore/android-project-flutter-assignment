/*
{uid: saved:{}, avatar: <file>}
Class suggestions : auth consumer {
_saved // set
add()
remove()
getall() // all saved
isSaved(name) //returns is contained
_sync()
// auth > !auth : removes saved
// !auth > auth : adds local saved
}
* */

import 'dart:developer';

import 'package:hello_me/auth_repository.dart';
import 'package:flutter/foundation.dart';

class SavedSuggestionsRepository with ChangeNotifier {
  final _saved = <String>{};
  AuthRepository _authRepo;

  SavedSuggestionsRepository(AuthRepository authRepo) : _authRepo = authRepo {
    log('created');
  }

  void add(String suggestion) {
    _saved.add(suggestion);
    notifyListeners();
  }

  void remove(String suggestion) {
    _saved.remove(suggestion);
    notifyListeners();
  }

  void toggleSelection(String suggestion) {
    if (isSaved(suggestion)) {
      remove(suggestion);
    } else {
      add(suggestion);
    }
  }

  Set<String> getAll() {
    return _saved;
  }

  bool isSaved(String suggestion) {
    return _saved.contains(suggestion);
  }
  // void _syncWithCloud(){}

  SavedSuggestionsRepository updateAuth(AuthRepository auth) {
    notifyListeners();

    return this;
  }
}
