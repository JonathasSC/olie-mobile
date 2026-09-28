import 'package:flutter_test/flutter_test.dart';

import 'package:olie/features/inquiries/domain/entities/inquiry_message.dart';

void main() {
  const template = '{saudacao}! {pergunta}\n\n{itens}';

  group('inquiryGreeting', () {
    final cases = {
      DateTime(2026, 9, 28, 5, 0): 'Bom dia',
      DateTime(2026, 9, 28, 11, 59): 'Bom dia',
      DateTime(2026, 9, 28, 12, 0): 'Boa tarde',
      DateTime(2026, 9, 28, 17, 59): 'Boa tarde',
      DateTime(2026, 9, 28, 18, 0): 'Boa noite',
      DateTime(2026, 9, 28, 0, 0): 'Boa noite',
      DateTime(2026, 9, 28, 4, 59): 'Boa noite',
    };
    cases.forEach((time, expected) {
      test('${time.hour}:${time.minute} → $expected', () {
        expect(inquiryGreeting(time), expected);
      });
    });
  });

  test('um item usa a pergunta no singular', () {
    final message = composeInquiryMessage(
      template: template,
      itemNames: ['Dipirona 500mg'],
      localTime: DateTime(2026, 9, 28, 9),
    );

    expect(message.text, 'Bom dia! Tem esse item?\n\n1. Dipirona 500mg');
    expect(message.itemCaptions, ['1. Dipirona 500mg']);
  });

  test('vários itens usam o plural e saem numerados', () {
    final message = composeInquiryMessage(
      template: template,
      itemNames: [' Parafuso 8mm ', 'Bucha 8'],
      localTime: DateTime(2026, 9, 28, 19, 30),
    );

    expect(
      message.text,
      'Boa noite! Tem esses itens?\n\n1. Parafuso 8mm\n2. Bucha 8',
    );
    expect(message.itemCaptions, ['1. Parafuso 8mm', '2. Bucha 8']);
  });
}
