import 'home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

String userID = "";
String userEmail = "";
String userImage = "";
String login = "google";

class SignInPage extends StatefulWidget {
  final String title = 'Registration';
  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF91B3E7), Color(0x0091B3E7),])),
          child: Column(
            children: <Widget>[
              SizedBox(height: 150,),
              Center(child: Text("매" , style: TextStyle(fontSize: 18, color: Colors.white),)),
              SizedBox(height: 20,),
              Center(child: Text("일", style: TextStyle(fontSize: 18, color: Colors.white),)),
              SizedBox(height: 20,),
              Center(child: Text("의", style: TextStyle(fontSize: 18, color: Colors.white),)),
              SizedBox(height: 50,),
              Center(child: Text("일", style: TextStyle(fontSize: 18, color: Colors.white),)),
              SizedBox(height: 20,),
              Center(child: Text("상", style: TextStyle(fontSize: 18, color: Colors.white),)),
              SizedBox(height: 320,),
              _GoogleSignInSection(),
            ],
          ),
        )
      )
    );
  }
}

class _GoogleSignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GoogleSignInSectionState();
}

class _GoogleSignInSectionState extends State<_GoogleSignInSection> {
  bool _success;
  String _userID;
  String _userEmail;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: SizedBox(
              width: 250,
              child : RaisedButton(
                color: Color(0xFF91B3E7),
                onPressed: () async {
                  _signInWithGoogle();
                  login = "google";
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                },
                child: const Text('GOOGLE', style: TextStyle(color: Colors.white),),
              ),
            )
        ),
      ],
    );
  }

  // Example code of how to sign in with google.
  void _signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _success = true;
        userID = user.uid;
        userEmail = user.email;
        userImage = user.photoUrl;
      } else {
        _success = false;
      }
    });
  }
}

