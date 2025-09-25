// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:sms_autofill/sms_autofill.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:steam/constant/constant.dart';
// import 'package:steam/screen/HomeScreen.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
//
// class OtpPage extends StatefulWidget {
//   final String verificationId;
//   final String phoneNumber;
//
//   const OtpPage({
//     super.key,
//     required this.verificationId,
//     required this.phoneNumber,
//   });
//
//   @override
//   _OtpPageState createState() => _OtpPageState();
// }
//
// class _OtpPageState extends State<OtpPage> {
//   final TextEditingController otpController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//   bool isLoading = false;
//   bool _showNameInput = false;
//   StreamSubscription<String>? _smsSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     if (!kIsWeb) {
//       _listenForOtp();
//     }
//   }
//
//   Future<void> _listenForOtp() async {
//     try {
//       final status = await Permission.sms.request();
//       if (status.isGranted) {
//         _smsSubscription = SmsAutoFill().code.listen((String? code) {
//           if (code != null && code.length == 6) {
//             setState(() {
//               otpController.text = code;
//             });
//             verifyOTP();
//           }
//         }, onError: (error) {
//           print("SMS listener error: $error");
//         });
//
//         await SmsAutoFill().listenForCode;
//         await SmsAutoFill().getAppSignature.then((signature) {
//           print("App signature for SMS Retriever: $signature");
//         });
//       } else {
//         _showSnackBar("SMS permissions are required for autofill.", isError: true);
//       }
//     } catch (e) {
//       print("Error initializing SMS listener: $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     _smsSubscription?.cancel();
//     if (!kIsWeb) {
//       SmsAutoFill().unregisterListener();
//     }
//     otpController.dispose();
//     nameController.dispose();
//     super.dispose();
//   }
//
//   void verifyOTP() async {
//     if (otpController.text.length != 6) {
//       _showSnackBar("Please enter a valid 6-digit OTP.", isError: true);
//       return;
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: widget.verificationId,
//         smsCode: otpController.text.trim(),
//       );
//
//       await FirebaseAuth.instance.signInWithCredential(credential);
//       await _handleUserDataAndNavigation();
//     } on FirebaseAuthException catch (e) {
//       _showSnackBar("OTP Verification Failed: ${e.message}", isError: true);
//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       _showSnackBar("An unexpected error occurred: ${e.toString()}", isError: true);
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _handleUserDataAndNavigation() async {
//     final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.phoneNumber);
//     final userDoc = await userDocRef.get();
//
//     if (userDoc.exists && (userDoc.data()?['name'] as String?)?.isNotEmpty == true) {
//       _navigateToHomePage();
//     } else {
//       setState(() {
//         _showNameInput = true;
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _saveUserName() async {
//     if (nameController.text.trim().isEmpty) {
//       _showSnackBar("Please enter your name.", isError: true);
//       return;
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.phoneNumber);
//
//       await userDocRef.set(
//         {'name': nameController.text.trim()},
//         SetOptions(merge: true),
//       );
//
//       _navigateToHomePage();
//     } catch (e) {
//       _showSnackBar("Failed to save name: ${e.toString()}", isError: true);
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   void _navigateToHomePage() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const HomePage()),
//     );
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
//     return Scaffold(
//       backgroundColor: bgColorPink,
//       appBar: kIsWeb
//           ? null
//           : AppBar(
//         backgroundColor: bgColorPink,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
//           onPressed: isLoading ? null : () => Navigator.pop(context),
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           if (constraints.maxWidth > 800) {
//             return _buildWebLayout(context);
//           } else {
//             return _buildMobileLayout(context);
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildMobileLayout(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenHeight = mediaQuery.size.height;
//     final screenWidth = mediaQuery.size.width;
//
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: screenHeight * 0.2),
//             Text(
//               _showNameInput ? 'Enter Your Name' : 'Enter OTP',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.01),
//             Image.asset('assets/images/line.png', width: screenWidth * 0.6),
//             SizedBox(height: screenHeight * 0.05),
//             _showNameInput
//                 ? Column(
//               children: [
//                 TextField(
//                   controller: nameController,
//                   style: const TextStyle(color: bgColorPink),
//                   decoration: const InputDecoration(
//                     hintText: "Your Name",
//                     hintStyle: TextStyle(color: bgColorPink),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   keyboardType: TextInputType.text,
//                 ),
//                 SizedBox(height: screenHeight * 0.04),
//                 Center(
//                   child: isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : ElevatedButton(
//                     onPressed: _saveUserName,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: const Color(0xFFA64AE2),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: screenWidth * 0.36,
//                         vertical: screenHeight * 0.02,
//                       ),
//                     ),
//                     child: const Text(
//                       'Save',
//                       style: TextStyle(
//                         color: bgColorPink,
//                         fontSize: 19,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//                 : Center(
//               child: PinFieldAutoFill(
//                 controller: otpController,
//                 codeLength: 6,
//                 decoration: BoxLooseDecoration(
//                   textStyle: const TextStyle(
//                     fontSize: 20,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   strokeColorBuilder: PinListenColorBuilder(Colors.white, Colors.green),
//                   bgColorBuilder: PinListenColorBuilder(Colors.white, Colors.white),
//                 ),
//                 onCodeChanged: (code) {
//                   if (code != null && code.length == 6) {
//                     otpController.text = code;
//                     verifyOTP();
//                   }
//                 },
//               ),
//             ),
//             if (!_showNameInput) SizedBox(height: screenHeight * 0.04),
//             if (!_showNameInput)
//               Center(
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : ElevatedButton(
//                   onPressed: verifyOTP,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: const Color(0xFFA64AE2),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth * 0.38,
//                       vertical: screenHeight * 0.02,
//                     ),
//                   ),
//                   child: const Text(
//                     'Login',
//                     style: TextStyle(
//                       color: bgColorPink,
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildWebLayout(BuildContext context) {
//     return Center(
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 1200),
//         padding: const EdgeInsets.all(40),
//         child: Row(
//           children: [
//             Expanded(
//               flex: 1,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Verification',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 48,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Image.asset(
//                     'assets/images/line.png',
//                     width: 300,
//                     fit: BoxFit.contain,
//                   ),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//             Expanded(
//               flex: 1,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     _showNameInput ? 'Enter Your Name' : 'Enter OTP',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   _showNameInput
//                       ? Column(
//                     children: [
//                       TextField(
//                         controller: nameController,
//                         style: const TextStyle(color: bgColorPink, fontSize: 24),
//                         decoration: const InputDecoration(
//                           hintText: "Your Name",
//                           hintStyle: TextStyle(color: bgColorPink),
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
//                             borderSide: BorderSide.none,
//                           ),
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 30,
//                             vertical: 25,
//                           ),
//                         ),
//                         keyboardType: TextInputType.text,
//                       ),
//                       const SizedBox(height: 30),
//                       isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _saveUserName,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: const Color(0xFFA64AE2),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 25,
//                             ),
//                           ),
//                           child: const Text(
//                             'Save',
//                             style: TextStyle(
//                               color: bgColorPink,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                       : Column(
//                     children: [
//                       TextField(
//                         controller: otpController,
//                         style: const TextStyle(color: bgColorPink, fontSize: 24),
//                         decoration: const InputDecoration(
//                           hintText: "Enter 6-digit OTP",
//                           hintStyle: TextStyle(color: bgColorPink),
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
//                             borderSide: BorderSide.none,
//                           ),
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 30,
//                             vertical: 25,
//                           ),
//                         ),
//                         keyboardType: TextInputType.number,
//                         maxLength: 6,
//                       ),
//                       const SizedBox(height: 30),
//                       isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: verifyOTP,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: const Color(0xFFA64AE2),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 25,
//                             ),
//                           ),
//                           child: const Text(
//                             'Login',
//                             style: TextStyle(
//                               color: bgColorPink,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steam/constant/constant.dart';
import 'package:steam/screen/HomeScreen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OtpPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with CodeAutoFill {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;
  bool _showNameInput = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      listenForCode();
    }
  }

  @override
  void codeUpdated() {
    setState(() {
      otpController.text = code ?? '';
      if (otpController.text.length == 6) {
        verifyOTP();
      }
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    nameController.dispose();
    // Stop listening for SMS
    if (!kIsWeb) {
      cancel();
    }
    super.dispose();
  }

  void verifyOTP() async {
    if (otpController.text.length != 6) {
      _showSnackBar("Please enter a valid 6-digit OTP.", isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await _handleUserDataAndNavigation();
    } on FirebaseAuthException catch (e) {
      _showSnackBar("OTP Verification Failed: ${e.message}", isError: true);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      _showSnackBar("An unexpected error occurred: ${e.toString()}", isError: true);
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> _handleUserDataAndNavigation() async {
  //   final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.phoneNumber);
  //   final userDoc = await userDocRef.get();
  //
  //   if (userDoc.exists && (userDoc.data()?['name'] as String?)?.isNotEmpty == true) {
  //     _navigateToHomePage();
  //   } else {
  //     setState(() {
  //       _showNameInput = true;
  //       isLoading = false;
  //     });
  //   }
  // }
  //
  // Future<void> _saveUserName() async {
  //   if (nameController.text.trim().isEmpty) {
  //     _showSnackBar("Please enter your name.", isError: true);
  //     return;
  //   }
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.phoneNumber);
  //
  //     await userDocRef.set(
  //       {'name': nameController.text.trim()},
  //       SetOptions(merge: true),
  //     );
  //
  //     _navigateToHomePage();
  //   } catch (e) {
  //     _showSnackBar("Failed to save name: ${e.toString()}", isError: true);
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
  //
  // void _navigateToHomePage() {
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => const HomePage()),
  //         (Route<dynamic> route) => false,
  //   );
  // }

  Future<void> _handleUserDataAndNavigation() async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.phoneNumber);
    try {
      final userDoc = await userDocRef.get();

      final userData = userDoc.data();
      final name = userData != null && userData.containsKey('name')
          ? (userData['name'] as String?)?.trim()
          : null;

      if (userDoc.exists && name != null && name.isNotEmpty) {
        _navigateToHomePage();
      } else {
        setState(() {
          _showNameInput = true;
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar("Error checking user data: ${e.toString()}", isError: true);
      setState(() {
        isLoading = false;
        _showNameInput = true;
      });
    }
  }

  Future<void> _saveUserName() async {
    final trimmedName = nameController.text.trim();
    if (trimmedName.isEmpty) {
      _showSnackBar("Please enter a valid name.", isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.phoneNumber);

      await userDocRef.set(
        {'name': trimmedName},
        SetOptions(merge: true),
      );

      final userDoc = await userDocRef.get();
      final savedName = userDoc.data()?['name'] as String?;
      if (savedName == null || savedName.trim().isEmpty) {
        throw Exception("Failed to verify saved name in Firestore");
      }

      _navigateToHomePage();
    } catch (e) {
      _showSnackBar("Failed to save name: ${e.toString()}", isError: true);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToHomePage() {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false,
      );
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: bgColorPink,
  //     appBar: kIsWeb
  //         ? null
  //         : AppBar(
  //       backgroundColor: bgColorPink,
  //       elevation: 0,
  //       leading: IconButton(
  //         icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
  //         onPressed: isLoading ? null : () => Navigator.pop(context),
  //       ),
  //     ),
  //     body: LayoutBuilder(
  //       builder: (context, constraints) {
  //         if (constraints.maxWidth > 800) {
  //           return _buildWebLayout(context);
  //         } else {
  //           return _buildMobileLayout(context);
  //         }
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'OTP Verification - V12 Laundry',
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
            onPressed: isLoading ? null : () => Navigator.pop(context),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
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

  Widget _buildMobileLayout(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.2),
              Text(
                _showNameInput ? 'Enter Your Name' : 'Enter OTP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Image.asset('assets/images/line.png', width: screenWidth * 0.6),
              SizedBox(height: screenHeight * 0.05),
              _showNameInput
                  ? Column(
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: bgColorPink),
                    decoration: const InputDecoration(
                      hintText: "Your Name",
                      hintStyle: TextStyle(color: bgColorPink),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Center(
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                      onPressed: _saveUserName,
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
                        'Save',
                        style: TextStyle(
                          color: bgColorPink,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : Center(
                child: PinFieldAutoFill(
                  controller: otpController,
                  codeLength: 6,
                  decoration: BoxLooseDecoration(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    strokeColorBuilder: PinListenColorBuilder(Colors.white, Colors.green),
                    bgColorBuilder: PinListenColorBuilder(Colors.white, Colors.white),
                  ),
                  onCodeChanged: (code) {
                    if (code != null && code.length == 6) {
                      verifyOTP();
                    }
                  },
                ),
              ),
              if (!_showNameInput) SizedBox(height: screenHeight * 0.04),
              if (!_showNameInput)
                Center(
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                    onPressed: verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFA64AE2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.38,
                        vertical: screenHeight * 0.02,
                      ),
                    ),
                    child: const Text(
                      'Login',
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
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(40),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verification',
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
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _showNameInput ? 'Enter Your Name' : 'Enter OTP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _showNameInput
                      ? Column(
                    children: [
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: bgColorPink, fontSize: 24),
                        decoration: const InputDecoration(
                          hintText: "Your Name",
                          hintStyle: TextStyle(color: bgColorPink),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 25,
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 30),
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveUserName,
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
                            'Save',
                            style: TextStyle(
                              color: bgColorPink,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                      : Column(
                    children: [
                      TextField(
                        controller: otpController,
                        style: const TextStyle(color: bgColorPink, fontSize: 24),
                        decoration: const InputDecoration(
                          hintText: "Enter 6-digit OTP",
                          hintStyle: TextStyle(color: bgColorPink),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 25,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      const SizedBox(height: 30),
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: verifyOTP,
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
                            'Login',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}