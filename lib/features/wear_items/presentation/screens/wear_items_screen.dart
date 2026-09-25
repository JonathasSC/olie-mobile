import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/features/wear_items/domain/entities/wear_status.dart';
import 'package:olie/features/wear_items/presentation/bloc/wear_item_bloc.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_item_form.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_item_list_item.dart';

class WearItemsScreen extends StatefulWidget {
  const WearItemsScreen({super.key});

  @override
  State<WearItemsScreen> createState() => _WearItemsScreenState();
}

class _WearItemsScreenState extends State<WearItemsScreen> {
  bool _isAdding = false;

  void _toggleFilter(Set<WearStatus> current, WearStatus status) {
    final next = {...current};
    if (!next.remove(status)) next.add(status);
    context.read<WearItemBloc>().add(WearItemsRequested(statuses: next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controle de desgaste')),
      floatingActionButton: _isAdding
          ? null
          : FloatingActionButton(
              onPressed: () => setState(() => _isAdding = true),
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          if (_isAdding)
            WearItemForm(
              submitLabel: 'Adicionar',
              onCancel: () => setState(() => _isAdding = false),
              onSubmit:
                  ({
                    required name,
                    required expectedLifespan,
                    required expectedLifespanUnit,
                    required purchaseDate,
                    installationDate,
                    purchaseValue,
                  }) {
                    setState(() => _isAdding = false);
                    context.read<WearItemBloc>().add(
                      WearItemAdded(
                        name: name,
                        expectedLifespan: expectedLifespan,
                        expectedLifespanUnit: expectedLifespanUnit,
                        purchaseDate: purchaseDate,
                        installationDate: installationDate,
                        purchaseValue: purchaseValue,
                      ),
                    );
                  },
            ),
          BlocBuilder<WearItemBloc, WearItemState>(
            buildWhen: (previous, current) =>
                previous.statusFilter != current.statusFilter,
            builder: (context, state) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    for (final status in WearStatus.values) ...[
                      FilterChip(
                        label: Text(status.label),
                        selected: state.statusFilter.contains(status),
                        onSelected: (_) =>
                            _toggleFilter(state.statusFilter, status),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: BlocConsumer<WearItemBloc, WearItemState>(
              listener: (context, state) {
                if (state.status == WearItemStatus.failure &&
                    state.errorMessage != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                }
              },
              builder: (context, state) {
                if (state.status == WearItemStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.items.isEmpty) {
                  return Center(
                    child: Text(
                      state.statusFilter.isEmpty
                          ? 'Nenhum item de desgaste por aqui ainda.'
                          : 'Nenhum item com esse status.',
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    final bloc = context.read<WearItemBloc>();
                    return WearItemListItem(
                      key: ValueKey(item.id),
                      item: item,
                      history: state.histories[item.id],
                      onSave:
                          ({
                            required name,
                            required expectedLifespan,
                            required expectedLifespanUnit,
                            required purchaseDate,
                            installationDate,
                            purchaseValue,
                          }) {
                            bloc.add(
                              WearItemUpdated(
                                id: item.id,
                                name: name,
                                expectedLifespan: expectedLifespan,
                                expectedLifespanUnit: expectedLifespanUnit,
                                purchaseDate: purchaseDate,
                                installationDate: installationDate,
                                purchaseValue: purchaseValue,
                              ),
                            );
                          },
                      onReplace:
                          ({
                            required purchaseDate,
                            installationDate,
                            removalDate,
                            purchaseValue,
                            paymentMethod,
                          }) {
                            bloc.add(
                              WearItemReplaced(
                                id: item.id,
                                purchaseDate: purchaseDate,
                                installationDate: installationDate,
                                removalDate: removalDate,
                                purchaseValue: purchaseValue,
                                paymentMethod: paymentMethod,
                              ),
                            );
                          },
                      onHistoryRequested: () =>
                          bloc.add(WearItemHistoryRequested(item.id)),
                      onDelete: () => bloc.add(WearItemDeleted(item.id)),
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
