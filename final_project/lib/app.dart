import 'package:flutter/material.dart';

import 'signin_page.dart';


// TODO: Convert ShrineApp to stateful widget (104)
class ShrineApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      // TODO: Change home: to a Backdrop with a HomePage frontLayer (104)
      home: SignInPage(),

    );
  }

}
