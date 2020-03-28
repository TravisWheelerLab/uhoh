import 'dart:io';

/// A statically-typed configuration that will generally be
/// constructed from command line arguments or perhaps a
/// configuration file.
abstract class Config {
  String get authToken;

  bool get isDryRun;

  bool get isQuiet;

  bool get isVerbose;

  Iterable<String> get languages;

  Iterable<String> get names;

  Iterable<String> get organizations;

  Directory get targetDirectory;

  Iterable<String> get users;
}

/// A cut-rate builder for the [Config] class that implements
/// the [Config] interface and "builds" by returning itself,
/// upcast to [Config].
class ConfigBuilder implements Config {
  @override
  String authToken;

  @override
  bool isDryRun = false;

  @override
  bool isQuiet = false;

  @override
  bool isVerbose = false;

  @override
  List<String> languages = const [];

  @override
  List<String> names = const [];

  @override
  List<String> organizations = const [];

  @override
  Directory targetDirectory;

  @override
  List<String> users = const [];

  bool _isAlive = true;

  Config build() {
    if (!_isAlive) {
      throw ConfigError('builder has been consumed');
    }
    _isAlive = false;

    if (authToken == null || authToken.isEmpty) {
      throw ConfigError('authToken may not be null or empty');
    }

    isDryRun ??= false;
    isQuiet ??= false;
    isVerbose ??= false;

    if (targetDirectory == null) {
      throw ConfigError('targetDirectory may not be null');
    }

    // Convert languages to lower case for consistency
    languages = (languages ?? const []).map((l) => l.toLowerCase()).toList();

    names ??= const [];
    organizations ??= const [];
    users ??= const [];

    return this;
  }
}

class ConfigError extends Error {
  final Object message;

  ConfigError([this.message]);

  @override
  String toString() => 'config error: $message';
}
