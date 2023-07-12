import 'package:doc_it/constants.dart';
import 'package:doc_it/models/doc_model.dart';
import 'package:doc_it/models/error_model.dart';
import 'package:doc_it/repository/auth_repo.dart';
import 'package:doc_it/repository/doc_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void signOutUser() {
    //Call signout method:
    ref.read(authRepoProvider).signUserOut();

    //Update the userProvider and make it null (and since we update it , so the main file will rebuild again too , since there we are
    //using the userProvider to get the user!=null and token stuff , so as soon as we click signout button then that will rebuild and the
    //user will be null now since updated , so will redirected to '/' route of the loggedOutScreen from the material.route())
    ref.read(userProvider.notifier).update((state) => null);
  }

  void deleteDoc(String docId) {
    ref
        .read(docRepoProvider)
        .deleteDoc(docId: docId, token: ref.read(userProvider)!.token);

    setState(() {});
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
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNewDoc(ref, context);
        },
        backgroundColor:
            Colors.pink[600], // Customize the button background color
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          size: 25,
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: bg1Color,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(125),
        child: AppBar(
          leadingWidth: MediaQuery.of(context).size.width * 0.3,
          // leading: Container(
          //   margin: const EdgeInsets.only(left: 20, top: 20),
          //   child: Image.asset(
          //     "assets/images/logo.png",
          //     // fit: BoxFit.fill,
          //     height: 100,
          //     width: 100,
          //   ),
          // ),
          title: Image.asset(
            "assets/images/logo.png",
            fit: BoxFit.fitHeight,
            height: 120,
          ),

          backgroundColor: bg1Color,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                signOutUser();
              },
              icon: const Icon(Icons.logout_sharp),
              color: Colors.red,
            ),
          ],
        ),
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
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20)),
                        height: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Card(
                            color: Colors.black.withOpacity(0.4),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 30),
                                    alignment: Alignment.center,
                                    child: Text(
                                      document.title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                    text:
                                                        'http://localhost:3000/#/doc/${document.id}'))
                                                .then((value) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Link copied!',
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.lock,
                                            size: 16,
                                          ),
                                          label: const Text('Share'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.green.withOpacity(0.9),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            deleteDoc(document.id);
                                          },
                                          icon: const Icon(Icons.delete),
                                          label: const Text("delete"),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                      padding: const EdgeInsets.only(
                                          left: 10, bottom: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.4)),
                                      alignment: Alignment.bottomLeft,
                                      child: Row(
                                        children: [
                                          const Text("Created at : "),
                                          Text(document.createdAt
                                              .toLocal()
                                              .toString()),
                                        ],
                                      ))
                                ],
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
