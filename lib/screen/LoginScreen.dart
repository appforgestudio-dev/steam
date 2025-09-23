// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:steam/constant/constant.dart';
// import 'package:steam/screen/OTPScreen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController phoneController = TextEditingController();
//   bool _isLoading = false;
//
//   void sendOTP() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     final fullPhoneNumber = "+91${phoneController.text.trim()}";
//
//     try {
//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: fullPhoneNumber,
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await FirebaseAuth.instance.signInWithCredential(credential);
//           setState(() {
//             _isLoading = false;
//           });
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           setState(() {
//             _isLoading = false;
//           });
//           _showSnackBar("Verification Failed. Please check your number or Internet", isError: true);
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           setState(() {
//             _isLoading = false;
//           });
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OtpPage(
//                 verificationId: verificationId,
//                 phoneNumber: fullPhoneNumber,
//               ),
//             ),
//           );
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           setState(() {
//             _isLoading = false;
//           });
//         },
//         timeout: const Duration(seconds: 60),
//       );
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showSnackBar("An error occurred: $e", isError: true);
//     }
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenHeight = mediaQuery.size.height;
//     final screenWidth = mediaQuery.size.width;
//
//     return Scaffold(
//       backgroundColor: bgColorPink,
//       appBar: AppBar(
//         backgroundColor: bgColorPink,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: screenHeight * 0.2),
//               const Text(
//                 'Login',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.01),
//               Image.asset('assets/images/line.png', width: screenWidth * 0.6),
//               SizedBox(height: screenHeight * 0.05),
//               TextField(
//                 controller: phoneController,
//                 style: const TextStyle(color: bgColorPink),
//                 decoration: InputDecoration(
//                   hintText: "Enter Mobile Number",
//                   hintStyle: const TextStyle(color: bgColorPink),
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: const OutlineInputBorder(
//                     borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               SizedBox(height: screenHeight * 0.04),
//               Center(
//                 child: _isLoading
//                     ? const CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 )
//                     : ElevatedButton(
//                   onPressed: sendOTP,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: const Color(0xFFA64AE2),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth * 0.36,
//                       vertical: screenHeight * 0.02,
//                     ),
//                   ),
//                   child: const Text(
//                     'Submit',
//                     style: TextStyle(
//                       color: bgColorPink,
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:steam/constant/constant.dart';
// import 'package:steam/screen/HomeScreen.dart';
// import 'package:steam/screen/OTPScreen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController phoneController = TextEditingController();
//   bool _isLoading = false;
//
//   void sendOTP() async {
//     if (_isLoading) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     final fullPhoneNumber = "+91${phoneController.text.trim()}";
//
//     try {
//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: fullPhoneNumber,
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await FirebaseAuth.instance.signInWithCredential(credential);
//           setState(() {
//             _isLoading = false;
//           });
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomePage()),
//           );
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           setState(() {
//             _isLoading = false;
//           });
//           _showSnackBar("Verification Failed: ${e.message}", isError: true);
//         },
//         codeSent: (String verificationId, int? resendToken) {
//
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OtpPage(
//                 verificationId: verificationId,
//                 phoneNumber: fullPhoneNumber,
//               ),
//             ),
//           ).then((_) {
//
//             if (mounted) {
//               setState(() {
//                 _isLoading = false;
//               });
//             }
//           });
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           setState(() {
//             _isLoading = false;
//           });
//         },
//         timeout: const Duration(seconds: 60),
//       );
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showSnackBar("An unexpected error occurred: ${e.toString()}", isError: true);
//     }
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenHeight = mediaQuery.size.height;
//     final screenWidth = mediaQuery.size.width;
//
//     return Scaffold(
//       backgroundColor: bgColorPink,
//       appBar: AppBar(
//         backgroundColor: bgColorPink,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
//           onPressed: _isLoading ? null : () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: screenHeight * 0.2),
//               const Text(
//                 'Login',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.01),
//               Image.asset('assets/images/line.png', width: screenWidth * 0.6),
//               SizedBox(height: screenHeight * 0.05),
//               TextField(
//                 controller: phoneController,
//                 style: const TextStyle(color: bgColorPink),
//                 decoration: InputDecoration(
//                   hintText: "Enter Mobile Number",
//                   hintStyle: const TextStyle(color: bgColorPink),
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: const OutlineInputBorder(
//                     borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               SizedBox(height: screenHeight * 0.04),
//               Center(
//                 child: _isLoading
//                     ? const CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 )
//                     : ElevatedButton(
//                   onPressed: _isLoading ? null : sendOTP, // Button disabled when _isLoading is true
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: const Color(0xFFA64AE2),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth * 0.36,
//                       vertical: screenHeight * 0.02,
//                     ),
//                   ),
//                   child: const Text(
//                     'Submit',
//                     style: TextStyle(
//                       color: bgColorPink,
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:steam/constant/constant.dart';
import 'package:steam/screen/HomeScreen.dart';
import 'package:steam/screen/OTPScreen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import '../sub screen/terms.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool _isLoading = false;
  late TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TermsPage()),
        );
      };
  }
  void sendOTP() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final fullPhoneNumber = "+91${phoneController.text.trim()}";

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar("Verification Failed: ${e.message}", isError: true);
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpPage(
                verificationId: verificationId,
                phoneNumber: fullPhoneNumber,
              ),
            ),
          ).then((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _isLoading = false;
          });
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("An unexpected error occurred: ${e.toString()}", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    _termsRecognizer.dispose();
    super.dispose();
  }

  Widget _buildTermsAndConditionsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            height: 1.5,
          ),
          children: <TextSpan>[
            const TextSpan(text: 'By Logging in you are accepting the '),
            TextSpan(
              text: 'Terms & Conditions',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: _termsRecognizer,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'V12 Laundry | Login',
      color: bgColorPink,
      child: Scaffold(
        backgroundColor: bgColorPink,
        appBar: kIsWeb
            ? null
            : AppBar(
          backgroundColor: bgColorPink,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: _isLoading ? null : () => Navigator.pop(context),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Use a breakpoint, for example, 800 pixels
            if (constraints.maxWidth > 800) {
              return _buildWebLayout(context);
            } else {
              return _buildMobileLayout(context);
            }
          },
        ),
      ),
    );
  }

  // This is the mobile layout widget
  Widget _buildMobileLayout(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.2),
            const Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Image.asset('assets/images/line.png', width: screenWidth * 0.6),
            SizedBox(height: screenHeight * 0.05),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: bgColorPink),
              decoration: InputDecoration(
                hintText: "Enter Mobile Number",
                hintStyle: const TextStyle(color: bgColorPink),
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20,),
            _buildTermsAndConditionsText(),
            SizedBox(height: screenHeight * 0.04),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : ElevatedButton(
                onPressed: _isLoading ? null : sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFA64AE2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.36,
                    vertical: screenHeight * 0.02,
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: bgColorPink,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This is the web layout widget
  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(40),
        child: Row(
          children: [
            // Left column with text and image
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Login to your account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/line.png',
                    width: 300,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            // Right column with form
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: phoneController,
                    style: const TextStyle(color: bgColorPink, fontSize: 24),
                    decoration: InputDecoration(
                      hintText: "Enter Mobile Number",
                      hintStyle: const TextStyle(color: bgColorPink),
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 25,
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  _buildTermsAndConditionsText(),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFA64AE2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          color: bgColorPink,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}