import 'package:flutter_bloc/flutter_bloc.dart';

class PasswordVisibilityState {
  final bool showPassword;
  final bool showConfirmPassword;

  const PasswordVisibilityState({
    this.showPassword = false,
    this.showConfirmPassword = false,
  });

  PasswordVisibilityState copyWith({
    bool? showPassword,
    bool? showConfirmPassword,
  }) {
    return PasswordVisibilityState(
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
    );
  }
}

class PasswordCubit extends Cubit<PasswordVisibilityState> {
  PasswordCubit() : super(const PasswordVisibilityState());

  void togglePassword() =>
      emit(state.copyWith(showPassword: !state.showPassword));

  void toggleConfirmPassword() =>
      emit(state.copyWith(showConfirmPassword: !state.showConfirmPassword));
}
