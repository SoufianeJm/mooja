import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/auth_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class AuthReset extends AuthEvent {
  const AuthReset();
}

class CheckStoredAuth extends AuthEvent {
  const CheckStoredAuth();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final String token;
  final Map<String, dynamic> user;

  const AuthSuccess({required this.token, required this.user});

  @override
  List<Object?> get props => [token, user];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<AuthReset>(_onAuthReset);
    on<CheckStoredAuth>(_onCheckStoredAuth);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await _authService.login(
        username: event.username,
        password: event.password,
      );

      if (result.isSuccess) {
        if (!isClosed) {
          emit(AuthSuccess(token: result.token!, user: result.user!));
        }
      } else {
        if (!isClosed) {
          emit(AuthFailure(result.message!));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(const AuthFailure('Something went wrong. Please try again.'));
      }
    }
  }

  void _onAuthReset(AuthReset event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }

  Future<void> _onCheckStoredAuth(
    CheckStoredAuth event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final storedAuth = await _authService.getStoredAuth();
      if (storedAuth != null && storedAuth.isSuccess) {
        if (!isClosed) {
          emit(AuthSuccess(token: storedAuth.token!, user: storedAuth.user!));
        }
      }
    } catch (e) {
      // If there's an error checking stored auth, just stay in initial state
      if (!isClosed) {
        emit(const AuthInitial());
      }
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout();
    if (!isClosed) {
      emit(const AuthInitial());
    }
  }
}
