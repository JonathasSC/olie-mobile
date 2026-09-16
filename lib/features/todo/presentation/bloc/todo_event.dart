part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class TodosRequested extends TodoEvent {
  const TodosRequested();
}

class TodoAdded extends TodoEvent {
  final String title;

  const TodoAdded(this.title);

  @override
  List<Object?> get props => [title];
}

class TodoToggled extends TodoEvent {
  final String id;

  const TodoToggled(this.id);

  @override
  List<Object?> get props => [id];
}

class TodoDeleted extends TodoEvent {
  final String id;

  const TodoDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
