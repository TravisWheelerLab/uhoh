import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

final _log = Logger('uhoh');

/// A thin abstraction over a repository that includes a single
/// remote and possibly a local, bare clone.
class Repo {
  String _localPath;

  String _nsPath;

  String _remotePath;

  Repo({
    @required String local,
    @required String remote,
  }) {
    final localDir = Directory(local);
    localDir.parent.createSync();

    _localPath = localDir.absolute.path;
    _nsPath = localDir.parent.absolute.path;
    _remotePath = remote;
  }

  String get localPath => _localPath;

  String get namespacePath => _nsPath;

  String get remotePath => _remotePath;

  void cloneSync() {
    final localExists = Directory(_localPath).existsSync();
    if (localExists) {
      return;
    }

    _log.info('cloning "$_remotePath"');

    final result = Process.runSync(
      'git',
      [
        'clone',
        '--bare',
        _remotePath,
        _localPath,
      ],
      workingDirectory: _nsPath,
    );

    if (result.exitCode != 0) {
      _throwForResult(result);
    }
  }

  void fetchSync() {
    _log.info('fetching "$_remotePath"');

    cloneSync();

    final result = Process.runSync(
      'git',
      [
        'fetch',
      ],
      workingDirectory: _localPath,
    );

    if (result.exitCode != 0) {
      _throwForResult(result);
    }
  }

  void _throwForResult(ProcessResult result) {
    throw RepoError(
      result.exitCode,
      result.stdout,
      result.stderr,
    );
  }
}

class RepoError extends Error {
  final Object exitCode;
  final Object stdout;
  final Object stderr;

  RepoError(this.exitCode, this.stdout, this.stderr);

  @override
  String toString() => 'repo error';
}
