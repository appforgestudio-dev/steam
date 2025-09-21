// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../constant/constant.dart';
//
// class ContactPage extends StatelessWidget {
//   const ContactPage({super.key});
//
//   final String phoneNumber = "+91 8220064631";
//   final String email = "v12drycleanlaundryservice@gmail.com";
//
//   Future<void> _launchPhone(BuildContext context, String number) async {
//     final Uri phoneUri = Uri(scheme: 'tel', path: number);
//     if (await canLaunchUrl(phoneUri)) {
//       await launchUrl(phoneUri);
//     } else {
//       await Clipboard.setData(ClipboardData(text: number));
//       _showSnackBar(context, "Phone number copied to clipboard");
//     }
//   }
//
//   Future<void> _launchEmail(BuildContext context, String email) async {
//     final Uri emailUri = Uri(
//       scheme: 'mailto',
//       path: email,
//       query: Uri.encodeFull("subject=Support Request&body=Hi, I need help with..."),
//     );
//     if (await canLaunchUrl(emailUri)) {
//       await launchUrl(emailUri);
//     } else {
//       await Clipboard.setData(ClipboardData(text: email));
//       _showSnackBar(context, "Email copied to clipboard");
//     }
//   }
//
//   void _showSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.green),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Contact Us", style: TextStyle(color: Colors.white)),
//         backgroundColor: bgColorPink,
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
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Need help? We're here for you.",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 24),
//
//             // 📞 Phone Card
//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.phone, color: bgColorPink),
//                 title: Text(phoneNumber),
//                 subtitle: const Text("Tap to call or copy"),
//                 onTap: () => _launchPhone(context, phoneNumber),
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // 📧 Email Card
//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.email, color: bgColorPink),
//                 title: Text(email),
//                 subtitle: const Text("Tap to email or copy"),
//                 onTap: () => _launchEmail(context, email),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant/constant.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  final String phoneNumber = "+91 8220064631";
  final String email = "v12drycleanlaundryservice@gmail.com";

  Future<void> _launchPhone(BuildContext context, String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      await Clipboard.setData(ClipboardData(text: number));
      _showSnackBar(context, "Phone number copied to clipboard");
    }
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull("subject=Support Request&body=Hi, I need help with..."),
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      await Clipboard.setData(ClipboardData(text: email));
      _showSnackBar(context, "Email copied to clipboard");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // Mobile-specific layout
  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Need help? We're here for you.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // 📞 Phone Card
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone, color: bgColorPink),
              title: Text(phoneNumber),
              subtitle: const Text("Tap to call or copy"),
              onTap: () => _launchPhone(context, phoneNumber),
            ),
          ),

          const SizedBox(height: 12),

          // 📧 Email Card
          Card(
            child: ListTile(
              leading: const Icon(Icons.email, color: bgColorPink),
              title: Text(email),
              subtitle: const Text("Tap to email or copy"),
              onTap: () => _launchEmail(context, email),
            ),
          ),
        ],
      ),
    );
  }

  // Web-specific layout
  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Need help? We're here for you.",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 📞 Phone Card
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: const Icon(Icons.phone, color: bgColorPink, size: 28),
                  title: Text(
                    phoneNumber,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text("Tap to call or copy"),
                  onTap: () => _launchPhone(context, phoneNumber),
                ),
              ),

              const SizedBox(height: 24),

              // 📧 Email Card
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: const Icon(Icons.email, color: bgColorPink, size: 28),
                  title: Text(
                    email,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text("Tap to email or copy"),
                  onTap: () => _launchEmail(context, email),
                ),
              ),
            ],
          ),
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
        title: const Text("Contact Us", style: TextStyle(color: Colors.white)),
        backgroundColor: bgColorPink,
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isMobile ? _buildMobileLayout(context) : _buildWebLayout(context),
    );
  }
}
