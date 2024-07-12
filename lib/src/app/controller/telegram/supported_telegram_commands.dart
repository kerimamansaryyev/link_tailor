Pattern _stringPattern(String s) => s;

enum SupportedTelegramCommand {
  start._('start', _stringPattern, '/start'),
  shortenLink._('shorten_link', _stringPattern, '/shorten_link');

  const SupportedTelegramCommand._(
    this.pattern,
    this._patternFactory,
    this.displayableName,
  );

  final String pattern;
  final String displayableName;
  final Pattern Function(String) _patternFactory;

  Pattern getPatternCasted() => _patternFactory(pattern);
}
