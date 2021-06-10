import 'package:flutter/material.dart';
import 'package:example_client/example_client.dart';
import 'package:serverpod_auth_client/module.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';

late SessionManager sessionManager;
late Client client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The session manager keeps track of the signed-in state of the user. You
  // can query it to see if the user is currently signed in and get information
  // about the user.
  sessionManager = await SessionManager.instance;

  // Sets up a singleton client object that can be used to talk to the server
  // from anywhere in our app. The client is generated from your server code.
  // The client is set up to connect to a Serverpod running on a local server on
  // the default port. You will need to modify this to connect to staging or
  // production servers.
  client = Client(
    'http://localhost:8080/',
    authenticationKeyManager: sessionManager.keyManager,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Serverpod Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // These fields hold the last result or error message that we've received from
  // the server or null if no result exists yet.
  String? _resultMessage;
  String? _errorMessage;

  final _textEditingController = TextEditingController();

  // Calls the `hello` method of the `example` endpoint. Will set either the
  // `_resultMessage` or `_errorMessage` field, depending on if the call
  // is successful.
  void _callHello() {
    client.example.hello(_textEditingController.text).then((String result) {
      setState(() {
        _resultMessage = result;
      });
    }, onError: (e) {
      setState(() {
        _errorMessage = e.message;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          UserInfoTile(
            userInfo: sessionManager.signedInUser,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: SignInWithGoogleButton(
              caller: client.modules.auth,
              onFailure: () {
                print('Failed to sign in');
                setState(() {});
              },
              onSignedIn: () {
                print('Successfully signed in');
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
              onPressed: _callHello,
              child: Text('Send to Server'),
            ),
          ),
          _ResultDisplay(
            resultMessage: _resultMessage,
            errorMessage: _errorMessage,
          ),
        ],
      ),
    );
  }
}

// _ResultDisplays shows the result of the call. Either the returned result from
// the `example.hello` endpoint method or an error message.
class _ResultDisplay extends StatelessWidget {
  final String? resultMessage;
  final String? errorMessage;
  
  _ResultDisplay({this.resultMessage, this.errorMessage,});
  
  @override
  Widget build(BuildContext context) {
    String text;
    Color backgroundColor;
    if (errorMessage != null) {
      backgroundColor = Colors.red[300]!;
      text = errorMessage!;
    }
    else if (resultMessage != null) {
      backgroundColor = Colors.green[300]!;
      text = resultMessage!;
    }
    else {
      backgroundColor = Colors.grey[300]!;
      text = 'No server response yet.';
    }
    
    return Container(
      height: 50,
      color: backgroundColor,
      child: Center(
        child: Text(text),
      ),
    );
  }
}

class UserInfoTile extends StatelessWidget {
  final UserInfo? userInfo;

  UserInfoTile({this.userInfo});

  @override
  Widget build(BuildContext context) {
    if (userInfo == null) {
      return ListTile(
        title: Text('Anonymous User'),
        subtitle: Text('Tap to sign in'),
      );
    }
    else {
      return ListTile(
        title: Text(userInfo!.userName),
        subtitle: Text(userInfo!.email ?? 'Unknown email'),
      );
    }
  }
}


