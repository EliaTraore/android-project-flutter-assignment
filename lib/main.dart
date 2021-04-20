import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hello_me/service_repos/saved_suggestions_repository.dart';
import 'package:hello_me/service_repos/auth_repository.dart';
import 'package:hello_me/screens/all_suggestions_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
                body: Center(
                    child: Text(snapshot.error.toString(),
                        textDirection: TextDirection.ltr)));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return MyApp();
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthRepository.instance(),
      child: Consumer<AuthRepository>(builder: (context, auth, _) {
        return ChangeNotifierProxyProvider<AuthRepository,
            SavedSuggestionsRepository>(
          create: (_) => SavedSuggestionsRepository(
              Provider.of<AuthRepository>(context, listen: false)),
          update: (_, currAuth, currSaved) =>
              currSaved?.updateAuth(currAuth) ??
              SavedSuggestionsRepository(currAuth),
          child: MaterialApp(
              title: 'Welcome to Flutter',
              theme: ThemeData(primaryColor: Colors.red),
              home: AllSuggestionsScreen()),
        );
      }),
    );
  }
}
