import 'package:github/github.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:uhoh/src/config.dart';
import 'package:uhoh/src/repo.dart';

final _log = Logger('uhoh');

class Uhoh {
  final Config config;

  Uhoh({
    @required this.config,
  });

  Future<void> update(String namespace, String name) async {
    //
  }

  Future<void> updateAll() async {
    await config.targetDirectory.create(recursive: true);

    await _repos().forEach((repo) {
      final local = path.join(
        config.targetDirectory.path,
        repo.owner.login,
        repo.name,
      );
      final remote = 'git@github.com:${repo.fullName}.git';

      if (config.isDryRun) {
        _log.info('would clone or fetch "${repo.fullName}"');
        return;
      }

      Repo(
        local: local,
        remote: remote,
      )..fetchSync();
    });
  }

  Stream<Repository> _repos() async* {
    final github = GitHub(
      auth: Authentication.withToken(config.authToken),
    );

    for (final user in config.users) {
      yield* github.repositories
          .listUserRepositories(user)
          .where(_filterLanguage)
          .where(_filterName);
    }

    for (final organization in config.organizations) {
      yield* github.repositories
          .listOrganizationRepositories(organization)
          .where(_filterLanguage)
          .where(_filterName);
    }
  }

  bool _filterLanguage(Repository repo) {
    if (config.languages.isEmpty) {
      return true;
    }

    if (repo.language == null) {
      return false;
    }

    return config.languages.contains(repo.language.toLowerCase());
  }

  bool _filterName(Repository repo) {
    if (config.names.isEmpty) {
      return true;
    }

    return config.names.contains(repo.name);
  }
}
