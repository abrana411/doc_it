import 'dart:convert';

import 'package:doc_it/models/error_model.dart';
import 'package:doc_it/models/user_model.dart';
import 'package:doc_it/repository/local_storage_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import '../constants.dart';

//Getting the provider (from the riverpod) for this class , so that could access the methods and the function easily (and also the paratere have to be passed here only and not everywhere we use this)
final authRepoProvider = Provider(
  //this ref is used when multiple providers are depending on each other
  (ref) => AuthRepo(
    googleSignIn: GoogleSignIn(),
    client:
        Client(), //Passing the client (we can use the http methods like Clent.post(),.get()) and it is better than just directly doing get() or post() because using client we can do unit testing and stuff (have to read more)
    localstore:
        LocalStore(), //Passing the instance of the class here (whose function we will be using (as this way the unit testing is easy if we pass this to constructor directlys))
  ),
);

//Creating a stateProvider (from the riverpod) for the user , what is state provider? it is type of provider which enable us to change the value of the thing bind with provider not just viewing it ...because we may want to change the current users data too
//And we will set new user data to this when the sigup is complete and no error is there ie in the login screen when the signin returned model does not have any error
final userProvider = StateProvider<UserModel?>((ref) => null);
//Also stateprovoder when updated will rebuild the widget in which it is used (in all over the app)

class AuthRepo {
  //Making this private because we dont want this data member to be accessible outside this class scope as this class only will be having the authentication functions
  final GoogleSignIn _googleSignIn;
  //And passing this through constructor because it makes it easy to test the application for various purposes (will see the testing in flutter)
  final Client _client;
  final LocalStore _localStoreRepo;
  AuthRepo({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStore localstore,
  })  : _googleSignIn = googleSignIn,
        _client = client,
        _localStoreRepo = localstore;
  //We cant access the private data member in the constructor too , so to overcome this we have created another variable in which we will be receiving the passed instance of GoogleSignIn and then using : we can ssign that to the private varoable created above

  //Function to signin with google:-
  //we will be returning an Error Model (because we can either have an error here or data to be returned so in case we want to return error then
  //data will be null and vice versa)
  Future<ErrorModel> getSignedInOnGoogle() async {
    ErrorModel error = ErrorModel(
        error: "Some Error occured!", data: null); //in case error occured
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        //Below things we can get when the user is signed in  (so we have to make a post request to save those into the data abse for the user)
        // print(user.displayName);
        // print(user.email);
        // print(user.photoUrl);
        final newUser = UserModel(
            email: user.email,
            name: user.displayName ??
                '', //if null then giving empty string as name and same for below (can give some default value here if want)
            profilePic: user.photoUrl ?? '',
            uid: '',
            token: '');

        //Using client to make the request (rest is normal ,passing body and stuff)
        var res = await _client.post(Uri.parse('$initialUrl/api/signin'),
            body: newUser.toJson(),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            });
        // print(res.body);
        switch (res.statusCode) {
          case 200:
            final newuser = newUser.copyWith(
              //Getting the token and id from the res.body and setting it for thr user
              uid: jsonDecode(res.body)['_id'],
              token: jsonDecode(res.body)['token'],
            );
            _localStoreRepo.saveToken(newuser.token); //saving the token
            error = ErrorModel(
                error: null,
                data:
                    newuser); //now if no error is there then make error as null and pass in the new user (as we will be returning this now)
            break;
        }
      }
    } catch (e) {
      //Passing the error to the error model now before returning
      // print(e.toString());
      error = ErrorModel(error: e.toString(), data: null);
    }

    return error;
  }

  //Http request to get the token:-
  Future<ErrorModel> getUserData() async {
    ErrorModel error = ErrorModel(
        error: "Some Error occured!", data: null); //in case error occured
    try {
      String? token = await _localStoreRepo.getToken();
      if (token != null) {
        //If the token is not null ie there is a token which is stored in the local storage then we will do the get request using this token
        var res = await _client.get(Uri.parse('$initialUrl/'), headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "User_token":
              token //passing the token (the header name should match with what i am using to get the token in server side)
        });
        // print(res.body);
        switch (res.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(res.body);
            error = ErrorModel(error: null, data: newUser);
            break;
        }
      }
    } catch (e) {
      //Passing the error to the error model now before returning
      // print(e.toString());
      error = ErrorModel(error: e.toString(), data: null);
    }

    return error;
  }

  //Signout method:-
  //Two things to do: 1)Singout from google account , 2)Remove the token from the local storage
  //and will use this in home page
  void signUserOut() async {
    await _googleSignIn.signOut();
    _localStoreRepo.saveToken('');
  }
}
