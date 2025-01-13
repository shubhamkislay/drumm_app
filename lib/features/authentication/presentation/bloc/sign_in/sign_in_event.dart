abstract class SignInEvent {
  const SignInEvent();
}

class SignInWithApple extends SignInEvent{
  const SignInWithApple();
}

class SignInWithGoogle extends SignInEvent{
  const SignInWithGoogle();
}