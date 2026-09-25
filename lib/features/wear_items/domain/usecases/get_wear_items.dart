import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';
import 'package:olie/features/wear_items/domain/repositories/wear_item_repository.dart';

class GetWearItems implements UseCase<List<WearItem>, GetWearItemsParams> {
  final WearItemRepository repository;

  GetWearItems(this.repository);

  @override
  Future<Either<Failure, List<WearItem>>> call(GetWearItemsParams params) {
    return repository.getWearItems(statuses: params.statuses);
  }
}

class GetWearItemsParams extends Equatable {
  /// Vazio = sem filtro (todos os status).
  final Set<WearStatus> statuses;

  const GetWearItemsParams({this.statuses = const {}});

  @override
  List<Object?> get props => [statuses];
}
