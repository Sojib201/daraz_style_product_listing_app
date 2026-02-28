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
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final token = await _repo.login(
        username: event.username,
        password: event.password,
      );
      final user = await _repo.getUser(1);
      emit(AuthAuthenticated(token: token, user: user));
    } catch (e) {
      emit(AuthFailure(_friendlyError(e)));
    }
  }

  void _onLogout(AuthLogoutRequested _, Emitter<AuthState> emit) =>
      emit(const AuthInitial());

  String _friendlyError(Object e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) return 'Wrong username or password.';
      if (e.type == DioExceptionType.connectionTimeout) {
        return 'Connection timed out. Check internet.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
