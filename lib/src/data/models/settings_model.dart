import 'package:hive/hive.dart';

class SettingsModel {
  SettingsModel({
    required this.currency,
    required this.themeMode,
    required this.isBiometricEnabled,
    required this.isPinEnabled,
    required this.onboardingCompleted,
  });

  final String currency;
  final int themeMode;
  final bool isBiometricEnabled;
  final bool isPinEnabled;
  final bool onboardingCompleted;

  SettingsModel copyWith({
    String? currency,
    int? themeMode,
    bool? isBiometricEnabled,
    bool? isPinEnabled,
    bool? onboardingCompleted,
  }) {
    return SettingsModel(
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 4;

  @override
  SettingsModel read(BinaryReader reader) {
    return SettingsModel(
      currency: reader.readString(),
      themeMode: reader.readInt(),
      isBiometricEnabled: reader.readBool(),
      isPinEnabled: reader.readBool(),
      onboardingCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeString(obj.currency)
      ..writeInt(obj.themeMode)
      ..writeBool(obj.isBiometricEnabled)
      ..writeBool(obj.isPinEnabled)
      ..writeBool(obj.onboardingCompleted);
  }
}
