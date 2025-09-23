// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:steam/screen/LoginScreen.dart';
// import 'package:steam/constant/constant.dart';
//
// class MainPage extends StatelessWidget {
//   const MainPage({super.key});
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
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).push(PageTransition(
//                     type: PageTransitionType.fade,
//                     child: LoginScreen(),
//                   ));
//                 },
//                 child: const Text("Let's Go"),
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: bgColorPink,
//                   backgroundColor: bgColorWhite,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.3,
//                     vertical: screenHeight * 0.02,
//                   ),
//                   textStyle: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
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
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:steam/screen/LoginScreen.dart';
import 'package:steam/constant/constant.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Title(
      title: 'Welcome V12 Laundry',
      color: bgColorPink,
      child: Scaffold(
        backgroundColor: bgColorPink,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return _buildWebLayout(context);
            } else {
              return _buildMobileLayout(context);
            }
          },
        ),
      ),
    );
  }

  // Widget _buildMobileLayout(BuildContext context) {
  //   final mediaQuery = MediaQuery.of(context);
  //   final screenHeight = mediaQuery.size.height;
  //   final screenWidth = mediaQuery.size.width;
  //
  //   return SafeArea(
  //     child: Column(
  //       children: [
  //         SizedBox(
  //           height: screenHeight * 0.54,
  //           child: Stack(
  //             children: [
  //               Positioned.fill(
  //                 child: Image.asset(
  //                   "assets/images/bg.png",
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //               Positioned(
  //                 top: screenHeight * 0.21,
  //                 left: screenWidth * 0.15,
  //                 right: screenWidth * 0.15,
  //                 child: Lottie.asset(
  //                   'assets/animations/Animation.json',
  //                   width: screenWidth * 0.74,
  //                   height: screenHeight * 0.3,
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 20),
  //         const Text(
  //           'V12 Dry Clean',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 27,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const Text(
  //           'Laundry',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 24,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 50),
  //         Padding(
  //           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
  //           child: ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).push(PageTransition(
  //                 type: PageTransitionType.fade,
  //                 child: const LoginScreen(),
  //               ));
  //             },
  //             style: ElevatedButton.styleFrom(
  //               foregroundColor: bgColorPink,
  //               backgroundColor: bgColorWhite,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(30),
  //               ),
  //               padding: EdgeInsets.symmetric(
  //                 horizontal: screenWidth * 0.3,
  //                 vertical: screenHeight * 0.02,
  //               ),
  //               textStyle: const TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             child: const Text("Let's Go"),
  //           ),
  //         ),
  //         const SizedBox(height: 70),
  //         const Text(
  //           'At your service mate! Hold tight',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 16,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMobileLayout(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 450,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "assets/images/bg.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 179,
                    left: 0,
                    right: 0,
                    child: Lottie.asset(
                      'assets/animations/Animation.json',
                      height: 343,

                      fit: BoxFit.contain,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'V12 Dry Clean',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Laundry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(PageTransition(
                      type: PageTransitionType.fade,
                      child: const LoginScreen(),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: bgColorPink,
                    backgroundColor: bgColorWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text("Let's Go"),
                ),
              ),
            ),
            const SizedBox(height: 70),
            const Text(
              'At your service mate! Hold tight',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left section with text and button
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'V12 Dry Clean',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Laundry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'At your service mate! Hold tight',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 300,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(PageTransition(
                          type: PageTransitionType.fade,
                          child: const LoginScreen(),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: bgColorPink,
                        backgroundColor: bgColorWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text("Let's Go"),
                    ),
                  ),
                ],
              ),
            ),
            // Right section with animation
            Expanded(
              flex: 1,
              child: Lottie.asset(
                'assets/animations/Animation.json',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}