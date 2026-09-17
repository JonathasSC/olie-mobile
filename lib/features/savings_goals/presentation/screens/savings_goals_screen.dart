import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/di/injection_container.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/usecases/get_planned_items.dart';
import 'package:olie/features/savings_goals/presentation/bloc/savings_goal_bloc.dart';
import 'package:olie/features/savings_goals/presentation/widgets/savings_goal_form.dart';
import 'package:olie/features/savings_goals/presentation/widgets/savings_goal_list_item.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  bool _isAdding = false;
  late final Future<List<PlannedItem>> _plannedItemsFuture;

  @override
  void initState() {
    super.initState();
    _plannedItemsFuture = _loadPlannedItems();
  }

  Future<List<PlannedItem>> _loadPlannedItems() async {
    final result = await sl<GetPlannedItems>()(const NoParams());
    return result.fold((_) => const [], (items) => items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metas de economia')),
      floatingActionButton: _isAdding
          ? null
          : FloatingActionButton(
              onPressed: () => setState(() => _isAdding = true),
              child: const Icon(Icons.add),
            ),
      body: FutureBuilder<List<PlannedItem>>(
        future: _plannedItemsFuture,
        builder: (context, snapshot) {
          final plannedItems = snapshot.data ?? const <PlannedItem>[];

          return Column(
            children: [
              if (_isAdding)
                SavingsGoalForm(
                  plannedItems: plannedItems,
                  submitLabel: 'Adicionar',
                  onCancel: () => setState(() => _isAdding = false),
                  onSubmit:
                      ({
                        required name,
                        required amount,
                        required period,
                        plannedItemId,
                      }) {
                        setState(() => _isAdding = false);
                        context.read<SavingsGoalBloc>().add(
                          SavingsGoalAdded(
                            name: name,
                            amount: amount,
                            period: period,
                            plannedItemId: plannedItemId,
                          ),
                        );
                      },
                ),
              Expanded(
                child: BlocConsumer<SavingsGoalBloc, SavingsGoalState>(
                  listener: (context, state) {
                    if (state.status == SavingsGoalStatus.failure &&
                        state.errorMessage != null) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(content: Text(state.errorMessage!)),
                        );
                    }
                  },
                  builder: (context, state) {
                    if (state.status == SavingsGoalStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.goals.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma meta de economia por aqui ainda.'),
                      );
                    }

                    return ListView.separated(
                      itemCount: state.goals.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final goal = state.goals[index];
                        return SavingsGoalListItem(
                          key: ValueKey(goal.id),
                          goal: goal,
                          plannedItems: plannedItems,
                          onSave:
                              ({
                                required name,
                                required amount,
                                required period,
                                plannedItemId,
                              }) {
                                context.read<SavingsGoalBloc>().add(
                                  SavingsGoalUpdated(
                                    id: goal.id,
                                    name: name,
                                    amount: amount,
                                    period: period,
                                    plannedItemId: plannedItemId,
                                  ),
                                );
                              },
                          onDelete: () => context.read<SavingsGoalBloc>().add(
                            SavingsGoalDeleted(goal.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
