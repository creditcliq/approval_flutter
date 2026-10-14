class AUserData {
  /// First name of the user
  final String? firstName;

  /// Last name of the user
  final String? lastName;

  /// 11-digit Bank Verification Number (BVN)
  final String? bvn;

  /// 11-digit National Identity Number (NIN)
  final String? nin;

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
    this.nin,
    this.email,
    this.dob,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (firstName != null && firstName!.isNotEmpty) map['firstName'] = firstName;
    if (lastName != null && lastName!.isNotEmpty) map['lastName'] = lastName;
    if (bvn != null && bvn!.isNotEmpty) map['bvn'] = bvn;
    if (nin != null && nin!.isNotEmpty) map['nin'] = nin;
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (dob != null && dob!.isNotEmpty) {
      map['dob'] = dob;
      map['dateOfBirth'] = dob;
    }
    if (phone != null && phone!.isNotEmpty) map['phone'] = phone;
    return map;
  }
}