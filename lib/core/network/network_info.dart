import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_logger.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasActiveConnection(results);
    } catch (e) {
      AppLogger.warning('NetworkInfo', 'Failed to check connectivity: $e');
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      final connected = _hasActiveConnection(results);
      AppLogger.debug('NetworkInfo', 'Connectivity changed', {'isConnected': connected});
      return connected;
    });
  }

  bool _hasActiveConnection(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }
}
