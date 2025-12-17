class ContactInfo {
  String phone;
  String email;
  String address;
  String website;

  ContactInfo({
    required this.phone,
    required this.email,
    required this.address,
    required this.website,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      website: json['website'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'address': address,
      'website': website,
    };
  }
}
