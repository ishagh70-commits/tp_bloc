import 'package:flutter_bloc/flutter_bloc.dart';

sealed class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String username;
  LoginSuccess(this.username);
}

class LoginFailure extends LoginState {
  final String message;
  LoginFailure(this.message);
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());

    // Simulation d'un appel API (délai de 2 secondes)
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'test@test.com' && password == '123456') {
      emit(LoginSuccess(email));
    } else {
      emit(LoginFailure('Email ou mot de passe incorrect.'));
    }
  }
}
