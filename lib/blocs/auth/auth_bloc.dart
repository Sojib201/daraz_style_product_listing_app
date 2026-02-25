// lib/blocs/auth/auth_bloc.dart
//
// Owns authentication state. On successful login the API returns a token;
// we immediately fetch user #1 (Fakestoreapi uses fixed users; real apps
// would decode the JWT to get userId).

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../repositories/api_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiRepository _repo;

  AuthBloc(this._repo) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final token = await _repo.login(
        username: event.username,
        password: event.password,
      );
      // Fakestoreapi has users 1–10; using id=1 as the demo account.
      final user = await _repo.getUser(1);
      emit(AuthAuthenticated(token: token, user: user));
    } catch (e) {
      emit(AuthFailure(_mapError(e)));
    }
  }

  void _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }

  String _mapError(Object e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) return 'Invalid username or password.';
      if (e.type == DioExceptionType.connectionTimeout) {
        return 'Connection timed out. Check your internet.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}


