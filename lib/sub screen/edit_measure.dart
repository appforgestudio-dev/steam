import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam/constant/constant.dart';

class EditMeasurementsPage extends StatefulWidget {
  const EditMeasurementsPage({super.key});

  @override
  State<EditMeasurementsPage> createState() => _EditMeasurementsPageState();
}

class _EditMeasurementsPageState extends State<EditMeasurementsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to manage the text in each TextFormField
  final _shoulderToScalpController = TextEditingController();
  final _shoulderToThighController = TextEditingController();
  final _hipCircumferenceController = TextEditingController();
  final _chestPleatController = TextEditingController();

  // Define the same unique keys used to save the data
  static const String _shoulderToScalpKey = 'shoulder_to_scalp';
  static const String _shoulderToThighKey = 'shoulder_to_thigh';
  static const String _hipCircumferenceKey = 'hip_circumference';
  static const String _chestPleatKey = 'chest_pleat';

  @override
  void initState() {
    super.initState();
    // Load the saved measurements when the page opens
    _loadMeasurements();
  }

  @override
  void dispose() {
    // Clean up the controllers
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

  /// Saves the updated values and returns to the previous screen.
  Future<void> _updateMeasurements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shoulderToScalpKey, _shoulderToScalpController.text);
    await prefs.setString(_shoulderToThighKey, _shoulderToThighController.text);
    await prefs.setString(_hipCircumferenceKey, _hipCircumferenceController.text);
    await prefs.setString(_chestPleatKey, _chestPleatController.text);

    if (!mounted) return;

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Measurements updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'V12 Laundry | Edit',
      color: bgColorPink,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Your Measurements', style: TextStyle(color: Colors.white)),
          backgroundColor: bgColorPink,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _buildForm(),
                ),
              );
            }
            return _buildForm(); // Mobile layout
          },
        ),
      ),
    );
  }

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
            onPressed: _updateMeasurements,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColorPink, // Consistent button color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Update Measurements'),
          ),
        ],
      ),
    );
  }

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
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: bgColorPink, width: 2.0),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
    );
  }
}