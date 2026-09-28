import 'package:equatable/equatable.dart';

class InquiryIdParams extends Equatable {
  final String id;

  const InquiryIdParams(this.id);

  @override
  List<Object?> get props => [id];
}
