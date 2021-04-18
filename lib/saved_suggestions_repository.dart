import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello_me/auth_repository.dart';
import 'package:flutter/foundation.dart';


class SavedSuggestionsRepository with ChangeNotifier {
  FirebaseFirestore _firestore;
  AuthRepository _authRepo;
  final _saved = <String>{};
  final _savedDBField = 'saved_suggestions';

  SavedSuggestionsRepository(AuthRepository authRepo)
      : _firestore = FirebaseFirestore.instance,
        _authRepo = authRepo {
    updateAuth(_authRepo);
  }
  
  void add(String suggestion) async {
    addAll([suggestion]);
  }
  
  void addAll(List<String> suggestions) async {
    if (_authRepo.isAuthenticated && _authRepo.user != null) {
      _firestore
          .collection('users')
          .doc(_authRepo.user?.uid) // assumed inited because isAuthenticated
          .update({
            _savedDBField: FieldValue.arrayUnion(suggestions)
          })
          .then((value) => log('success adding $suggestions'))
          .catchError((err) => log('while adding $suggestions got error $err'));
    } else {
      _saved.addAll(suggestions);

    }
    notifyListeners();
  }

  void remove(String suggestion) async {
    if (_authRepo.isAuthenticated && _authRepo.user != null) {
      _firestore
          .collection('users')
          .doc(_authRepo.user?.uid)
          .update({
            _savedDBField: FieldValue.arrayRemove([suggestion])
          })
          .then((value) => log('success removing $suggestion'))
          .catchError(
              (err) => log('while removing $suggestion got error $err'));
    } else {
      _saved.remove(suggestion);
    }
    notifyListeners();
  }

  void toggleSelection(String suggestion) async {
    isSaved(suggestion).then((suggestionSaved) =>
        suggestionSaved ? remove(suggestion) : add(suggestion));
  }

  Future<Set<String>> getAll() async {
    if (_authRepo.isAuthenticated) {
      return _firestore
          .collection('users')
          .doc(_authRepo.user?.uid)
          .get()
          .then((snapshot) => Set<String>.from(snapshot.data()?.values.first))
          .catchError((err) => Set<String>());
    }
    return _saved;
  }

  Future<bool> isSaved(String suggestion) async {
    return getAll()
        .then((value) => value.contains(suggestion))
        .catchError((err) => false);
  }

  SavedSuggestionsRepository updateAuth(AuthRepository auth) {
    _authRepo = auth;
    if (_authRepo.isAuthenticated){
      addAll(_saved.toList());
      _saved.clear();
    }
    return this;
  }
}
