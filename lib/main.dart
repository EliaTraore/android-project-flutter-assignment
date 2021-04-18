import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/saved_suggestions_repository.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/auth_repository.dart';

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
    return MaterialApp(
        title: 'Welcome to Flutter',
        theme: ThemeData(primaryColor: Colors.red),
        home: RandomWords());
  }
}

class LoginScreen extends StatelessWidget {
  Widget _build(BuildContext context, AuthRepository auth) {
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
              child: Text("Log In"),
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
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).primaryColor)))
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
    return ChangeNotifierProvider(
        create: (_) => AuthRepository.instance(),
        child: Consumer<AuthRepository>(
            builder: (context, auth, _) => _build(context, auth)));
  }
}

Text RowText(String text) => Text(text, style: TextStyle(fontSize: 18));

class SavedSuggestionsScreen extends StatelessWidget {
  Widget _build(BuildContext context, SavedSuggestions saved) {
    final tiles = saved.getAll().map((String suggestion) => ListTile(
          title: RowText(suggestion),
          trailing:
              Icon(Icons.delete_outline, color: Theme.of(context).primaryColor),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Deletion is not implemented yet"))),
        ));
    final divided =
        ListTile.divideTiles(context: context, tiles: tiles).toList();

    return Scaffold(
        appBar: AppBar(title: Text('Saved Suggestions')),
        body: ListView(children: divided));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<AuthRepository, SavedSuggestions>(
        create: (_) => SavedSuggestions(
            Provider.of<AuthRepository>(context, listen: false)),
        update: (_, currAuth, currSaved) =>
            currSaved?.updateAuth(currAuth) ?? SavedSuggestions(currAuth),
        child: Consumer<SavedSuggestions>(
            builder: (context, saved, _) => _build(context, saved)));
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <String>[];

  Widget _rowBuilder(BuildContext context, int row) {
    if (row.isOdd) {
      return Divider();
    }

    final int index = row ~/ 2;
    if (index >= _suggestions.length) {
      _suggestions.addAll(generateWordPairs().take(10).map((e) => e.asPascalCase));
    }

    // return _buildRow(_suggestions[index]);
    final suggestion = _suggestions[index];
    final alreadySaved = false; //_saved.contains(pair);
    return ListTile(
      title: RowText(suggestion),
      trailing: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("addition is not implemented yet"))), //todo: used provided
    );
  }

  Widget _build(
      BuildContext context, AuthRepository auth, SavedSuggestions saved) {
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
            padding: const EdgeInsets.all(16), itemBuilder: _rowBuilder));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthRepository.instance()),
          ChangeNotifierProxyProvider<AuthRepository, SavedSuggestions>(
              create: (_) => SavedSuggestions(
                  Provider.of<AuthRepository>(context, listen: false)),
              update: (_, currAuth, currSaved) =>
                  currSaved?.updateAuth(currAuth) ?? SavedSuggestions(currAuth))
        ],
        child: Consumer2<AuthRepository, SavedSuggestions>(
            builder: (context, auth, saved, _) =>
                _build(context, auth, saved)));
  }
}
