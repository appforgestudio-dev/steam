// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
//
// import 'package:steam/screen/MainPage.dart';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:steam/screen/HomeScreen.dart';
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//   );
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'V12 Laundry',
//       debugShowCheckedModeBanner: false,
//       home: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return HomePage();
//           } else {
//             return MainPage();
//           }
//         },
//       ),
//     );
//   }
// }




// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart'; // Required for location services
// import 'package:firebase_auth/firebase_auth.dart'; // For authentication state
// import 'package:lottie/lottie.dart';
//
// // Assuming these are your page imports
// import 'package:steam/screen/MainPage.dart'; // Your unauthenticated entry point (e.g., Login/Welcome)
// import 'package:steam/screen/HomeScreen.dart';
//
// import 'constant/constant.dart'; // Your authenticated entry point (e.g., Home screen)
// // Make sure these paths are correct relative to your main.dart file.
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Firebase. On mobile, this usually picks up configuration
//   // from google-services.json (Android) or GoogleService-Info.plist (iOS) automatically.
//   await Firebase.initializeApp();
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//
//       home: const SplashScreen(),
//     );
//   }
// }
//
// // This widget handles the Firebase Authentication state changes
// class _AuthWrapper extends StatelessWidget {
//   const _AuthWrapper({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Show a loading indicator while checking authentication status
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         } else if (snapshot.hasData) {
//           // User is signed in
//           return const HomePage(); // Navigate to your authenticated home page
//         } else {
//           // User is signed out
//           return const MainPage(); // Navigate to your login/welcome page
//         }
//       },
//     );
//   }
// }
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Run location check immediately in the background
//     _checkLocationAndNavigate();
//   }
//
//   Future<void> _checkLocationAndNavigate() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     try {
//       // 1. Check if location services are enabled on the device
//       serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         await _showEnableLocationDialog();
//         // Re-check after dialog
//         serviceEnabled = await Geolocator.isLocationServiceEnabled();
//         if (!serviceEnabled) {
//           print("Location services still disabled. Proceeding without location.");
//         }
//       }
//
//       // 2. Check and request app-specific location permission
//       permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           await _showPermissionDeniedDialog();
//           permission = await Geolocator.checkPermission();
//           if (permission == LocationPermission.denied) {
//             print("Location permission still denied. Proceeding without location.");
//           }
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         await _showPermissionPermanentlyDeniedDialog();
//         permission = await Geolocator.checkPermission();
//         if (permission == LocationPermission.deniedForever) {
//           print("Location permission permanently denied. Proceeding without location.");
//         }
//       }
//
//       // 3. If permissions are granted, try to get a position (optional accuracy check)
//       if (serviceEnabled && (permission == LocationPermission.whileInUse || permission == LocationPermission.always)) {
//         try {
//           await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//           print("Location obtained with high accuracy.");
//         } catch (e) {
//           print("Failed to get high-accuracy location or permission issue: $e");
//           await _showLocationAccuracyDialog();
//         }
//       }
//
//       // Navigate to auth wrapper regardless of location status
//       _navigateToAuthWrapper();
//     } catch (e) {
//       print("Unexpected error in _checkLocationAndNavigate: $e");
//       _navigateToAuthWrapper(); // Fallback to proceed without location
//     }
//   }
//
//   // --- Dialogs for Location Handling ---
//
//   Future<void> _showEnableLocationDialog() async {
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.grey[850],
//         title: const Text(
//           'Enable Location Service',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: const Text(
//           'Location services are disabled on your device. Please enable them to use location features in the app.',
//           style: TextStyle(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             style: TextButton.styleFrom(foregroundColor: Colors.white70),
//             onPressed: () {
//               Navigator.pop(context);
//               _checkLocationAndNavigate(); // Proceed without location
//             },
//             child: const Text('No, thanks'),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: Colors.green,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             ),
//             onPressed: () async {
//               Navigator.pop(context);
//               await Geolocator.openLocationSettings();
//               // Re-check will happen automatically on return
//             },
//             child: const Text('Turn on'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _showPermissionDeniedDialog() async {
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.grey[850],
//         title: const Text(
//           'Location Permission Required',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: const Text(
//           'This app requires location permissions to function properly. Please grant location access.',
//           style: TextStyle(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             style: TextButton.styleFrom(foregroundColor: Colors.white70),
//             onPressed: () {
//               Navigator.pop(context);
//               _checkLocationAndNavigate(); // Proceed without location
//             },
//             child: const Text('No, thanks'),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: Colors.green,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             ),
//             onPressed: () async {
//               Navigator.pop(context);
//               await Geolocator.requestPermission();
//               _checkLocationAndNavigate(); // Re-evaluate after request
//             },
//             child: const Text('Grant'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _showPermissionPermanentlyDeniedDialog() async {
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.grey[850],
//         title: const Text(
//           'Location Permission Denied',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: const Text(
//           'Location permissions are permanently denied. Please enable them from your device\'s app settings.',
//           style: TextStyle(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             style: TextButton.styleFrom(foregroundColor: Colors.white70),
//             onPressed: () {
//               Navigator.pop(context);
//               _checkLocationAndNavigate(); // Proceed without location
//             },
//             child: const Text('No, thanks'),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: Colors.green,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             ),
//             onPressed: () async {
//               Navigator.pop(context);
//               await Geolocator.openAppSettings();
//               _checkLocationAndNavigate(); // Re-evaluate after user returns
//             },
//             child: const Text('Open Settings'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _showLocationAccuracyDialog() async {
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.grey[850],
//         title: const Text(
//           'Enable Location Accuracy',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: const Text(
//           'To continue, your device will need to use Location Accuracy, which provides more accurate location for apps and services. This may use device sensors and wireless signals to improve location accuracy.',
//           style: TextStyle(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             style: TextButton.styleFrom(foregroundColor: Colors.white70),
//             onPressed: () {
//               Navigator.pop(context);
//               _checkLocationAndNavigate(); // Proceed without high accuracy
//             },
//             child: const Text('No, thanks'),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: Colors.green,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             ),
//             onPressed: () async {
//               Navigator.pop(context);
//               await Geolocator.openLocationSettings();
//               _checkLocationAndNavigate(); // Re-evaluate after user returns
//             },
//             child: const Text('Turn on'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Navigate to the main authentication wrapper
//   void _navigateToAuthWrapper() {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => const _AuthWrapper()),
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
//       body: SafeArea(
//         child: Column(
//           children: [
//             SizedBox(
//               height: screenHeight * 0.54,
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: Image.asset(
//                       "assets/images/bg.png",
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Positioned(
//                     top: screenHeight * 0.21,
//                     left: screenWidth * 0.15,
//                     right: screenWidth * 0.15,
//                     child: Lottie.asset(
//                       'assets/animations/Animation.json',
//                       width: screenWidth * 0.74,
//                       height: screenHeight * 0.3,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'V12 Dry Clean',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 27,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const Text(
//               'Laundry',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 50),
//
//             const SizedBox(height: 70),
//             const Text(
//               'At your service mate! Hold tight',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:steam/screen/MainPage.dart';
import 'package:steam/screen/HomeScreen.dart';
import 'firebase_options.dart'; // Make sure this file exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {

    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V12 Laundry',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            return const HomePage();
          } else {
            return const MainPage();
          }
        },
      ),
    );
  }
}