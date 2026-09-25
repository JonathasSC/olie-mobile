import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item_detail.dart';
import 'package:olie/features/wear_items/domain/repositories/wear_item_repository.dart';

class GetWearItemDetail
    implements UseCase<WearItemDetail, GetWearItemDetailParams> {
  final WearItemRepository repository;

  GetWearItemDetail(this.repository);

  @override
  Future<Either<Failure, WearItemDetail>> call(GetWearItemDetailParams params) {
    return repository.getWearItemDetail(params.id);
  }
}

class GetWearItemDetailParams extends Equatable {
  final String id;

  const GetWearItemDetailParams(this.id);

  @override
  List<Object?> get props => [id];
}
