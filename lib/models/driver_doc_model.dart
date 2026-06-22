class DriverDocuments {
  final DriverLicenceDoc dl;
  final RegistrationCertificateDoc rc;
  final ProfilePhotoDoc pp;
  final String? firstName;
  final String? lastName;
  final bool permission;

  DriverDocuments({
    required this.dl,
    required this.rc,
    required this.pp,
    required this.firstName,
    required this.lastName,
    required this.permission,
  });
}

class DriverLicenceDoc {
  final String status;
  final String? dlNumber;
  final String? dob;
  final String? frontImage;
  final String? backImage;
  final String? rejectionReason;

  DriverLicenceDoc({
    required this.status,
    this.dlNumber,
    this.dob,
    this.frontImage,
    this.backImage,
    this.rejectionReason,
  });

  factory DriverLicenceDoc.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return DriverLicenceDoc(status: "Absent");
    }
    return DriverLicenceDoc(
      status: data['Status'] ?? "Absent",
      dlNumber: data['DLNumber'],
      dob: data['DOB'],
      frontImage: data['FrontImage'],
      backImage: data['BackImage'],
      rejectionReason: data['RejectionReason'],
    );
  }
}

class RegistrationCertificateDoc {
  final String status;
  final String? Number;
  final String? frontImage;
  final String? backImage;
  final String? rejectionReason;

  RegistrationCertificateDoc({
    required this.status,
    this.Number,
    this.frontImage,
    this.backImage,
    this.rejectionReason,
  });

  factory RegistrationCertificateDoc.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return RegistrationCertificateDoc(status: "Absent");
    }
    return RegistrationCertificateDoc(
      status: data['Status'] ?? "Absent",
      Number: data['RCNumber'],
      frontImage: data['FrontImage'],
      backImage: data['BackImage'],
      rejectionReason: data['RejectionReason'],
    );
  }
}

class ProfilePhotoDoc {
  final String status;
  final String? photoUrl;
  final String? rejectionReason;

  ProfilePhotoDoc({
    required this.status,
    this.photoUrl,
    this.rejectionReason,
  });

  factory ProfilePhotoDoc.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return ProfilePhotoDoc(status: "Absent");
    }
    return ProfilePhotoDoc(
      status: data['Status'] ?? "Absent",
      photoUrl: data['PhotoURL'],
      rejectionReason: data['RejectionReason'],
    );
  }
}
