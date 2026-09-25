enum WearEstimateSource {
  /// Usa a vida útil informada manualmente (ainda sem histórico).
  expected,

  /// Usa a média de duração real dos ciclos anteriores.
  history;

  String get label {
    switch (this) {
      case WearEstimateSource.expected:
        return 'vida útil informada';
      case WearEstimateSource.history:
        return 'média do histórico';
    }
  }

  static WearEstimateSource fromApiValue(String value) {
    switch (value) {
      case 'EXPECTED':
        return WearEstimateSource.expected;
      case 'HISTORY':
        return WearEstimateSource.history;
      default:
        throw ArgumentError('Origem de estimativa desconhecida: $value');
    }
  }
}
