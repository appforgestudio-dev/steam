// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import '../constant/constant.dart';
//
// class FeedbackPage extends StatefulWidget {
//   const FeedbackPage({super.key});
//
//   @override
//   State<FeedbackPage> createState() => _FeedbackPageState();
// }
//
// class _FeedbackPageState extends State<FeedbackPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _feedbackController = TextEditingController();
//
//   String? _userName;
//   String? _phoneNumber;
//   double _rating = 3.0;
//   String _selectedCategory = "General";
//   bool _isSubmitting = false;
//   bool _showThankYou = false;
//
//   final List<String> _categories = ["General", "Service", "Delivery", "Price", "App Experience"];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserDetails();
//   }
//
//   Future<void> _loadUserDetails() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null && user.phoneNumber != null) {
//       _phoneNumber = user.phoneNumber;
//
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(_phoneNumber)
//           .get();
//
//       if (userDoc.exists) {
//         setState(() {
//           _userName = userDoc.data()?['name'] ?? "User";
//         });
//       }
//     }
//   }
//
//   Future<void> _submitFeedback() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     if (_phoneNumber == null || _userName == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("User details missing"), backgroundColor: Colors.red),
//       );
//       return;
//     }
//
//     setState(() {
//       _isSubmitting = true;
//     });
//
//     try {
//       await FirebaseFirestore.instance.collection('feedback').add({
//         'name': _userName,
//         'phoneNumber': _phoneNumber,
//         'feedback': _feedbackController.text.trim(),
//         'rating': _rating,
//         'category': _selectedCategory,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       setState(() {
//         _showThankYou = true;
//       });
//
//       await Future.delayed(const Duration(seconds: 2));
//
//       if (context.mounted) {
//         Navigator.pop(context);
//
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to submit feedback: $e"), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       setState(() {
//         _isSubmitting = false;
//       });
//     }
//   }
//
//   Widget _buildRatingSlider() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Rating", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         Slider(
//           value: _rating,
//           min: 1.0,
//           max: 5.0,
//           divisions: 4,
//           label: _rating.toStringAsFixed(1),
//           onChanged: (value) {
//             setState(() {
//               _rating = value;
//             });
//           },
//           activeColor: bgColorPink,
//           inactiveColor: Colors.grey[300],
//         ),
//         Text(
//           _ratingDescription(_rating),
//           style: const TextStyle(fontSize: 14, color: Colors.grey),
//         ),
//       ],
//     );
//   }
//
//   String _ratingDescription(double rating) {
//     if (rating <= 1.5) return "Very Poor";
//     if (rating <= 2.5) return "Poor";
//     if (rating <= 3.5) return "Average";
//     if (rating <= 4.5) return "Good";
//     return "Excellent";
//   }
//
//   Widget _buildCategoryDropdown() {
//     return DropdownButtonFormField<String>(
//       value: _selectedCategory,
//       decoration: const InputDecoration(
//         labelText: "Feedback Category",
//         border: OutlineInputBorder(),
//       ),
//       items: _categories.map((category) {
//         return DropdownMenuItem<String>(
//           value: category,
//           child: Text(category),
//         );
//       }).toList(),
//       onChanged: (value) {
//         if (value != null) {
//           setState(() {
//             _selectedCategory = value;
//           });
//         }
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_showThankYou) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: Lottie.asset(
//             'assets/animations/thankyou.json',
//             repeat: false,
//             width: 200,
//             height: 200,
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Feedback", style: TextStyle(color: Colors.white)),
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
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               const Text(
//                 "We value your feedback!",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 24),
//
//               _buildCategoryDropdown(),
//               const SizedBox(height: 16),
//
//               TextFormField(
//                 controller: _feedbackController,
//                 decoration: const InputDecoration(
//                   labelText: "Your Feedback",
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 4,
//                 validator: (value) => value == null || value.trim().isEmpty ? 'Please enter feedback' : null,
//               ),
//               const SizedBox(height: 20),
//
//               _buildRatingSlider(),
//               const SizedBox(height: 24),
//
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isSubmitting ? null : _submitFeedback,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: bgColorPink,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: _isSubmitting
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text("Submit Feedback", style: TextStyle(fontSize: 16,color: Colors.white)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constant/constant.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  String? _userName;
  String? _phoneNumber;
  double _rating = 3.0;
  String _selectedCategory = "General";
  bool _isSubmitting = false;
  bool _showThankYou = false;

  final List<String> _categories = ["General", "Service", "Delivery", "Price", "App Experience"];

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.phoneNumber != null) {
      _phoneNumber = user.phoneNumber;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_phoneNumber)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc.data()?['name'] ?? "User";
        });
      }
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    if (_phoneNumber == null || _userName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User details missing"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'name': _userName,
        'phoneNumber': _phoneNumber,
        'feedback': _feedbackController.text.trim(),
        'rating': _rating,
        'category': _selectedCategory,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _showThankYou = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        Navigator.pop(context);

      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit feedback: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildRatingSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Rating", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Slider(
          value: _rating,
          min: 1.0,
          max: 5.0,
          divisions: 4,
          label: _rating.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _rating = value;
            });
          },
          activeColor: bgColorPink,
          inactiveColor: Colors.grey[300],
        ),
        Text(
          _ratingDescription(_rating),
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  String _ratingDescription(double rating) {
    if (rating <= 1.5) return "Very Poor";
    if (rating <= 2.5) return "Poor";
    if (rating <= 3.5) return "Average";
    if (rating <= 4.5) return "Good";
    return "Excellent";
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: "Feedback Category",
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
    );
  }

  // Mobile-specific layout
  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              "We value your feedback!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: "Your Feedback",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter feedback' : null,
            ),
            const SizedBox(height: 20),
            _buildRatingSlider(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColorPink,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Feedback", style: TextStyle(fontSize: 16,color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Web-specific layout
  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column with title
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "We value your feedback!",
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Your opinion helps us improve our services. Please share your thoughts with us.",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            // Right Column with form
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _buildCategoryDropdown(),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _feedbackController,
                        decoration: const InputDecoration(
                          labelText: "Your Feedback",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 6,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter feedback' : null,
                      ),
                      const SizedBox(height: 24),
                      _buildRatingSlider(),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitFeedback,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bgColorPink,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Submit Feedback", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showThankYou) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Lottie.asset(
            'assets/animations/thankyou.json',
            repeat: false,
            width: 200,
            height: 200,
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    const mobileBreakpoint = 800.0;
    final bool isMobile = screenWidth < mobileBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback", style: TextStyle(color: Colors.white)),
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
        child: isMobile ? _buildMobileLayout(context) : _buildWebLayout(context),
      ),
    );
  }
}
