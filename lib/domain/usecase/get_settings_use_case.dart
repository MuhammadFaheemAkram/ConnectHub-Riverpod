import 'package:connect_hub_riverpod/domain/model/app_settings.dart';
import 'package:connect_hub_riverpod/domain/repository/settings_repository.dart';

/// The settings now, synchronously (for the app's first frame).
class GetSettingsUseCase {
  const GetSettingsUseCase(this._settings);

  final SettingsRepository _settings;

  AppSettings call() => _settings.current;
}
