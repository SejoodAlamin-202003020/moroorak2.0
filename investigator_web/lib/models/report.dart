class Report {
  final String id;
  final String userId;
  final String? reporterName;
  final String? reporterEmail;
  final String? reporterPhone;
  final String reportNumber;
  final String myPlateNumber;
  final String? myVehicleType;
  final String? myVehicleModel;
  final String? myVehicleColor;
  final String otherPlateNumber;
  final String? otherVehicleType;
  final String? otherVehicleModel;
  final String? otherVehicleColor;
  final bool isOwner;
  final String? relationToOwner;
  final bool isFaulty;
  final double? faultPercentage;
  final String? myLicenseNumber;
  final String? otherLicenseNumber;
  final String? mySearchCertificate;
  final String? otherSearchCertificate;
  final bool insuranceCovered;
  final String? insuranceType;
  final String? insuranceNumber;
  final bool injuries;
  final String description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String reportStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> photoUrls;

  Report({
    required this.id,
    required this.userId,
    this.reporterName,
    this.reporterEmail,
    this.reporterPhone,
    required this.reportNumber,
    required this.myPlateNumber,
    this.myVehicleType,
    this.myVehicleModel,
    this.myVehicleColor,
    required this.otherPlateNumber,
    this.otherVehicleType,
    this.otherVehicleModel,
    this.otherVehicleColor,
    required this.isOwner,
    this.relationToOwner,
    required this.isFaulty,
    this.faultPercentage,
    this.myLicenseNumber,
    this.otherLicenseNumber,
    this.mySearchCertificate,
    this.otherSearchCertificate,
    required this.insuranceCovered,
    this.insuranceType,
    this.insuranceNumber,
    required this.injuries,
    required this.description,
    this.location,
    this.latitude,
    this.longitude,
    required this.reportStatus,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.photoUrls,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      userId: json['user_id'],
      reporterName: json['reporter_name'],
      reporterEmail: json['reporter_email'],
      reporterPhone: json['reporter_phone'],
      reportNumber: json['report_number'],
      myPlateNumber: json['my_plate_number'],
      myVehicleType: json['my_vehicle_type'],
      myVehicleModel: json['my_vehicle_model'],
      myVehicleColor: json['my_vehicle_color'],
      otherPlateNumber: json['other_plate_number'],
      otherVehicleType: json['other_vehicle_type'],
      otherVehicleModel: json['other_vehicle_model'],
      otherVehicleColor: json['other_vehicle_color'],
      isOwner: json['is_owner'],
      relationToOwner: json['relation_to_owner'],
      isFaulty: json['is_faulty'],
      faultPercentage: json['fault_percentage']?.toDouble(),
      myLicenseNumber: json['my_license_number'],
      otherLicenseNumber: json['other_license_number'],
      mySearchCertificate: json['my_search_certificate'],
      otherSearchCertificate: json['other_search_certificate'],
      insuranceCovered: json['insurance_covered'],
      insuranceType: json['insurance_type'],
      insuranceNumber: json['insurance_number'],
      injuries: json['injuries'],
      description: json['description'],
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      reportStatus: json['report_status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      photoUrls: [], // Will be populated separately from report_images
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'report_number': reportNumber,
      'my_plate_number': myPlateNumber,
      'my_vehicle_type': myVehicleType,
      'my_vehicle_model': myVehicleModel,
      'my_vehicle_color': myVehicleColor,
      'other_plate_number': otherPlateNumber,
      'other_vehicle_type': otherVehicleType,
      'other_vehicle_model': otherVehicleModel,
      'other_vehicle_color': otherVehicleColor,
      'is_owner': isOwner,
      'relation_to_owner': relationToOwner,
      'is_faulty': isFaulty,
      'fault_percentage': faultPercentage,
      'my_license_number': myLicenseNumber,
      'other_license_number': otherLicenseNumber,
      'my_search_certificate': mySearchCertificate,
      'other_search_certificate': otherSearchCertificate,
      'insurance_covered': insuranceCovered,
      'insurance_type': insuranceType,
      'insurance_number': insuranceNumber,
      'injuries': injuries,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'report_status': reportStatus,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
