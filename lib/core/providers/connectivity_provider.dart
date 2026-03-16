import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { isConnected, isDisconnected, notDetermined }

final connectivityStatusProvider = StateNotifierProvider<ConnectivityStateNotifier, ConnectivityStatus>((ref) {
  return ConnectivityStateNotifier();
});

class ConnectivityStateNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityStateNotifier() : super(ConnectivityStatus.notDetermined) {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateState(results);
    });
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateState(results);
  }

  void _updateState(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      state = ConnectivityStatus.isDisconnected;
    } else {
      state = ConnectivityStatus.isConnected;
    }
  }
}
