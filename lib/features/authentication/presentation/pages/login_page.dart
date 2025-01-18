import 'package:drumm_app/features/authentication/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/sign_in/sign_in_event.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/sign_in/sign_in_state.dart';
import 'package:drumm_app/features/authentication/presentation/widgets/policy_text_widget.dart';
import 'package:drumm_app/injection_container.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocProvider<SignInBloc>(
        create: (context) => s1(),
        child: BlocListener<SignInBloc, SignInState>(
          listener: (BuildContext context, state) {
            if (state is SignInCompleted) {
              context.go(state.route ?? "/");
            }
          },
          child: BlocBuilder<SignInBloc, SignInState>(
            builder: (BuildContext blocContext, state) {
              //print("Sign In State is ${state}");
              String apple = (state is SignInIdle)
                  ? "Continue with Apple"
                  : "Signing in with apple...";
              String google = (state is SignInIdle)
                  ? "Continue with Google"
                  : "Signing in with google...";
              bool showAppleSignInButton = (state is SignInIdle)
                  ? true
                  : (state is AppleSignInitiated)
                      ? true
                      : (state is SignInCompleted)
                          ? true
                          : false;
              bool showGoogleSignInButton = (state is SignInIdle)
                  ? true
                  : (state is GoogleSignInitiated)
                      ? true
                      : (state is SignInCompleted)
                          ? true
                          : false;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 1.75,
                      child: Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                          height: 200,
                          width: 200,
                          fit: BoxFit.contain,
                          color: Colors.white, //Color(0xD8181818),
                          "images/logo_background_white.png",
                        ),
                      ),
                    ),
                  ),
                  if (showAppleSignInButton)
                    GestureDetector(
                      onTap: () {
                        blocContext.read<SignInBloc>().add(SignInWithApple());
                      },
                      child: getSignInButton(apple, context),
                    ),
                  SizedBox(
                    height: 12,
                  ),
                  if (showGoogleSignInButton)
                    GestureDetector(
                      onTap: () {
                        blocContext.read<SignInBloc>().add(SignInWithGoogle());
                      },
                      child: getSignInButton(google, context),
                    ),
                  SizedBox(
                    height: 16,
                  ),
                  PolicyTextWidget(),
                  SizedBox(
                    height: 100,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Container getSignInButton(String btnText, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      margin: EdgeInsets.symmetric(horizontal: 32),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade900, width: 2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            btnText,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: APP_FONT_MEDIUM),
          ),
          Icon(
            Icons.navigate_next_rounded,
            color: Colors.white,
          )
        ],
      ),
    );
  }
}
