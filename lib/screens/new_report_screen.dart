import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/report_service.dart';
import '../services/photo_upload_service.dart';

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reportService = ReportService();
  final _photoUploadService = PhotoUploadService();

  // Your car details
  final _yourCarPlateController = TextEditingController();
  final _yourCarTypeController = TextEditingController();
  final _yourCarModelController = TextEditingController();
  final _yourCarColorController = TextEditingController();

  // Other car details
  final _otherCarPlateController = TextEditingController();
  final _otherCarTypeController = TextEditingController();
  final _otherCarModelController = TextEditingController();
  final _otherCarColorController = TextEditingController();

  // Ownership and fault
  bool _isOwner = true;
  String? _relationship;
  bool _isYourFault = false;
  final _toleranceController = TextEditingController();

  // License numbers
  final _yourLicenseController = TextEditingController();
  final _otherLicenseController = TextEditingController();

  // Car search certificates
  final _yourCertificateController = TextEditingController();
  final _otherCertificateController = TextEditingController();

  // Insurance
  bool _hasInsurance = false;
  final _insurancePolicyController = TextEditingController();
  String? _insuranceType;

  // Injuries and description
  bool _hasInjuries = false;
  final _descriptionController = TextEditingController();

  // Location and photos
  String? _location;
  List<File> _photos = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Report',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Your Car Details'),
                    _buildTextField(_yourCarPlateController,
                        'Car Plate Number *', 'Enter your car plate number'),
                    _buildTextField(_yourCarTypeController, 'Car Type',
                        'Enter car type (e.g., Sedan)'),
                    _buildTextField(_yourCarModelController, 'Car Model',
                        'Enter car model'),
                    _buildTextField(_yourCarColorController, 'Car Color',
                        'Enter car color'),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Other Driver\'s Car Details'),
                    _buildTextField(
                        _otherCarPlateController,
                        'Car Plate Number *',
                        'Enter other driver\'s car plate number'),
                    _buildTextField(
                        _otherCarTypeController, 'Car Type', 'Enter car type'),
                    _buildTextField(_otherCarModelController, 'Car Model',
                        'Enter car model'),
                    _buildTextField(_otherCarColorController, 'Car Color',
                        'Enter car color'),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Ownership & Fault'),
                    SwitchListTile(
                      title: const Text('Are you the owner of the car?'),
                      value: _isOwner,
                      onChanged: (value) => setState(() => _isOwner = value),
                    ),
                    if (!_isOwner)
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Relationship'),
                        items: ['Agent', 'First-degree kinship', 'Other']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _relationship = value),
                        validator: (value) => !_isOwner && value == null
                            ? 'Please select relationship'
                            : null,
                      ),
                    SwitchListTile(
                      title: const Text('Was the accident your fault?'),
                      value: _isYourFault,
                      onChanged: (value) =>
                          setState(() => _isYourFault = value),
                    ),
                    _buildTextField(
                        _toleranceController,
                        'Accident Tolerance (≥10%)',
                        'Enter tolerance percentage', validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final num = double.tryParse(value);
                      if (num == null || num < 10) return 'Must be ≥10%';
                      return null;
                    }),
                    const SizedBox(height: 24),
                    _buildSectionTitle('License Numbers'),
                    _buildTextField(_yourLicenseController,
                        'Your License Number', 'Enter your license number'),
                    _buildTextField(
                        _otherLicenseController,
                        'Other Driver\'s License Number',
                        'Enter other driver\'s license number'),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Car Search Certificates'),
                    _buildTextField(
                        _yourCertificateController,
                        'Your Car Search Certificate Number',
                        'Enter certificate number'),
                    _buildTextField(
                        _otherCertificateController,
                        'Other Driver\'s Certificate Number',
                        'Enter certificate number'),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Insurance'),
                    SwitchListTile(
                      title: const Text('Does the car include insurance?'),
                      value: _hasInsurance,
                      onChanged: (value) =>
                          setState(() => _hasInsurance = value),
                    ),
                    if (_hasInsurance) ...[
                      _buildTextField(_insurancePolicyController,
                          'Insurance Policy Number', 'Enter policy number'),
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Insurance Type'),
                        items: ['Comprehensive', 'Third Party']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _insuranceType = value),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _buildSectionTitle('Incident Details'),
                    SwitchListTile(
                      title: const Text('Are there any injuries?'),
                      value: _hasInjuries,
                      onChanged: (value) =>
                          setState(() => _hasInjuries = value),
                    ),
                    _buildTextField(
                        _descriptionController,
                        'Description (≥10 characters) *',
                        'Describe the incident',
                        maxLines: 3, validator: (value) {
                      if (value == null || value.length < 10)
                        return 'Description must be at least 10 characters';
                      return null;
                    }),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Location'),
                    ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.location_on),
                      label: const Text('Get Current Location'),
                    ),
                    if (_location != null) Text('Location: $_location'),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Photos'),
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.camera),
                      label: const Text('Attach Photos'),
                    ),
                    if (_photos.isNotEmpty)
                      Wrap(
                        children: _photos
                            .map((photo) =>
                                Image.file(photo, width: 100, height: 100))
                            .toList(),
                      ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Submit Report',
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {int maxLines = 1, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: validator ??
            (value) => value == null || value.isEmpty
                ? 'This field is required'
                : null,
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them.';
        });
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permissions are permanently denied. Please enable them in settings.';
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _location = '${position.latitude}, ${position.longitude}';
        _errorMessage = null; // Clear any previous error
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    setState(() {
      _photos = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    // Check required fields
    if (_yourCarPlateController.text.isEmpty ||
        _otherCarPlateController.text.isEmpty ||
        _descriptionController.text.length < 10) {
      setState(() => _errorMessage = 'Please fill in all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user!.id;

      // Upload photos to Supabase storage
      List<String> photoUrls = [];
      if (_photos.isNotEmpty) {
        photoUrls = await _photoUploadService.uploadPhotos(_photos, userId);
      }

      await _reportService.submitReport(
        userId: userId,
        myPlateNumber: _yourCarPlateController.text,
        myVehicleType: _yourCarTypeController.text,
        myVehicleModel: _yourCarModelController.text,
        myVehicleColor: _yourCarColorController.text,
        otherPlateNumber: _otherCarPlateController.text,
        otherVehicleType: _otherCarTypeController.text,
        otherVehicleModel: _otherCarModelController.text,
        otherVehicleColor: _otherCarColorController.text,
        isOwner: _isOwner,
        relationToOwner: _relationship,
        isFaulty: _isYourFault,
        faultPercentage: double.tryParse(_toleranceController.text) ?? 0.0,
        myLicenseNumber: _yourLicenseController.text,
        otherLicenseNumber: _otherLicenseController.text,
        mySearchCertificate: _yourCertificateController.text,
        otherSearchCertificate: _otherCertificateController.text,
        insuranceCovered: _hasInsurance,
        insuranceType: _insuranceType,
        insuranceNumber: _insurancePolicyController.text,
        injuries: _hasInjuries,
        description: _descriptionController.text,
        location: _location ??
            'Manual location', // TODO: Implement manual location input
        photoUrls: photoUrls,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to submit report: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _yourCarPlateController.dispose();
    _yourCarTypeController.dispose();
    _yourCarModelController.dispose();
    _yourCarColorController.dispose();
    _otherCarPlateController.dispose();
    _otherCarTypeController.dispose();
    _otherCarModelController.dispose();
    _otherCarColorController.dispose();
    _toleranceController.dispose();
    _yourLicenseController.dispose();
    _otherLicenseController.dispose();
    _yourCertificateController.dispose();
    _otherCertificateController.dispose();
    _insurancePolicyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
