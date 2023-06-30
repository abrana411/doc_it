import 'package:doc_it/constants.dart';
import 'package:doc_it/models/doc_model.dart';
import 'package:doc_it/models/error_model.dart';
import 'package:doc_it/repository/auth_repo.dart';
import 'package:doc_it/repository/doc_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOutUser(WidgetRef ref) {
    //Call signout method:
    ref.read(authRepoProvider).signUserOut();

    //Update the userProvider and make it null (and since we update it , so the main file will rebuild again too , since there we are
    //using the userProvider to get the user!=null and token stuff , so as soon as we click signout button then that will rebuild and the
    //user will be null now since updated , so will redirected to '/' route of the loggedOutScreen from the material.route())
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createNewDoc(WidgetRef ref, BuildContext context) async {
    final token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final scafMsg = ScaffoldMessenger.of(context);
    final errorModel = await ref.read(docRepoProvider).createDocument(token);
    if (errorModel.error == null && errorModel.data != null) {
      //Then we have new document created so navigate to the document screen with the id passed in the route
      navigator.push('/doc/${errorModel.data.id}');
    } else {
      scafMsg.showSnackBar(
        SnackBar(
          content: Text(
            errorModel.error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg1Color,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              createNewDoc(ref, context);
            },
            icon: const Icon(Icons.add),
            color: Colors.black,
          ),
          IconButton(
            onPressed: () {
              signOutUser(ref);
            },
            icon: const Icon(Icons.logout_sharp),
            color: Colors.red,
          ),
        ],
      ),
      body: Center(
        //Do what we could have done is get the user documents and store it in a errorModel tyep variable and then get the list of ducments from it whcih will be .data
        //and until we have that as null we will show a loader here else the same part we are doing after waiting state here ie the docuemnt (after iterating through them)
        //But another thing which we can do if we have to await some list or some data is future builder, so we are awaiting until future condition does not fullfils since it is an async req,
        //so getting document in it , and till we do not have that the id() ie waiting state will be there and a loader will be seen , else we will show a list view builder
        child: FutureBuilder<ErrorModel>(
          //getUser(token) using ref
          future: ref.watch(docRepoProvider).getUserDocs(
                ref.watch(userProvider)!.token,
              ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            //The snapsht.data is what we get in future after awaiting ie ErrorModel
            //so that .data is the list of documents ie snapshot.data.data so have to work on it
            //and snapshot.data.data[index] is a single document
            return Center(
              //a normal centered listview builder showing the titles of the docuemtn user has created
              child: Container(
                width: 600,
                margin: const EdgeInsets.only(top: 10),
                child: ListView.builder(
                  itemCount: snapshot.data!.data.length,
                  itemBuilder: (context, index) {
                    DocModel document = snapshot.data!.data[index];

                    return InkWell(
                      onTap: () {
                        final navigator = Routemaster.of(context);
                        navigator.push('/doc/${document.id}');
                      },
                      child: SizedBox(
                        height: 50,
                        child: Card(
                          child: Center(
                            child: Text(
                              document.title,
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
