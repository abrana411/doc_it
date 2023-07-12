import 'dart:convert';

import 'package:doc_it/models/doc_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

import '../constants.dart';
import '../models/error_model.dart';

//Creating provider for this class:-
final docRepoProvider = Provider(
  (ref) => DocRepo(client: Client()),
);

class DocRepo {
  final Client _client;
  DocRepo({
    required Client client,
  }) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    //Will get the user token from the location where we will make the call to this method (because we dont want to make the ref calls in the repository)
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );
    try {
      //a post request to create anew document
      var res = await _client.post(
        Uri.parse('$initialUrl/doc/create'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'User_token': token,
        },
        //in the body we are requiring only the current time
        body: jsonEncode({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        }),
      );
      switch (res.statusCode) {
        case 200:
          //If we get the document created successfully then we will send the data in the error model as from json(res.body) and the error as null
          error = ErrorModel(
            error: null,
            data: DocModel.fromJson(res.body),
          );
          break;
        default:
          //if any error then get the res.body as error and the data as null
          error = ErrorModel(
            error: res.body,
            data: null,
          );
          break;
      }
    } catch (e) {
      // print(e);
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return error;
  }

  //http request to get the document of a user:-
  Future<ErrorModel> getUserDocs(String token) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );
    try {
      //a get request to get all the docs of current user
      var res = await _client.get(
        Uri.parse('$initialUrl/doc/getUser'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'User_token': token,
        },
      );
      switch (res.statusCode) {
        case 200:
          List<DocModel> userdocs = [];
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            userdocs.add(
              DocModel.fromJson(
                jsonEncode(jsonDecode(res.body)[
                    i]), //decode to make map and get ith doc , then convert it to json string using encode and then pass the json string of a doc to fromJson and get a docModel ready and add it to the list
              ),
            );
          }
          error = ErrorModel(
            error: null,
            data: userdocs,
          );
          break;
        default:
          //if any error then get the res.body as error and the data as null
          error = ErrorModel(
            error: res.body,
            data: null,
          );
          break;
      }
    } catch (e) {
      // print(e);
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return error;
  }

  //function to update the document's title:-
  Future<ErrorModel> updateDoctitle(
      {required String newTitle,
      required String docId,
      required String token}) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );
    try {
      var res = await _client.post(Uri.parse('$initialUrl/doc/update/title'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'User_token': token,
          },
          body: jsonEncode({"id": docId, "title": newTitle}));
      switch (res.statusCode) {
        case 200:
          error = ErrorModel(
            error: null,
            data: "true",
          );
          break;
        default:
          error = ErrorModel(
            error: res.body,
            data: null,
          );
          break;
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return error;
  }

  //Function to get a document's data using its id
  Future<ErrorModel> getDocData(
      {required String docId, required String token}) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );
    try {
      var res = await _client.get(
        Uri.parse('$initialUrl/doc/$docId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'User_token': token,
        },
      );
      switch (res.statusCode) {
        case 200:
          error = ErrorModel(
            error: null,
            data: DocModel.fromJson(res.body),
          );
          break;
        default:
          throw "No document with this Id exists, please access a valid document"; //since throwing so the catch below will catch it
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return error;
  }

  //http call to delete a document:-
  Future<ErrorModel> deleteDoc(
      {required String docId, required String token}) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );
    try {
      var res = await _client.delete(
        Uri.parse('$initialUrl/doc/$docId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'User_token': token,
        },
      );
      switch (res.statusCode) {
        case 200:
          error = ErrorModel(
            error: null,
            data: "Deleted",
          );
          break;
        default:
          throw "No document with this Id exists!";
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return error;
  }
}
