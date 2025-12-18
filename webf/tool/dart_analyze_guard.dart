import 'dart:convert';
import 'dart:io';

class _Options {
  final int top;
  final int? maxInfo;

  const _Options({required this.top, required this.maxInfo});
}

_Options _parseOptions(List<String> args) {
  int top = 20;
  int? maxInfo;

  for (final arg in args) {
    if (arg.startsWith('--top=')) {
      top = int.parse(arg.substring('--top='.length));
      continue;
    }
    if (arg.startsWith('--max-info=')) {
      maxInfo = int.parse(arg.substring('--max-info='.length));
      continue;
    }
  }

  return _Options(top: top, maxInfo: maxInfo);
}

Future<int> main(List<String> args) async {
  final options = _parseOptions(args);

  final process = await Process.start(
    'dart',
    const ['analyze', '--format', 'machine'],
    runInShell: true,
  );

  final severityCounts = <String, int>{};
  final codeCounts = <String, int>{};

  void trackLine(String line) {
    if (line.isEmpty) return;
    final parts = line.split('|');
    if (parts.length < 4) return;

    final severity = parts[0];
    final code = parts.length >= 3 ? parts[2] : '';

    severityCounts[severity] = (severityCounts[severity] ?? 0) + 1;
    if (code.isNotEmpty) {
      codeCounts[code] = (codeCounts[code] ?? 0) + 1;
    }
  }

  final stdoutFuture = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach(trackLine);
  final stderrFuture = process.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach(trackLine);

  final exitCode = await process.exitCode;
  await Future.wait([stdoutFuture, stderrFuture]);

  int severityCount(String key) => severityCounts[key] ?? 0;

  final errors = severityCount('ERROR');
  final warnings = severityCount('WARNING');
  final infos = severityCount('INFO');

  stdout.writeln('dart analyze: ERROR=$errors WARNING=$warnings INFO=$infos (exitCode=$exitCode)');

  final topCodes = codeCounts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) return byCount;
      return a.key.compareTo(b.key);
    });

  if (topCodes.isNotEmpty) {
    stdout.writeln('Top ${options.top} codes:');
    for (final entry in topCodes.take(options.top)) {
      stdout.writeln('  ${entry.value}\t${entry.key}');
    }
  }

  if (errors > 0 || warnings > 0) return 1;
  if (options.maxInfo != null && infos > options.maxInfo!) return 1;

  return 0;
}

