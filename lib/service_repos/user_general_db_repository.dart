import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello_me/service_repos/auth_repository.dart';
import 'package:flutter/foundation.dart';

class UserGeneralDataRepository with ChangeNotifier {
  FirebaseFirestore _firestore;
  AuthRepository _authRepo;
  final _savedDBField = 'saved_suggestions';
  final _profileDBField = 'profile';
  final _avatarDBField = 'avatar';

  UserGeneralDataRepository(AuthRepository authRepo)
      : _firestore = FirebaseFirestore.instance,
        _authRepo = authRepo {
    updateAuth(_authRepo);
  }

  void createDbEntry() async {
    if (!_authRepo.isAuthenticated || _authRepo.user == null) {
      return;
    }
    _firestore
        .collection('users')
        .doc(_authRepo.user?.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) => {
              if (!documentSnapshot.exists)
                {
                  _firestore
                      .collection('users')
                      .doc(_authRepo.user?.uid)
                      .set({
                        _savedDBField: [],
                        _profileDBField: {
                          _avatarDBField: Blob(Uint8List.fromList([])) //empty image by default
                        }
                      })
                      .then((value) => log("user db created"))
                      .catchError(
                          (error) => print("Failed to update user: $error"))
                }
            });
  }

  void setAvatar() async {
    //todo:
  }

  void getAvatar() async {
    //todo:
  }

  UserGeneralDataRepository updateAuth(AuthRepository auth) {
    _authRepo = auth;
    return this;
  }
}
