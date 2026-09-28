import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/features/contacts/presentation/bloc/contact_bloc.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/presentation/bloc/inquiry_bloc.dart';
import 'package:olie/features/inquiries/presentation/screens/inquiry_navigation.dart';
import 'package:olie/features/inquiries/presentation/widgets/inquiry_row.dart';

enum _Kind { all, real, simulated }

/// Histórico de consultas, com busca por item e filtros por tipo, data e
/// categoria.
class InquiriesView extends StatefulWidget {
  const InquiriesView({super.key});

  @override
  State<InquiriesView> createState() => _InquiriesViewState();
}

class _InquiriesViewState extends State<InquiriesView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _apply(InquiryFilter filter) {
    context.read<InquiryBloc>().add(InquiriesRequested(filter: filter));
  }

  InquiryFilter _copy(
    InquiryFilter current, {
    DateTime? from,
    DateTime? to,
    bool clearDates = false,
    String? categoryId,
    bool clearCategory = false,
    String? item,
    bool? simulated,
    bool clearSimulated = false,
  }) {
    return InquiryFilter(
      from: clearDates ? null : from ?? current.from,
      to: clearDates ? null : to ?? current.to,
      categoryId: clearCategory ? null : categoryId ?? current.categoryId,
      item: item ?? current.item,
      simulated: clearSimulated ? null : simulated ?? current.simulated,
    );
  }

  Future<void> _pickDates(InquiryFilter filter) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: filter.from == null || filter.to == null
          ? null
          : DateTimeRange(start: filter.from!, end: filter.to!),
    );
    if (range == null) return;
    _apply(_copy(filter, from: range.start, to: range.end));
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ContactBloc>().state.categories;

    return BlocBuilder<InquiryBloc, InquiryState>(
      builder: (context, state) {
        final filter = state.filter;
        final kind = switch (filter.simulated) {
          null => _Kind.all,
          true => _Kind.simulated,
          false => _Kind.real,
        };

        return RefreshIndicator(
          onRefresh: () async => _apply(filter),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Buscar por item consultado',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _apply(_copy(filter, item: ''));
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                  onSubmitted: (value) => _apply(_copy(filter, item: value)),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    SegmentedButton<_Kind>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: _Kind.all, label: Text('Todas')),
                        ButtonSegment(value: _Kind.real, label: Text('Envios')),
                        ButtonSegment(
                          value: _Kind.simulated,
                          label: Text('Simulações'),
                        ),
                      ],
                      selected: {kind},
                      onSelectionChanged: (selection) {
                        final selected = selection.first;
                        _apply(
                          selected == _Kind.all
                              ? _copy(filter, clearSimulated: true)
                              : _copy(
                                  filter,
                                  simulated: selected == _Kind.simulated,
                                ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    InputChip(
                      avatar: const Icon(Icons.date_range, size: 18),
                      label: Text(
                        filter.from == null || filter.to == null
                            ? 'Período'
                            : '${formatShortDate(filter.from!)} – '
                                  '${formatShortDate(filter.to!)}',
                      ),
                      onPressed: () => _pickDates(filter),
                      onDeleted: filter.from == null
                          ? null
                          : () => _apply(_copy(filter, clearDates: true)),
                    ),
                    for (final category in categories) ...[
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(category.name),
                        selected: filter.categoryId == category.id,
                        onSelected: (selected) => _apply(
                          selected
                              ? _copy(filter, categoryId: category.id)
                              : _copy(filter, clearCategory: true),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (state.status == InquiryStatusView.loading &&
                  state.inquiries.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.inquiries.isEmpty)
                EmptyHint(
                  title: filter.isEmpty
                      ? 'Nenhuma consulta ainda.'
                      : 'Nenhuma consulta com esses filtros.',
                  hint: filter.isEmpty
                      ? 'Pergunte a vários contatos de uma vez se têm um item '
                            '— com fotos, pelo WhatsApp. Experimente simular '
                            'antes do primeiro envio.'
                      : null,
                ),
              for (final inquiry in state.inquiries) ...[
                InquiryRow(
                  key: ValueKey(inquiry.id),
                  inquiry: inquiry,
                  onTap: () => openInquiryDetail(context, inquiry.id),
                ),
                const Divider(indent: 20),
              ],
            ],
          ),
        );
      },
    );
  }
}
