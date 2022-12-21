import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnProvider with ChangeNotifier {
  final state = ValueNotifier<ConnectivityResult>(ConnectivityResult.none);

  ConnProvider() {
    _init();
  }

  void _init() async {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      state.value = result;
    });
  }
}
