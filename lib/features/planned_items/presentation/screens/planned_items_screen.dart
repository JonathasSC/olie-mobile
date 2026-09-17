import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/features/planned_items/presentation/bloc/planned_item_bloc.dart';
import 'package:olie/features/planned_items/presentation/widgets/planned_item_form.dart';
import 'package:olie/features/planned_items/presentation/widgets/planned_item_list_item.dart';

class PlannedItemsScreen extends StatefulWidget {
  const PlannedItemsScreen({super.key});

  @override
  State<PlannedItemsScreen> createState() => _PlannedItemsScreenState();
}

class _PlannedItemsScreenState extends State<PlannedItemsScreen> {
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Itens planejados')),
      floatingActionButton: _isAdding
          ? null
          : FloatingActionButton(
              onPressed: () => setState(() => _isAdding = true),
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          if (_isAdding)
            PlannedItemForm(
              submitLabel: 'Adicionar',
              onCancel: () => setState(() => _isAdding = false),
              onSubmit:
                  ({
                    required name,
                    required priority,
                    required estimatedValue,
                    required estimatedDate,
                  }) {
                    setState(() => _isAdding = false);
                    context.read<PlannedItemBloc>().add(
                      PlannedItemAdded(
                        name: name,
                        priority: priority,
                        estimatedValue: estimatedValue,
                        estimatedDate: estimatedDate,
                      ),
                    );
                  },
            ),
          Expanded(
            child: BlocConsumer<PlannedItemBloc, PlannedItemState>(
              listener: (context, state) {
                if (state.status == PlannedItemStatus.failure &&
                    state.errorMessage != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                }
              },
              builder: (context, state) {
                if (state.status == PlannedItemStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.items.isEmpty) {
                  return const Center(
                    child: Text('Nenhum item planejado por aqui ainda.'),
                  );
                }

                return ListView.separated(
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return PlannedItemListItem(
                      key: ValueKey(item.id),
                      item: item,
                      onSave:
                          ({
                            required name,
                            required priority,
                            required estimatedValue,
                            required estimatedDate,
                          }) {
                            context.read<PlannedItemBloc>().add(
                              PlannedItemUpdated(
                                id: item.id,
                                name: name,
                                priority: priority,
                                estimatedValue: estimatedValue,
                                estimatedDate: estimatedDate,
                              ),
                            );
                          },
                      onComplete: ({required paymentMethod, value}) {
                        context.read<PlannedItemBloc>().add(
                          PlannedItemCompleted(
                            id: item.id,
                            paymentMethod: paymentMethod,
                            value: value,
                          ),
                        );
                      },
                      onDelete: () => context.read<PlannedItemBloc>().add(
                        PlannedItemDeleted(item.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
