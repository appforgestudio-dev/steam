// import 'package:flutter/material.dart';
// import '../constant/constant.dart';
//
// class TermsPage extends StatelessWidget {
//   const TermsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Terms & Conditions", style: TextStyle(color: Colors.white)),
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
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "User Agreement",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Text("The following Terms of Use, along with our Privacy Policy, form a legally binding agreement between V12 Dry Clean & Laundry and you, the user. These Terms define your legal rights, responsibilities, and obligations when using the V12 Dry Clean & Laundry mobile application.",
//               style: TextStyle(fontSize: 14, color: Colors.black87),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "This agreement covers:",
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "• Your access to and use of the V12 app\n"
//                   "• Our services including garment pickup/delivery, laundry, dry cleaning, and any other associated services\n"
//                   "• Any online or offline transactions conducted via the mobile application",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "By accessing or using the V12 app, registering for services, or clicking “Accept & Proceed,” you confirm that:",
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "• You are legally authorized to enter into this agreement\n"
//                   "• You agree to abide by all the Terms and Conditions outlined herein\n"
//                   "• You consent to the collection and use of your data as described in our Privacy Policy",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "If you do not agree to these terms, please do not use the app or its services. Continued use implies full acceptance of these Terms of Use.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "We reserve the right to modify these Terms at any time. Any changes will be effective upon being posted in the app. It is your responsibility to review these Terms regularly. Your continued use of the app after changes are posted constitutes your agreement to those modifications.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 24),
//             Text(
//               "Usage Restrictions & User Data",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "You agree not to reproduce, duplicate, copy, sell, resell, or exploit any portion of the V12 Dry Clean & Laundry app, its content, or its services without express written permission from us.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "Any misuse, unauthorized use, or modification of the application or its content is strictly prohibited and may result in legal action.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 16),
//             Text(
//               "User Registration & Information",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "To access and use the services of V12 Dry Clean & Laundry, users are required to register by providing accurate and up-to-date personal information including:",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "• Full Name\n• Mobile Phone Number\n• Delivery Address",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "We use this information solely for service delivery, customer communication, and order tracking. By registering, you consent to the collection and use of this data in accordance with our Privacy Policy.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 24),
//             Text(
//               "Garment Processing Disclaimer",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "All garments are processed at the customer’s risk. V12 is not responsible for issues such as color bleeding, shrinkage, damage to embellishments, or embroidery work during processing.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "If you are aware of sensitive fabrics or garments that may bleed or require special care, kindly inform our pickup executive beforehand.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "We will attempt to remove stains using the best techniques available. However, we are not liable for stains deemed unremovable by our cleaning experts.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 24),
//             Text(
//               "Pricing, Offers & Subscription",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "V12 Dry Clean & Laundry reserves the right to change pricing, offers, or service terms at any time without prior notice. Prices are subject to change based on item type, condition, or special care requirements.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "All pricing displayed in the app is indicative and may vary. It is your responsibility to review current rates before placing orders. Minimum order value may apply.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "If you are subscribed to any of our wash plans:",
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 6),
//             Text(
//               "• Unused washes are non-transferable\n"
//                   "• Wash plan validity is fixed and non-extendable\n"
//                   "• Refunds will not be issued once a subscription is activated",
//               style: TextStyle(fontSize: 14),
//
//             ),
//             SizedBox(height: 24),
//             Text(
//               "Refund & Cancellation Policy",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "Currently, V12 Dry Clean & Laundry accepts payments via Cash on Delivery (COD) for all services including Subscriptions . Online payment options will be introduced in the future, specifically for subscription-based plans.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "Once a pickup request is confirmed and the garments have been collected, the order cannot be canceled. All services are rendered on a no-refund basis after pickup is completed.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "Refunds are also not applicable to unused washes within a subscription plan. Please ensure you have reviewed your selected plan, pricing, and item details before confirming.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "We recommend contacting our support team prior to placing your order if you have any questions about our services or pricing.",
//               style: TextStyle(fontSize: 14),
//             ),
//             SizedBox(height: 24),
//
//           ]
//         )
//       )
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../constant/constant.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  static const TextStyle _bodyTextStyle = TextStyle(fontSize: 14, color: Colors.black87);
  static const TextStyle _bodyTextStyleWeb = TextStyle(fontSize: 16, color: Colors.black87);

  // Mobile layout for the terms content
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "User Agreement",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("The following Terms of Use, along with our Privacy Policy, form a legally binding agreement between V12 Dry Clean & Laundry and you, the user. These Terms define your legal rights, responsibilities, and obligations when using the V12 Dry Clean & Laundry mobile application.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 12),
          const Text(
            "This agreement covers:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "• Your access to and use of the V12 app\n"
                "• Our services including garment pickup/delivery, laundry, dry cleaning, and any other associated services\n"
                "• Any online or offline transactions conducted via the mobile application",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 12),
          const Text(
            "By accessing or using the V12 app, registering for services, or clicking “Accept & Proceed,” you confirm that:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "• You are legally authorized to enter into this agreement\n"
                "• You agree to abide by all the Terms and Conditions outlined herein\n"
                "• You consent to the collection and use of your data as described in our Privacy Policy",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 12),
          const Text(
            "If you do not agree to these terms, please do not use the app or its services. Continued use implies full acceptance of these Terms of Use.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 12),
          const Text(
            "We reserve the right to modify these Terms at any time. Any changes will be effective upon being posted in the app. It is your responsibility to review these Terms regularly. Your continued use of the app after changes are posted constitutes your agreement to those modifications.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 24),
          const Text(
            "Usage Restrictions & User Data",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,

            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "You agree not to reproduce, duplicate, copy, sell, resell, or exploit any portion of the V12 Dry Clean & Laundry app, its content, or its services without express written permission from us.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 12),
          const Text(
            "Any misuse, unauthorized use, or modification of the application or its content is strictly prohibited and may result in legal action.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 16),
          const Text(
            "User Registration & Information",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "To access and use the services of V12 Dry Clean & Laundry, users are required to register by providing accurate and up-to-date personal information including:",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            "• Full Name\n• Mobile Phone Number\n• Delivery Address",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 12),
          const Text(
            "We use this information solely for service delivery, customer communication, and order tracking. By registering, you consent to the collection and use of this data in accordance with our Privacy Policy.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 24),
          const Text(
            "Garment Processing Disclaimer",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "All garments are processed at the customer’s risk. V12 is not responsible for issues such as color bleeding, shrinkage, damage to embellishments, or embroidery work during processing.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            "If you are aware of sensitive fabrics or garments that may bleed or require special care, kindly inform our pickup executive beforehand.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            "We will attempt to remove stains using the best techniques available. However, we are not liable for stains deemed unremovable by our cleaning experts.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 24),
          const Text(
            "Pricing, Offers & Subscription",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "V12 Dry Clean & Laundry reserves the right to change pricing, offers, or service terms at any time without prior notice. Prices are subject to change based on item type, condition, or special care requirements.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            "All pricing displayed in the app is indicative and may vary. It is your responsibility to review current rates before placing orders. Minimum order value may apply.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 12),
          const Text(
            "If you are subscribed to any of our wash plans:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "• Unused washes are non-transferable\n"
                "• Wash plan validity is fixed and non-extendable\n"
                "• Refunds will not be issued once a subscription is activated",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 24),
          const Text(
            "Refund & Cancellation Policy",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Currently, V12 Dry Clean & Laundry accepts payments via Cash on Delivery (COD) for all services including Subscriptions . Online payment options will be introduced in the future, specifically for subscription-based plans.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 12),
          const Text(
            "Once a pickup request is confirmed and the garments have been collected, the order cannot be canceled. All services are rendered on a no-refund basis after pickup is completed.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            "Refunds are also not applicable to unused washes within a subscription plan. Please ensure you have reviewed your selected plan, pricing, and item details before confirming.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            "We recommend contacting our support team prior to placing your order if you have any questions about our services or pricing.",
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Web layout for the terms content
  Widget _buildWebLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "User Agreement",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text("The following Terms of Use, along with our Privacy Policy, form a legally binding agreement between V12 Dry Clean & Laundry and you, the user. These Terms define your legal rights, responsibilities, and obligations when using the V12 Dry Clean & Laundry mobile application.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 20),
              const Text(
                "This agreement covers:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "• Your access to and use of the V12 app\n"
                    "• Our services including garment pickup/delivery, laundry, dry cleaning, and any other associated services\n"
                    "• Any online or offline transactions conducted via the mobile application",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 20),
              const Text(
                "By accessing or using the V12 app, registering for services, or clicking “Accept & Proceed,” you confirm that:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "• You are legally authorized to enter into this agreement\n"
                    "• You agree to abide by all the Terms and Conditions outlined herein\n"
                    "• You consent to the collection and use of your data as described in our Privacy Policy",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 20),
              const Text(
                "If you do not agree to these terms, please do not use the app or its services. Continued use implies full acceptance of these Terms of Use.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 20),
              const Text(
                "We reserve the right to modify these Terms at any time. Any changes will be effective upon being posted in the app. It is your responsibility to review these Terms regularly. Your continued use of the app after changes are posted constitutes your agreement to those modifications.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 30),
              const Text(
                "Usage Restrictions & User Data",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "You agree not to reproduce, duplicate, copy, sell, resell, or exploit any portion of the V12 Dry Clean & Laundry app, its content, or its services without express written permission from us.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 15),
              const Text(
                "Any misuse, unauthorized use, or modification of the application or its content is strictly prohibited and may result in legal action.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 25),
              const Text(
                "User Registration & Information",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "To access and use the services of V12 Dry Clean & Laundry, users are required to register by providing accurate and up-to-date personal information including:",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 10),
              const Text(
                "• Full Name\n• Mobile Phone Number\n• Delivery Address",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 15),
              const Text(
                "We use this information solely for service delivery, customer communication, and order tracking. By registering, you consent to the collection and use of this data in accordance with our Privacy Policy.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 30),
              const Text(
                "Garment Processing Disclaimer",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "All garments are processed at the customer’s risk. V12 is not responsible for issues such as color bleeding, shrinkage, damage to embellishments, or embroidery work during processing.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 10),
              const Text(
                "If you are aware of sensitive fabrics or garments that may bleed or require special care, kindly inform our pickup executive beforehand.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 10),
              const Text(
                "We will attempt to remove stains using the best techniques available. However, we are not liable for stains deemed unremovable by our cleaning experts.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 30),
              const Text(
                "Pricing, Offers & Subscription",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "V12 Dry Clean & Laundry reserves the right to change pricing, offers, or service terms at any time without prior notice. Prices are subject to change based on item type, condition, or special care requirements.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 10),
              const Text(
                "All pricing displayed in the app is indicative and may vary. It is your responsibility to review current rates before placing orders. Minimum order value may apply.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 15),
              const Text(
                "If you are subscribed to any of our wash plans:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "• Unused washes are non-transferable\n"
                    "• Wash plan validity is fixed and non-extendable\n"
                    "• Refunds will not be issued once a subscription is activated",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 30),
              const Text(
                "Refund & Cancellation Policy",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Currently, V12 Dry Clean & Laundry accepts payments via Cash on Delivery (COD) for all services including Subscriptions . Online payment options will be introduced in the future, specifically for subscription-based plans.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 15),
              const Text(
                "Once a pickup request is confirmed and the garments have been collected, the order cannot be canceled. All services are rendered on a no-refund basis after pickup is completed.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 10),
              const Text(
                "Refunds are also not applicable to unused washes within a subscription plan. Please ensure you have reviewed your selected plan, pricing, and item details before confirming.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 10),
              const Text(
                "We recommend contacting our support team prior to placing your order if you have any questions about our services or pricing.",
                style: _bodyTextStyleWeb,
              ),
              const SizedBox(height: 30),
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
        title: const Text("Terms & Conditions", style: TextStyle(color: Colors.white)),
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
      body: SafeArea(
        child: isMobile ? _buildMobileLayout() : _buildWebLayout(),
      ),
    );
  }
}
