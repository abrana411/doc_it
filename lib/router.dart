import 'package:doc_it/Screens/Home_Screen.dart';
import 'package:doc_it/Screens/document_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import 'Screens/login_screen.dart';

//Below is the loggedOutRoute and only a single loggedOutRoute is there and which is simply '/' and lead to the login page as if the person is logged out then we only want him/her to navigate to the login screen
final loggedOutRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: LoginScreen()),
});

//logged in routes:-
//1)'/' simply goes to the Home page (ie same '/' in case of logged out leads to the login and here to home , thats is an advantage of using this routeMaster)
final loggedInRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(
      child:
          HomeScreen()), //If in the routebuilder only this loggedInRoute is used then it will always refer to '/' route
  '/doc/:id': (route) => MaterialPage(
        child: DocumentScreen(docId: route.pathParameters['id'] ?? ''),
      ),

  //so thw use od dynamic route is that we can pass in the parameter to the constructor to the route where we are going without actually doing that
  //ie in normal navigator.pushNamed() too we have to specify the argument:the argument to pass whereever we call this, but here we can make use
  //of the routes: like above the doute is /doc/:id so whenever we want to navegate to the Documentscreen we can do like :-
  //routeMaster.push('/doc/1234') where 1234 is the doc Id say , and to capture it and pass it to parameter here we can use the same name as given
  //in the route which is "id" so rote.pathParameter['id'] like this , so can add any number of values like this to route
});
