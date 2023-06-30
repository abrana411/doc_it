import 'package:doc_it/Screens/Home_Screen.dart';
import 'package:doc_it/Screens/login_screen.dart';
import 'package:doc_it/models/error_model.dart';
import 'package:doc_it/repository/auth_repo.dart';
import 'package:doc_it/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  //stateful -> Consumerstateful if want to use the riverpof ref (for getting the providers)
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ErrorModel? errModel;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    errModel = await ref.read(authRepoProvider).getUserData();
    if (errModel != null &&
        errModel!.data !=
            null) //then it means there is actually a user token (valid) prsent since we got the data , so we will simply update the user provider and will navigate to main page (not to the login page) by using this userProvider only since set here (else it will be null if no user is there)
    {
      ref.read(userProvider.notifier).update((state) => errModel!
          .data); //This will work as listen:true , so it will rebuild the widget (thats why this is called stateProvider)
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      //will use this instead of materialApp only since we will be setting up a router using routeMaster pacakge which simply uses the router 2.0 under the hood
      title: 'DocIt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //there is no home in this:
      routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
        //if a user is there then we will get this as not null and token as not null too so then we can navigate to the
        final currUser = ref.watch(userProvider);
        if (currUser != null && currUser.token.isNotEmpty) {
          return loggedInRoute; //using only the loggenInRoute name here we will go to the '/' route so this has to be there as deafult which is there
        } else {
          return loggedOutRoute;
        }
      }),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
