/// Constantes globais da aplicação LoadSecure.
abstract class AppConstants {
  // --- App Info ---
  static const String appName        = 'LoadSecure';
  static const String appVersion     = '1.0.0';

  // --- SharedPreferences Keys ---
  static const String keyAuthToken   = 'auth_token';
  static const String keyUserId      = 'user_id';
  static const String keyUserName    = 'user_name';
  static const String keyUserEmail   = 'user_email';
  static const String keyIsLoggedIn  = 'is_logged_in';

  // --- Durations ---
  static const Duration animationFast   = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow   = Duration(milliseconds: 600);
  static const Duration splashDuration  = Duration(seconds: 2);

  // --- Padding / Spacing ---
  static const double paddingXS  = 4.0;
  static const double paddingS   = 8.0;
  static const double paddingM   = 16.0;
  static const double paddingL   = 24.0;
  static const double paddingXL  = 32.0;
  static const double paddingXXL = 48.0;

  // --- Border Radius ---
  static const double radiusS   = 8.0;
  static const double radiusM   = 12.0;
  static const double radiusL   = 16.0;
  static const double radiusXL  = 24.0;
  static const double radiusXXL = 32.0;

  // --- Icon Sizes ---
  static const double iconS   = 16.0;
  static const double iconM   = 24.0;
  static const double iconL   = 32.0;
  static const double iconXL  = 48.0;

  // --- Machine Status ---
  static const String statusOnline      = 'online';
  static const String statusOffline     = 'offline';
  static const String statusMaintenance = 'maintenance';
  static const String statusAlert       = 'alert';
}
