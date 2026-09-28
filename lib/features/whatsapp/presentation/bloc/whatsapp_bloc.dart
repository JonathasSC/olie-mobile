import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/whatsapp/domain/entities/whatsapp_connection.dart';
import 'package:olie/features/whatsapp/domain/usecases/connect_whatsapp.dart';
import 'package:olie/features/whatsapp/domain/usecases/disconnect_whatsapp.dart';
import 'package:olie/features/whatsapp/domain/usecases/get_whatsapp_connection.dart';
import 'package:olie/features/whatsapp/domain/usecases/watch_whatsapp_connection.dart';

part 'whatsapp_event.dart';
part 'whatsapp_state.dart';

class WhatsAppBloc extends Bloc<WhatsAppEvent, WhatsAppState> {
  final GetWhatsAppConnection getWhatsAppConnection;
  final ConnectWhatsApp connectWhatsApp;
  final DisconnectWhatsApp disconnectWhatsApp;
  final WatchWhatsAppConnection watchWhatsAppConnection;

  WhatsAppBloc({
    required this.getWhatsAppConnection,
    required this.connectWhatsApp,
    required this.disconnectWhatsApp,
    required this.watchWhatsAppConnection,
  }) : super(const WhatsAppState()) {
    on<WhatsAppStarted>(
      _onStarted,
      // Uma única escuta do WebSocket por bloc, mesmo se reenviado.
      transformer: (events, mapper) => events.take(1).asyncExpand(mapper),
    );
    on<WhatsAppRefreshed>(
      (event, emit) => _run(emit, () => getWhatsAppConnection(const NoParams())),
    );
    on<WhatsAppConnectRequested>(
      (event, emit) => _run(emit, () => connectWhatsApp(const NoParams())),
    );
    on<WhatsAppDisconnectRequested>(
      (event, emit) => _run(emit, () => disconnectWhatsApp(const NoParams())),
    );
  }

  Future<void> _onStarted(
    WhatsAppStarted event,
    Emitter<WhatsAppState> emit,
  ) async {
    emit(state.copyWith(status: WhatsAppStatus.loading));
    await _run(emit, () => getWhatsAppConnection(const NoParams()));

    await emit.forEach<WhatsAppConnection>(
      watchWhatsAppConnection(),
      onData: (connection) => state.copyWith(
        status: WhatsAppStatus.ready,
        connection: connection,
      ),
    );
  }

  Future<void> _run(
    Emitter<WhatsAppState> emit,
    Future<Either<Failure, WhatsAppConnection>> Function() request,
  ) async {
    emit(state.copyWith(busy: true));
    final result = await request();
    result.fold(
      (failure) => emit(state.copyWith(
        status: WhatsAppStatus.failure,
        busy: false,
        errorMessage: failure.message,
      )),
      (connection) => emit(state.copyWith(
        status: WhatsAppStatus.ready,
        busy: false,
        connection: connection,
      )),
    );
  }
}
