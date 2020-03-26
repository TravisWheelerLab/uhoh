String wrapString(
  String value,
  int maxLength, {
  String initial = '',
  int hangingIndent = 0,
}) {
  var lines = <String>[];
  var line = initial;
  value.split(' ').forEach((word) {
    if (line.isEmpty) {
      line = word;
      return;
    }

    if (line.length + word.length + 1 <= maxLength) {
      // It fits!
      line += ' $word';
    } else {
      // It overflowed!
      lines.add(line);
      line = (' ' * hangingIndent) + word;
    }
  });

  lines.add(line);

  return lines.join('\n');
}
