import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:uhoh/src/client.dart';
import 'package:uhoh/src/config.dart';
import 'package:uhoh/src/constants.dart';
import 'package:uhoh/src/utils.dart';

final _log = Logger('uhoh');

Future<void> main(List<String> arguments) async {
  final config = makeConfig(arguments);

  if (config.isVerbose) {
    Logger.root.level = Level.ALL;
  } else {
    Logger.root.level = Level.INFO;
  }

  if (config.isQuiet) {
    Logger.root.level = Level.OFF;
  }

  _log.onRecord.listen((record) {
    stderr.write(
        '${record.time.toUtc()} [${record.level}] ${record.loggerName}: ${record.message}\n');
  });

  final client = Uhoh(config: config);
  await client.updateAll();
}

/// Uses the environment and command line arguments to
/// make a configuration object suitable for running the
/// backup tool or throws a `UhohConfigError` with an error
/// message suitable for consumption by the end user.
Config makeConfig(List<String> arguments) {
  final argParser = ArgParser(usageLineLength: 79)
    ..addFlag(
      'dry-run',
      help: 'Verify options and authentication, but clone nothing',
      defaultsTo: false,
      negatable: false,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show help and usage information',
      defaultsTo: false,
      negatable: false,
    )
    ..addMultiOption(
      'languages',
      abbr: 'l',
      help:
          'Filter repos based on their prevailing language, case-insensitive, may be repeated',
      valueHelp: 'lang',
    )
    ..addMultiOption(
      'names',
      abbr: 'n',
      help: 'Filter repos based on their name, case-sensitive, may be repeated',
      valueHelp: 'name',
    )
    ..addMultiOption(
      'organizations',
      abbr: 'o',
      help: 'Organizations whose repos should be backed up',
      valueHelp: 'org',
    )
    ..addFlag(
      'quiet',
      abbr: 'q',
      help: 'Stay quiet as a church mouse unless we crash',
      defaultsTo: false,
      negatable: false,
    )
    ..addOption(
      'target',
      abbr: 't',
      help: 'Target directory to clone repos into, absolute or relative',
      valueHelp: 'path',
      defaultsTo: '.',
    )
    ..addMultiOption(
      'users',
      abbr: 'u',
      help: 'Users whose repos should be backed up, may be repeated',
      valueHelp: 'user',
    )
    ..addFlag(
      'verbose',
      help: 'Print more information while running',
      defaultsTo: false,
      negatable: false,
    );

  final argResults = argParser.parse(arguments);

  // Print the fancy help information and then quit if we got
  // the --help or -h flag.
  if (argResults['help'] as bool) {
    var firstLine = 'usage: uhoh ' +
        argParser.options.values.map((option) {
          var next = '[--${option.name}';
          if (option.valueHelp != null) {
            next += '=<${option.valueHelp}>';
          }
          next += ']';
          return next;
        }).join(' ');
    print(wrapString(firstLine, argParser.usageLineLength, hangingIndent: 12));

    print('');
    print(argParser.usage);
    print('');

    var authMessage = 'The environment variable $AUTH_TOKEN_VARIABLE should '
        'be set to your GitHub personal token, '
        'which must have all "repo" permissions.';
    print(wrapString(authMessage, argParser.usageLineLength));

    exit(0);
  }

  final configBuilder = ConfigBuilder();

  configBuilder.authToken = Platform.environment[AUTH_TOKEN_VARIABLE];

  for (final option in argResults.options) {
    switch (option) {
      case 'dry-run':
        configBuilder.isDryRun = argResults[option];
        break;
      case 'languages':
        configBuilder.languages = argResults[option] as List<String>;
        break;
      case 'names':
        configBuilder.names = argResults[option] as List<String>;
        break;
      case 'organizations':
        final organizations = argResults[option] as List<String>;
        configBuilder.organizations = organizations;
        break;
      case 'quiet':
        configBuilder.isQuiet = argResults[option];
        break;
      case 'target':
        final targetPath = argResults[option];
        configBuilder.targetDirectory = Directory(targetPath).absolute;
        break;
      case 'users':
        final users = argResults[option] as List<String>;
        configBuilder.users = users;
        break;
      case 'verbose':
        configBuilder.isVerbose = argResults[option];
        break;
    }
  }

  return configBuilder.build();
}
