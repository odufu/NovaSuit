import 'package:flutter/material.dart';

class CampaignFormBuilderProvider extends ChangeNotifier {
  int _currentStep = 0;
  String _quantityDisplayMode = 'radio';
  final List<Map<String, dynamic>> _formFields = [
    {'name': 'Full Name', 'type': 'Text Field', 'required': true},
    {'name': 'Phone Number (WhatsApp)', 'type': 'Phone Field', 'required': true},
    {'name': 'Delivery Address', 'type': 'Text Area', 'required': true},
    {'name': 'Delivery State & City', 'type': 'Dropdown', 'required': true},
    {'name': 'Select Package Offer', 'type': 'Package Radio Selector', 'required': true},
  ];

  int get currentStep => _currentStep;
  String get quantityDisplayMode => _quantityDisplayMode;
  List<Map<String, dynamic>> get formFields => List.unmodifiable(_formFields);

  void setStep(int step) {
    if (_currentStep != step) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void setQuantityDisplayMode(String mode) {
    _quantityDisplayMode = mode;
    notifyListeners();
  }

  void toggleFieldRequired(int index) {
    if (index >= 0 && index < _formFields.length) {
      _formFields[index]['required'] = !(_formFields[index]['required'] as bool);
      notifyListeners();
    }
  }
}
