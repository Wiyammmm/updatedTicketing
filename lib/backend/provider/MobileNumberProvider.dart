import 'dart:async';
import 'package:dltb/backend/deviceinfo/getDeviceInfo.dart';
import 'package:flutter/material.dart';

class MobileNumberProvider with ChangeNotifier {
  DeviceInfoService deviceInfoService = DeviceInfoService();
  String _mobileNumber = "";
  String get mobileNumber => _mobileNumber;

  MobileNumberProvider() {
    checkMobileNumberPeriodically();
  }

  Future<void> checkMobileNumberPeriodically() async {
    while (true) {
      await checkMobileNumber();
      await Future.delayed(
          Duration(seconds: 10)); // Adjust the interval as needed
    }
  }

  Future<void> checkMobileNumber() async {
    try {
      String newMobileNumber = await deviceInfoService.getMobileNumber();
      if (_mobileNumber != newMobileNumber) {
        _mobileNumber = newMobileNumber;
        notifyListeners();
      }
    } catch (e) {
      print('Error getting mobile number: $e');
    }
  }
}
