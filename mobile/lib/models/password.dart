import 'dart:convert';
import 'package:flutter/material.dart';

class Password {
  final String? id;
  final String? title;
  final String? username;
  final String? encryptedPassword;
  final String? websiteUrl;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Password({
    this.id,
    this.title,
    this.username,
    this.encryptedPassword,
    this.websiteUrl,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Password.fromJson(Map<String, dynamic> json) {
    return Password(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      username: json['username'] as String?,
      encryptedPassword: json['encrypted_password'] as String?,
      websiteUrl: json['website_url'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'username': username,
      'encrypted_password': encryptedPassword,
      'website_url': websiteUrl,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
} 