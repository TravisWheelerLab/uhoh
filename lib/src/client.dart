import 'package:github/github.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:uhoh/src/config.dart';
import 'package:uhoh/src/repo.dart';

final _log = Logger('uhoh');

/// The Uhoh client is quite simple right now, it allows
/// the consumer to back up a set of repositories based
/// on a configuration.
class Uhoh {
  final Config config;

  Uhoh({
    @required this.config,
  });

  /// Create, or update, backups of all repositories as
  /// defined by the client's configuration.
  Future<void> updateAll() async {
    await config.targetDirectory.create(recursive: true);

    (await _repos()).forEach((repo) {
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

  /// Fetch all the repos we will need to clone.
  ///
  /// We grab all of the repos at once to avoid timing out
  /// the connection while we make the clones. If we want
  /// to make this more memory-efficient, we could clone
  /// one user / organization at a time.
  Future<Iterable<Repository>> _repos() async {
    final github = GitHub(
      auth: Authentication.withToken(config.authToken),
    );

    final all = <Repository>[];

    for (final user in config.users) {
      await github.repositories
          .listUserRepositories(user)
          .where(_filterLanguage)
          .where(_filterName)
          .forEach((r) => all.add(r));
    }

    for (final organization in config.organizations) {
      await github.repositories
          .listOrganizationRepositories(organization)
          .where(_filterLanguage)
          .where(_filterName)
          .forEach((r) => all.add(r));
    }

    return all;
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
