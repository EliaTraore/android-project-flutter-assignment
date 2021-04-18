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

import 'package:hello_me/auth_repository.dart';
import 'package:flutter/foundation.dart';


class SavedSuggestions with ChangeNotifier {
  Set _saved = <String>{};
  AuthRepository _authRepo;

  SavedSuggestions(this._authRepo);

  void add(String suggestion){}
  // void remove(String suggestion){}
  List<String> getAll(){
    return [];
  }
  // void isSaved(String suggestion){}
  // void _syncWithCloud(){}

  SavedSuggestions updateAuth(AuthRepository auth){
    return this;
  }
}