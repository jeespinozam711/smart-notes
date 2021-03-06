import 'package:app/services/navigation/navigation_service.dart';
import 'package:app/view_models/view_models.dart';
import 'package:app_business/entities.dart';
import 'package:app_business/managers.dart';
import 'package:app_common/exceptions.dart';
import 'package:app_common/constants.dart';
import 'package:app_util/app_util.dart';

class AppViewModel extends BaseViewModel {
  AppViewModel(
    this._authManager,
    this._settingsManager,
    this._analyticsService,
    this._navigationService,
  ) {
    settings = SettingsEntity();
    _onInitialize();
  }

  final AnalyticsService _analyticsService;
  final AuthManager _authManager;
  final NavigationService _navigationService;
  final SettingsManager _settingsManager;

  @override
  void dispose() => _settingsManager.removeListener(_onSettingsChanged);

  SettingsEntity _settings;
  SettingsEntity get settings => _settings;
  set settings(SettingsEntity value) {
    if (_settings == value) {
      _settings = value;
      return;
    }
    _settings = value;
    notifyListeners('settings');
  }

  Future<void> _onInitialize() async {
    _settingsManager.addListener(_onSettingsChanged);

    try {
      await Future.wait([
        _analyticsService.start(),
        _authManager.ensureUserSignedIn(),
        _settingsManager.initialize(),
        Future.delayed(Duration(seconds: 1)),
      ]);

      await _navigationService.pushReplacement(ViewNames.homeView);
    } on AuthException catch (aex) {
      debugError(aex.message);
      await _navigationService.pushReplacement(ViewNames.loginView);
    }
  }

  void _onSettingsChanged() => settings = _settingsManager.currentSettings;
}
