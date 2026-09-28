import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/di/injection_container.dart' as di;
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/contacts/presentation/bloc/contact_bloc.dart';
import 'package:olie/features/contacts/presentation/screens/contacts_view.dart';
import 'package:olie/features/contacts/presentation/widgets/contact_sheets.dart';
import 'package:olie/features/home/presentation/screens/today_view.dart';
import 'package:olie/features/inquiries/presentation/bloc/inquiry_bloc.dart';
import 'package:olie/features/inquiries/presentation/screens/inquiries_view.dart';
import 'package:olie/features/inquiries/presentation/screens/inquiry_navigation.dart';
import 'package:olie/features/notes/presentation/bloc/note_bloc.dart';
import 'package:olie/features/notes/presentation/screens/notes_view.dart';
import 'package:olie/features/planned_items/presentation/bloc/planned_item_bloc.dart';
import 'package:olie/features/planned_items/presentation/screens/planned_items_view.dart';
import 'package:olie/features/planned_items/presentation/widgets/planned_item_sheets.dart';
import 'package:olie/features/savings_goals/presentation/bloc/savings_goal_bloc.dart';
import 'package:olie/features/savings_goals/presentation/screens/savings_goals_view.dart';
import 'package:olie/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:olie/features/wear_items/presentation/bloc/wear_item_bloc.dart';
import 'package:olie/features/wear_items/presentation/screens/wear_items_view.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_item_sheets.dart';
import 'package:olie/features/whatsapp/presentation/bloc/whatsapp_bloc.dart';
import 'package:olie/features/whatsapp/presentation/widgets/whatsapp_status_bar.dart';

/// Estrutura do app autenticado: quatro abas que compartilham os mesmos
/// blocs, para que uma mudança em uma aba apareça na aba Hoje.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<TodoBloc>()..add(const TodosRequested()),
        ),
        BlocProvider(
          create: (_) =>
              di.sl<PlannedItemBloc>()..add(const PlannedItemsRequested()),
        ),
        BlocProvider(
          create: (_) =>
              di.sl<SavingsGoalBloc>()..add(const SavingsGoalsRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<WearItemBloc>()..add(const WearItemsRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<NoteBloc>()..add(const NotesRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<ContactBloc>()..add(const ContactsRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<WhatsAppBloc>()..add(const WhatsAppStarted()),
        ),
        BlocProvider(
          create: (_) => di.sl<InquiryBloc>()
            ..add(const InquiriesRequested())
            ..add(const InquiryRealtimeStarted()),
        ),
      ],
      child: const _ErrorReporter(child: _Shell()),
    );
  }
}

/// Mostra num aviso qualquer erro devolvido pela API, de qualquer aba.
class _ErrorReporter extends StatelessWidget {
  final Widget child;

  const _ErrorReporter({required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TodoBloc, TodoState>(
          listenWhen: (_, s) =>
              s.status == TodoStatus.failure && s.errorMessage != null,
          listener: (context, state) => showToast(context, state.errorMessage!),
        ),
        BlocListener<PlannedItemBloc, PlannedItemState>(
          listenWhen: (_, s) =>
              s.status == PlannedItemStatus.failure && s.errorMessage != null,
          listener: (context, state) => showToast(context, state.errorMessage!),
        ),
        BlocListener<SavingsGoalBloc, SavingsGoalState>(
          listenWhen: (_, s) =>
              s.status == SavingsGoalStatus.failure && s.errorMessage != null,
          listener: (context, state) => showToast(context, state.errorMessage!),
        ),
        BlocListener<WearItemBloc, WearItemState>(
          listenWhen: (_, s) =>
              s.status == WearItemStatus.failure && s.errorMessage != null,
          listener: (context, state) => showToast(context, state.errorMessage!),
        ),
        BlocListener<NoteBloc, NoteState>(
          listenWhen: (_, s) =>
              s.status == NoteStatus.failure && s.errorMessage != null,
          listener: (context, state) => showToast(context, state.errorMessage!),
        ),
        BlocListener<ContactBloc, ContactState>(
          listenWhen: (_, s) =>
              s.status == ContactStatus.failure && s.errorMessage != null,
          listener: (context, state) => showToast(context, state.errorMessage!),
        ),
        BlocListener<InquiryBloc, InquiryState>(
          listenWhen: (_, s) =>
              s.status == InquiryStatusView.failure && s.errorMessage != null,
          listener: (context, state) => showToast(context, state.errorMessage!),
        ),
        // Resumo final de uma consulta que terminou (RF32), em qualquer aba.
        BlocListener<InquiryBloc, InquiryState>(
          listenWhen: (previous, current) =>
              current.lastFinished != null &&
              previous.lastFinished != current.lastFinished,
          listener: (context, state) {
            final totals = state.lastFinished!.totals;
            showToast(
              context,
              totals.failed == 0
                  ? 'Consulta concluída: ${totals.sent} enviada(s).'
                  : 'Consulta concluída: ${totals.sent} enviada(s) e '
                        '${totals.failed} com falha.',
            );
          },
        ),
      ],
      child: child,
    );
  }
}

class _Destination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _Destination(this.label, this.icon, this.selectedIcon);
}

const _destinations = [
  _Destination('Hoje', Icons.today_outlined, Icons.today),
  _Destination('Compras', Icons.shopping_bag_outlined, Icons.shopping_bag),
  _Destination('Desgaste', Icons.autorenew_outlined, Icons.autorenew),
  _Destination('Consultas', Icons.forum_outlined, Icons.forum),
  _Destination('Notas', Icons.sticky_note_2_outlined, Icons.sticky_note_2),
];

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final p = OliePalette.of(context);

    final pages = IndexedStack(
      index: _index,
      children: const [
        _Tab(child: TodayView()),
        _ShoppingTab(),
        _WearTab(),
        _InquiriesTab(),
        _Tab(title: 'Notas', eyebrow: 'Anotações da casa', child: NotesView()),
      ],
    );

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: p.surface,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              indicatorColor: p.oliveSoft,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'olie',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(color: p.olive),
                ),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            VerticalDivider(width: 1, color: p.rule),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: pages,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: pages,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

/// Moldura de uma aba: título opcional, conteúdo e botão de ação.
class _Tab extends StatelessWidget {
  final String? title;
  final String? eyebrow;
  final Widget? header;
  final Widget child;
  final Widget? action;

  const _Tab({
    this.title,
    this.eyebrow,
    this.header,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: action,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow != null)
                      Text(
                        eyebrow!.toUpperCase(),
                        style: OlieText.label(context),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
              ),
            ?header,
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

enum _ShoppingSection { list, goals }

class _ShoppingTab extends StatefulWidget {
  const _ShoppingTab();

  @override
  State<_ShoppingTab> createState() => _ShoppingTabState();
}

class _ShoppingTabState extends State<_ShoppingTab> {
  _ShoppingSection _section = _ShoppingSection.list;

  @override
  Widget build(BuildContext context) {
    final isList = _section == _ShoppingSection.list;
    return _Tab(
      title: 'Compras',
      eyebrow: 'O que comprar e quanto guardar',
      header: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: SegmentedButton<_ShoppingSection>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: _ShoppingSection.list,
              label: Text('Planejadas'),
            ),
            ButtonSegment(value: _ShoppingSection.goals, label: Text('Metas')),
          ],
          selected: {_section},
          onSelectionChanged: (s) => setState(() => _section = s.first),
        ),
      ),
      action: Builder(
        builder: (context) => FloatingActionButton.extended(
          onPressed: () => isList
              ? showNewPlannedItemSheet(context)
              : showNewSavingsGoalSheet(context),
          icon: const Icon(Icons.add),
          label: Text(isList ? 'Nova compra' : 'Nova meta'),
        ),
      ),
      child: isList ? const PlannedItemsView() : const SavingsGoalsView(),
    );
  }
}

class _WearTab extends StatelessWidget {
  const _WearTab();

  @override
  Widget build(BuildContext context) {
    return _Tab(
      title: 'Desgaste',
      eyebrow: 'Quando trocar cada coisa',
      action: Builder(
        builder: (context) => FloatingActionButton.extended(
          onPressed: () => showNewWearItemSheet(context),
          icon: const Icon(Icons.add),
          label: const Text('Novo item'),
        ),
      ),
      child: const WearItemsView(),
    );
  }
}

enum _InquiriesSection { inquiries, contacts }

class _InquiriesTab extends StatefulWidget {
  const _InquiriesTab();

  @override
  State<_InquiriesTab> createState() => _InquiriesTabState();
}

class _InquiriesTabState extends State<_InquiriesTab> {
  _InquiriesSection _section = _InquiriesSection.inquiries;

  @override
  Widget build(BuildContext context) {
    final isInquiries = _section == _InquiriesSection.inquiries;
    return _Tab(
      title: 'Consultas',
      eyebrow: 'Quem tem o que você procura',
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WhatsAppStatusBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: SegmentedButton<_InquiriesSection>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: _InquiriesSection.inquiries,
                  label: Text('Consultas'),
                ),
                ButtonSegment(
                  value: _InquiriesSection.contacts,
                  label: Text('Contatos'),
                ),
              ],
              selected: {_section},
              onSelectionChanged: (s) => setState(() => _section = s.first),
            ),
          ),
        ],
      ),
      action: Builder(
        builder: (context) => FloatingActionButton.extended(
          onPressed: () => isInquiries
              ? openNewInquiry(context)
              : showNewContactSheet(context),
          icon: Icon(isInquiries ? Icons.send : Icons.person_add_alt),
          label: Text(isInquiries ? 'Nova consulta' : 'Novo contato'),
        ),
      ),
      child: isInquiries ? const InquiriesView() : const ContactsView(),
    );
  }
}
