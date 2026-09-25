import 'package:equatable/equatable.dart';

import 'package:olie/features/wear_items/domain/entities/wear_cycle.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';

/// Resposta de `GET /wear-items/{id}`: o item acrescido dos ciclos
/// encerrados, do mais recente para o mais antigo.
class WearItemDetail extends Equatable {
  final WearItem item;
  final List<WearCycle> history;

  const WearItemDetail({required this.item, required this.history});

  @override
  List<Object?> get props => [item, history];
}
