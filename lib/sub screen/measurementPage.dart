import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam/constant/constant.dart';

import '../screen/HomeScreen.dart';

class MeasurementsPage extends StatefulWidget {
  const MeasurementsPage({super.key});

  @override
  State<MeasurementsPage> createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  // A GlobalKey for the form to enable validation later if needed
  final _formKey = GlobalKey<FormState>();

  // Controllers to manage the text in each TextFormField
  final _shoulderToScalpController = TextEditingController();
  final _shoulderToThighController = TextEditingController();
  final _hipCircumferenceController = TextEditingController();
  final _chestPleatController = TextEditingController();

  // Define unique keys for saving data to shared_preferences
  static const String _shoulderToScalpKey = 'shoulder_to_scalp';
  static const String _shoulderToThighKey = 'shoulder_to_thigh';
  static const String _hipCircumferenceKey = 'hip_circumference';
  static const String _chestPleatKey = 'chest_pleat';

  @override
  void initState() {
    super.initState();
    // Load any previously saved measurements when the page opens
    _loadMeasurements();
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed from the screen
    _shoulderToScalpController.dispose();
    _shoulderToThighController.dispose();
    _hipCircumferenceController.dispose();
    _chestPleatController.dispose();
    super.dispose();
  }

  /// Loads values from SharedPreferences and populates the text fields.
  Future<void> _loadMeasurements() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _shoulderToScalpController.text = prefs.getString(_shoulderToScalpKey) ?? '';
      _shoulderToThighController.text = prefs.getString(_shoulderToThighKey) ?? '';
      _hipCircumferenceController.text = prefs.getString(_hipCircumferenceKey) ?? '';
      _chestPleatController.text = prefs.getString(_chestPleatKey) ?? '';
    });
  }

  /// Saves the current values from the text fields to SharedPreferences.
  Future<void> _saveMeasurements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shoulderToScalpKey, _shoulderToScalpController.text);
    await prefs.setString(_shoulderToThighKey, _shoulderToThighController.text);
    await prefs.setString(_hipCircumferenceKey, _hipCircumferenceController.text);
    await prefs.setString(_chestPleatKey, _chestPleatController.text);

    // Show a confirmation message to the user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Measurements saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'V12 Laundry | Measurement',
      color: bgColorPink,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enter Your Measurements',style: TextStyle(color: Colors.white),),
          backgroundColor: bgColorPink,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // For wider screens (web), center the form with a max width
            if (constraints.maxWidth > 600) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _buildForm(),
                ),
              );
            }
            // For narrower screens (mobile), the form takes the full width
            return _buildForm();
          },
        ),
      ),
    );
  }

  /// Builds the form containing all the measurement input fields.
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildMeasurementField(
            controller: _shoulderToScalpController,
            label: 'Shoulder Stitch to Scalp Muscle',
          ),
          const SizedBox(height: 20),
          _buildMeasurementField(
            controller: _shoulderToThighController,
            label: 'Shoulder to Right Outer Thigh',
          ),
          const SizedBox(height: 20),
          _buildMeasurementField(
            controller: _hipCircumferenceController,
            label: 'Hip Circumference',
          ),
          const SizedBox(height: 20),
          _buildMeasurementField(
            controller: _chestPleatController,
            label: 'Chest Pleat (Arm Hold to Arm Hold)',
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _saveMeasurements,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: const Text('Save Measurements',style: TextStyle(color: bgColorPink),),
          ),
        ],
      ),
    );
  }

  /// A helper widget to create a styled TextFormField for a measurement.
  TextFormField _buildMeasurementField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'inch',
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      // Allows only numbers and a single decimal point
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
    );
  }
}