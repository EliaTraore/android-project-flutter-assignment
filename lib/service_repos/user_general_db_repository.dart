import 'dart:developer';
import 'dart:io';
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

  DocumentReference _getUserDoc() {
    return _firestore.collection('users').doc(_authRepo.user?.uid);
  }

  void createDbEntry() async {
    if (!_authRepo.isAuthenticated || _authRepo.user == null) {
      return;
    }
    _getUserDoc().get().then((DocumentSnapshot documentSnapshot) => {
          if (!documentSnapshot.exists)
            {
              _getUserDoc()
                  .set({
                    _savedDBField: [],
                    _profileDBField: {
                      _avatarDBField:
                          Blob(Uint8List.fromList([])) //empty image by default
                    }
                  })
                  .then((value) => log("user db created"))
                  .catchError((error) => print("Failed to update user: $error"))
            }
        });
  }

  void setAvatar(File imageFile) async {
    imageFile
        .readAsBytes()
        .then((bytes) => bytes.buffer.asUint8List())
        .then((avatar) => _getUserDoc()
            .update({'$_profileDBField.$_avatarDBField': Blob(avatar)}))
        .catchError((error) => log("failed to upload avatar"));
    notifyListeners();
  }

  Future<Uint8List> getAvatar() async {
    return _getUserDoc()
        .get()
        .then((snapshot) => Uint8List.fromList(
            snapshot.get('$_profileDBField.$_avatarDBField').bytes))
        .catchError((error) {
      log('failed to download image $error');
      return Uint8List.fromList([]);
    });
  }

  UserGeneralDataRepository updateAuth(AuthRepository auth) {
    _authRepo = auth;
    notifyListeners();
    return this;
  }
}
