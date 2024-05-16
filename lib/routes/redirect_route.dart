import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_route.dart';
import 'home_route.dart';


class RedirectRoute extends StatelessWidget {
  const RedirectRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot){
          if (snapshot.hasData) {
            return const HomeRoute();
          } else if (snapshot.connectionState == ConnectionState.waiting){
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else{
            return const AuthRoute();
          }
        }
    );
  }
}
