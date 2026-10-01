import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Service managing biometric and device-level authentication for privacy lock.
class BiometricService {
  BiometricService._();

  static final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the device has biometric hardware available and enrolled.
  static Future<bool> isBiometricsAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Authenticates user with fingerprint, Face ID, or device PIN.
  static Future<bool> authenticate({String reason = 'Authenticate to access Tapasya'}) async {
    try {
      final available = await isBiometricsAvailable();
      if (!available) return true; // Fail open if no hardware support

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
