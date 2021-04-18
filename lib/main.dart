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
    return Consumer<AuthRepository>(
        builder: (context, auth, _) => _build(context, auth));
  }
}

Text rowText(String text) => Text(text,
    style: TextStyle(
        fontSize: 18)); //todo: better solution for style encapsulation

class SavedSuggestionsScreen extends StatelessWidget {
  Widget _build(BuildContext context, List<String> allSaved, SavedSuggestionsRepository savedRepo){
    final tiles = allSaved.map((String suggestion) => ListTile(
          title: rowText(suggestion),
          trailing:
              Icon(Icons.delete_outline, color: Theme.of(context).primaryColor),
          onTap: () => savedRepo.remove(suggestion),
        ));
    final divided =
        ListTile.divideTiles(context: context, tiles: tiles).toList();

    return Scaffold(
        appBar: AppBar(title: Text('Saved Suggestions')),
        body: ListView(children: divided));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedSuggestionsRepository>(
        builder: (context, saved, _) => FutureBuilder(
          future: saved.getAll(),
            builder: (context, AsyncSnapshot<Set<String>> snapshot) {
              if (snapshot.hasError) {
                return _build(context, [], saved);
              }
              if (snapshot.connectionState == ConnectionState.done) {
                return _build(context, snapshot.data?.toList() ?? [], saved); //todo
              }
              return Center(child: CircularProgressIndicator());
            }));
  }
}

class AllSuggestionsScreen extends StatefulWidget {
  @override
  _AllSuggestionsScreenState createState() => _AllSuggestionsScreenState();
}

class _AllSuggestionsScreenState extends State<AllSuggestionsScreen> {
  final _suggestions = <String>[];

  Future<Widget> _rowBuilder(
      BuildContext context, int row, SavedSuggestionsRepository savedRepo) async{
    if (row.isOdd) {
      return Divider();
    }

    final int index = row ~/ 2;
    if (index >= _suggestions.length) {
      _suggestions
          .addAll(generateWordPairs().take(10).map((e) => e.asPascalCase));
    }

    final suggestion = _suggestions[index];
    bool alreadySaved = await savedRepo.isSaved(suggestion);//todo
    return ListTile(
        title: rowText(suggestion),
        trailing: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null),
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
            itemBuilder: (context, row) => FutureBuilder(
                future: _rowBuilder(context, row, savedRepo), //todo: future only the data?
                builder: (context, AsyncSnapshot<Widget> snapshot) {
                  final fillerWidget = (text) => ListTile(
                      title: rowText(text),
                      trailing: Icon(Icons.favorite_border));
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    return snapshot.data ?? fillerWidget('error loading :(');
                  }
                  return fillerWidget(" ");
                })
                ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthRepository, SavedSuggestionsRepository>(
        builder: (context, auth, saved, _) => _build(context, auth, saved));
  }
}
