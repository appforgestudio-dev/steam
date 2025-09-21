// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:steam/sub%20screen/terms.dart';
// import '../constant/constant.dart';
//
// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});
//
//   void _navigateToTerms(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const TermsPage()),
//     );
//   }
//
//   Future<void> _deleteAccount(BuildContext context) async {
//     final user = FirebaseAuth.instance.currentUser;
//
//     if (user != null && user.phoneNumber != null) {
//       final phone = user.phoneNumber!;
//       final userDocRef = FirebaseFirestore.instance.collection('users').doc(phone);
//
//       bool? confirm = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Delete Account"),
//           content: const Text("Are you sure you want to permanently delete your account?"),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text("Delete", style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         ),
//       );
//
//       if (confirm == true) {
//         try {
//           await userDocRef.delete();
//           await FirebaseAuth.instance.signOut();
//           if (context.mounted) {
//             Navigator.of(context).popUntil((route) => route.isFirst);
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Account deleted"), backgroundColor: Colors.red),
//             );
//           }
//         } catch (e) {
//           if (context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("Failed to delete account: $e"), backgroundColor: Colors.red),
//             );
//           }
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Settings", style: TextStyle(color: Colors.white)),
//         backgroundColor: bgColorPink,
//         iconTheme: const IconThemeData(color: Colors.white),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(12),
//           ),
//         ),
//       ),
//       body: ListView(
//         children: [
//           const SizedBox(height: 16),
//           ListTile(
//             leading: const Icon(Icons.article_outlined, color: bgColorPink),
//             title: const Text("Terms & Conditions"),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () => _navigateToTerms(context),
//           ),
//           const Divider(indent: 16, endIndent: 16),
//           ListTile(
//             leading: const Icon(Icons.delete_forever, color: Colors.red),
//             title: const Text(
//               "Delete This Account",
//               style: TextStyle(color: Colors.red),
//             ),
//             onTap: () => _deleteAccount(context),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../sub screen/terms.dart';
import '../constant/constant.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _navigateToTerms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsPage()),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.phoneNumber != null) {
      final phone = user.phoneNumber!;
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(phone);

      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to permanently delete your account?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        try {
          await userDocRef.delete();
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Account deleted"), backgroundColor: Colors.red),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to delete account: $e"), backgroundColor: Colors.red),
            );
          }
        }
      }
    }
  }

  // Mobile-specific layout
  Widget _buildMobileLayout(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.article_outlined, color: bgColorPink),
          title: const Text("Terms & Conditions"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _navigateToTerms(context),
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text(
            "Delete This Account",
            style: TextStyle(color: Colors.red),
          ),
          onTap: () => _deleteAccount(context),
        ),
      ],
    );
  }

  // Web-specific layout
  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          children: [
            ListTile(
              leading: const Icon(Icons.article_outlined, color: bgColorPink, size: 28),
              title: const Text("Terms & Conditions", style: TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 20),
              onTap: () => _navigateToTerms(context),
            ),
            const Divider(height: 40, thickness: 1, indent: 24, endIndent: 24),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
              title: const Text(
                "Delete This Account",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
              onTap: () => _deleteAccount(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const mobileBreakpoint = 600.0;
    final bool isMobile = screenWidth < mobileBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: bgColorPink,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      body: isMobile ? _buildMobileLayout(context) : _buildWebLayout(context),
    );
  }
}
