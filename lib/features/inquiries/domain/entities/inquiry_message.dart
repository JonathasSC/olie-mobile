import 'package:equatable/equatable.dart';

class ComposedInquiryMessage extends Equatable {
  final String greeting;
  final String question;
  final String text;

  /// Legenda de cada item ("1. Nome"), na ordem — usada nas fotos.
  final List<String> itemCaptions;

  const ComposedInquiryMessage({
    required this.greeting,
    required this.question,
    required this.text,
    required this.itemCaptions,
  });

  @override
  List<Object?> get props => [greeting, question, text, itemCaptions];
}

/// "Bom dia" das 05h00 às 11h59, "Boa tarde" das 12h00 às 17h59 e
/// "Boa noite" das 18h00 às 04h59 — a mesma regra do backend.
String inquiryGreeting(DateTime localTime) {
  final minutes = localTime.hour * 60 + localTime.minute;
  if (minutes >= 5 * 60 && minutes < 12 * 60) return 'Bom dia';
  if (minutes >= 12 * 60 && minutes < 18 * 60) return 'Boa tarde';
  return 'Boa noite';
}

/// Monta a mensagem localmente para a pré-visualização acompanhar a
/// digitação sem esperar a rede. O backend recompõe na hora do envio a
/// cada contato (a saudação pode mudar até lá).
ComposedInquiryMessage composeInquiryMessage({
  required String template,
  required List<String> itemNames,
  required DateTime localTime,
}) {
  final greeting = inquiryGreeting(localTime);
  final question = itemNames.length == 1 ? 'Tem esse item?' : 'Tem esses itens?';
  final captions = [
    for (var i = 0; i < itemNames.length; i++) '${i + 1}. ${itemNames[i].trim()}',
  ];
  final text = template
      .replaceAll('{saudacao}', greeting)
      .replaceAll('{pergunta}', question)
      .replaceAll('{itens}', captions.join('\n'));
  return ComposedInquiryMessage(
    greeting: greeting,
    question: question,
    text: text,
    itemCaptions: captions,
  );
}
