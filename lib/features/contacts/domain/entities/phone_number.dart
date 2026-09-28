final _formatting = RegExp(r'[\s().-]');
final _e164 = RegExp(r'^\+[1-9]\d{7,14}$');

/// Mesma regra da API: aceita "+55 (11) 99999-9999" e devolve
/// "+5511999999999"; sem o código do país (`+`) o número é inválido.
String? normalizePhone(String raw) {
  final phone = raw.trim().replaceAll(_formatting, '');
  return _e164.hasMatch(phone) ? phone : null;
}
