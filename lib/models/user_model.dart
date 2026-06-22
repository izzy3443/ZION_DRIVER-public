import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String? uid;
  final String? firstName;
  final String? lastName;
  final String? phoneNo;
  final String? email;
  final String? profilePic;
  final String? status;
  final String? vehicleDetails;
  final String? vehicleNumberPlate;
  final String? vehicleType;
  final int? totalTrips;
  final double? totalEarnings;
  final double? rating;
  final bool? isVerified;
  final int? ridesToday;
  final double? earningsToday;
  final DateTime? subscriptionExpiry;
  final bool? subscriptionActive;

  AppUser({
    this.uid,
    this.firstName,
    this.lastName,
    this.phoneNo,
    this.email,
    this.profilePic,
    this.status,
    this.vehicleDetails,
    this.vehicleNumberPlate,
    this.vehicleType,
    this.totalTrips,
    this.totalEarnings,
    this.rating,
    this.isVerified,
    this.ridesToday,
    this.earningsToday,
    this.subscriptionExpiry,
    this.subscriptionActive,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['Uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNo: map['PhoneNo'],
      email: map['Email'],
      profilePic: map['ProfilePic'],
      status: map['Status'],
      vehicleDetails: map['VehicleDetails'],
      vehicleNumberPlate: map['VehicleNumberPlate'],
      vehicleType: map['VehicleType'],
      totalTrips: map['TotalRides'],
      totalEarnings: map['TotalEarning'] != null
          ? (map['TotalEarning'] as num).toDouble()
          : null,
      rating: map['Rating'] != null ? (map['Rating'] as num).toDouble() : null,
      isVerified: map['Verified'] == true,
      ridesToday: map['ridesToday'],
      earningsToday: map['earningsToday'] != null
          ? (map['earningsToday'] as num).toDouble()
          : null,
      subscriptionExpiry: map['subscriptionExpiry'] != null
          ? (map['subscriptionExpiry'] as Timestamp).toDate()
          : null,
      subscriptionActive: map['subscriptionActive'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'PhoneNo': phoneNo,
      'Email': email,
      'ProfilePic': profilePic,
      'Status': status,
      'VehicleDetails': vehicleDetails,
      'VehicleNumberPlate': vehicleNumberPlate,
      'VehicleType': vehicleType,
      'TotalRides': totalTrips,
      'TotalEarning': totalEarnings,
      'Rating': rating,
      'Verified': isVerified,
      'ridesToday': ridesToday,
      'earningsToday': earningsToday,
      'subscriptionExpiry': subscriptionExpiry,
      'subscriptionActive': subscriptionActive,
    };
  }

  AppUser copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? phoneNo,
    String? email,
    String? profilePic,
    String? status,
    String? vehicleDetails,
    String? vehicleNumberPlate,
    String? vehicleType,
    int? totalTrips,
    double? totalEarnings,
    double? rating,
    bool? isVerified,
    int? ridesToday,
    double? earningsToday,
    DateTime? subscriptionExpiry,
    bool? subscriptionActive,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNo: phoneNo ?? this.phoneNo,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      status: status ?? this.status,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
      vehicleNumberPlate: vehicleNumberPlate ?? this.vehicleNumberPlate,
      vehicleType: vehicleType ?? this.vehicleType,
      totalTrips: totalTrips ?? this.totalTrips,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
      ridesToday: ridesToday ?? this.ridesToday,
      earningsToday: earningsToday ?? this.earningsToday,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      subscriptionActive: subscriptionActive ?? this.subscriptionActive,
    );
  }
}
