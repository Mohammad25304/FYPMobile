import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String name;
  final bool requiresActiveAccount;
  final String? logo;
  final List<Map<String, dynamic>> providers;

  ServiceModel({
    required this.id,
    required this.name,
    required this.requiresActiveAccount,
    this.logo,
    required this.providers,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      requiresActiveAccount: json['requires_active_account'],
      logo: json['logo'],
      providers: List<Map<String, dynamic>>.from(json['providers']),
    );
  }
}
