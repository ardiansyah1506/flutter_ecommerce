import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({Key? key}) : super(key: key);

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  ValueNotifier<User?> userCredential = ValueNotifier<User?>(null);

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // Login canceled by user

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google user credentials
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Sign in failed: $e');
      return null;
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      print('Sign out failed: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In Screen')),
      body: ValueListenableBuilder<User?>(
        valueListenable: userCredential,
        builder: (context, user, child) {
          if (user == null) {
            // User not signed in
            return Center(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  iconSize: 40,
                  icon: Image.asset('assets/images/google_icon.png'),
                  onPressed: () async {
                    User? user = await signInWithGoogle();
                    if (user != null) {
                      userCredential.value = user;
                    }
                  },
                ),
              ),
            );
          } else {
            // User signed in
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.photoURL ?? ''),
                  ),
                  const SizedBox(height: 20),
                  Text(user.displayName ?? 'No Name',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  Text(user.email ?? 'No Email'),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      bool result = await signOutFromGoogle();
                      if (result) {
                        userCredential.value = null;
                      }
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
