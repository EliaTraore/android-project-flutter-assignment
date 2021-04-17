import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  final _status = 0;


  //-------------- screens creation functions --------------------------------
  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (BuildContext _context, int i) {
        if (i.isOdd) {
          return Divider();
        }
        final int index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(pair.asPascalCase, style: _biggerFont),
      trailing: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  Widget _buildSavedSuggestionsScreen(BuildContext context) {
    final tiles = _saved.map((WordPair pair) => ListTile(
          title: Text(pair.asPascalCase, style: _biggerFont),
          trailing:
              Icon(Icons.delete_outline, color: Theme.of(context).primaryColor),
          onTap: () => _unsupportedSnackBar(action: "Deletion"),
        ));
    final divided =
        ListTile.divideTiles(context: context, tiles: tiles).toList();

    return Scaffold(
        appBar: AppBar(title: Text('Saved Suggestions')),
        body: ListView(children: divided));
  }

  Widget _buildLoginScreen(BuildContext _) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController pwdController = TextEditingController();

    //temp code
    final statusQueue = [Status.Uninitialized,
      Status.Authenticating, Status.Unauthenticated,
      Status.Authenticating, Status.Authenticated];
    //temp code end

    Widget getLoginButton() {
      return ElevatedButton(
          child: Text("Log In"),
          onPressed: () =>
              _unsupportedSnackBar(action: 'Login #${emailController.text}#'),
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).primaryColor)));
    }

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
      ElevatedButton(
          child: Text("Log In"),
          onPressed: () =>
              _unsupportedSnackBar(action: 'Login #${emailController.text}#'),
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

  //-------------- general usage ---------------------------------------------
  void _pushScreen({required Function widgetBuilder}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => widgetBuilder(context)));
  }

  void _unsupportedSnackBar({required String action}) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(action + " is not implemented yet")));
  }

  //--------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Startup Name Generator'),
          actions: [
            IconButton(
                icon: Icon(Icons.list),
                onPressed: () =>
                    _pushScreen(widgetBuilder: _buildSavedSuggestionsScreen)),
            IconButton(
                icon: Icon(Icons.login),
                onPressed: () => _pushScreen(widgetBuilder: _buildLoginScreen))
          ],
        ),
        body: _buildSuggestions());
  }
}
