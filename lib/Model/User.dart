import 'dart:convert';

class User {
  final String firstName;
  final String lastName;
  final String fatherName;
  final String motherFullName;
  final int age;
  final String gender;
  final String placeOfBirth;
  final String country;
  final String city;
  final String phone;
  final String email;
  final String faceSelfie;
  final String nationality;
  final String idType;
  final int idNumber;
  final String idFront;
  final String idBack;
  final String userType;
  final String sourceOfIncome;
  final String martialStatus;
  final String password;

  User({
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.motherFullName,
    required this.age,
    required this.gender,
    required this.placeOfBirth,
    required this.country,
    required this.city,
    required this.phone,
    required this.email,
    required this.faceSelfie,
    required this.nationality,
    required this.idType,
    required this.idNumber,
    required this.idFront,
    required this.idBack,
    required this.userType,
    required this.sourceOfIncome,
    required this.martialStatus,
    required this.password,
  });

  Map<String, dynamic> ToMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'fatherName': fatherName,
      'motherFullName': motherFullName,
      'age': age,
      'gender': gender,
      'placeOfBirth': placeOfBirth,
      'country': country,
      'city': city,
      'phone': phone,
      'email': email,
      'faceSelfie': faceSelfie,
      'nationality': nationality,
      'idType': idType,
      'idNumber': idNumber,
      'idFront': idFront,
      'idBack': idBack,
      'userType': userType,
      'sourceOfIncome': sourceOfIncome,
      'martialStatus': martialStatus,
      'password': password,
    };
  }

  String toJson() => jsonEncode(ToMap());
}
