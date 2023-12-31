import 'package:doc_it/constants.dart';
import 'package:doc_it/repository/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    //Stroring the context part below and before the asyn call because other wise if will give warning of asyn gap , so either we could use context.mounted() or can do like this
    final scaffoldMsg = ScaffoldMessenger.of(context);
    // final navigator = Navigator.of(context); //Before using the routeMaster
    final navigator = Routemaster.of(context); //After using it
    final errorModel = await ref.read(authRepoProvider).getSignedInOnGoogle();
    if (errorModel.error != null) {
      //That is we get some error and not the new user: (so we will show an snack bar)
      scaffoldMsg.showSnackBar(
        SnackBar(
          content: Text(
            errorModel.error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    } else {
      //If we get the user signed in :-
      //1)First we will have to update the userProvider to hold this new user now (so that whenever we read() or watch() the userProvider we get this user's content only)
      ref.read(userProvider.notifier).update((state) =>
          errorModel.data); //Using the userProvider.notifier we can update this

      //Navigate to the home screen now
      // navigator
      //     .push(MaterialPageRoute(builder: (context) => const HomeScreen())); //Before using the route master
      navigator.replace(
          '/'); //after using the route master we only need to specify the route (and based on the condition in the materialApp.route() it will go to the particular router which is applicable currently and inside which the '/' route)
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png"),
            const SizedBox(
              height: 100,
            ),
            ElevatedButton.icon(
              onPressed: () => signInWithGoogle(ref, context),
              icon: Image.asset(
                'assets/images/googleLogo.png',
                height: 20,
              ),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(
                  color: txt1Color,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: bg1Color,
                minimumSize: const Size(150, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
