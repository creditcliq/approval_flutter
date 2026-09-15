class AUserData {
  /// First name of the user
  final String? firstName;

  /// Last name of the user
  final String? lastName;

  /// 11-digit Bank Verification Number (BVN)
  final String? bvn;

  /// Email address
  final String? email;

  /// Date of birth in ISO 8601 format (e.g. "2000-10-01")
  final String? dob;

  /// Phone number with country code (e.g. "+2348012345678")
  final String? phone;

  const AUserData({
    this.firstName,
    this.lastName,
    this.bvn,
    this.email,
    this.dob,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'bvn': bvn ?? '',
      'email': email ?? '',
      'dob': dob,
      'phone': phone,
    };
  }
}