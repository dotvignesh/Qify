import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'current_user.dart';
import 'login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CurrentUser(),
      child: BotToastInit(
        child: MaterialApp(
          navigatorObservers: [BotToastNavigatorObserver()],
          //0xFFFE871E
          theme: ThemeData(

            primarySwatch: Colors.red,
          ),
          home: LoginPage(),
        ),
      ),
    );
  }
}