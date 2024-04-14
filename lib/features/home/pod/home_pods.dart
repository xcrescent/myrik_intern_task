import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pickUpSearchController = StateProvider<TextEditingController>((ref) {
  return TextEditingController();
});

final dropSearchController = StateProvider<TextEditingController>((ref) {
  return TextEditingController();
});

final speechEnabledPod = StateProvider<bool>((ref) {
  return false;
});

final textRecognizedPod = StateProvider<String>((ref) {
  return '';
});
