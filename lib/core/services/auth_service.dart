import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'log_service.dart';

class AuthService {

  static final _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<dynamic> signInWithGoogle() async {
    await _googleSignIn.signOut();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in process
        return null;
      }

      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      var result= await _auth.signInWithCredential(credential);
      return result;
    } on Exception catch (e) {
      LogService.e('exception->$e');
    }
  }

  static Future<bool> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }


  static bool isLoggedIn() {
    final User? firebaseUser = _auth.currentUser;
    return firebaseUser != null;
  }

}
