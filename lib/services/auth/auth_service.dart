import 'dart:math'; // For generating random OTPs
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_otp/email_otp.dart';// Ensure this is correctly integrated
import 'package:uuid/uuid.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a random OTP
  String generateOTP() {
    final random = Random();
    final otp = List.generate(6, (index) => random.nextInt(10)).join();
    return otp;
  }

  Future<User?> getCurrentUser() async {
    User? user = _auth.currentUser;
    print("Current user from AuthService: ${user?.uid}"); // Add this line
    return user;
  }

  Future<void> sendEmailOTP(String email) async {
    final otp = generateOTP();
    final identifier = Uuid().v4();

    // Implement email sending using your chosen method
    bool sent = await EmailOTP.sendOTP(
      email: email,
      // Customize the method according to your EmailOTP package or replace this with your email sending logic
    );

    if (!sent) {
      throw Exception('Failed to send OTP');
    }

    // Store the OTP in Firestore temporarily (you can use more secure methods if needed)
    await _firestore.collection('otps').doc(email).set({
      'otp': otp,
      'identifier': identifier, // Store the identifier
      'createdAt': FieldValue.serverTimestamp(),
      'isUsed': false, // Initialize OTP as not used
    });
  }

  Future<void> verifyEmailOTP(String email, String enteredOtp) async {
    try {
      // Retrieve the OTP from Firestore
      final otpDoc = await _firestore.collection('otps').doc(email).get();
      final data = otpDoc.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>

      if (data == null) {
        throw Exception('No OTP found for this email');
      }

      final String storedOtp = data['otp'];
      final Timestamp createdAt = data['createdAt'];

      // Check if the OTP has expired
      final now = DateTime.now();
      final createdAtDateTime = createdAt.toDate();
      final otpAge = now.difference(createdAtDateTime).inMinutes;

      if (otpAge > 2) { // Assuming OTP validity is 2 minutes
        throw Exception('OTP expired');
      }

      // Check if the entered OTP matches the stored OTP
      if (enteredOtp!= storedOtp) {
        throw Exception('Invalid OTP');
      }

      // OTP is valid, perform the desired operation
      //...

      // Delete the OTP after successful verification
      await _firestore.collection('otps').doc(email).delete();
    } catch (e) {
      // Handle the error
      print('Error verifying OTP: $e');
    }
  }

  Future<void> signUpWithEmailPassword(String email, String password, String username) async {
    await verifyEmailOTP(email, ''); // Verify OTP before registration (removed otp parameter)

    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('Users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'email': email,
      'username': username,
    });

    // Optionally delete the OTP after successful registration
    await _firestore.collection('otps').doc(email).delete();
  }

  Future<User?> signInWithEmailPassword(String emailOrUsername, String password) async {
    try {
      if (emailOrUsername.contains('@')) {
        // Login with email
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailOrUsername,
          password: password,
        );
        return userCredential.user;
      } else {
        // Login with username
        final userDoc = await _firestore
            .collection('Users')
            .where('username', isEqualTo: emailOrUsername)
            .limit(1)
            .get();

        if (userDoc.docs.isEmpty) {
          throw Exception('No user found with this username');
        }

        final email = userDoc.docs.first['email'];
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return userCredential.user;
      }
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    final querySnapshot = await _firestore
        .collection("Users")
        .where("username", isEqualTo: username)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }
}