import 'dart:async';

import 'package:doc_it/constants.dart';
import 'package:doc_it/models/error_model.dart';
import 'package:doc_it/repository/auth_repo.dart';
import 'package:doc_it/repository/doc_repo.dart';
import 'package:doc_it/repository/socket_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:routemaster/routemaster.dart'; //since it has some common dependencies so , in order to work without having any issue , we are naming the import

class DocumentScreen extends ConsumerStatefulWidget {
  final String docId;
  const DocumentScreen({super.key, required this.docId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final TextEditingController _titlecontroller =
      TextEditingController(text: "Untitles document");
  quill.QuillController? _quillController;
  ErrorModel? docData;
  bool isError = false;
  //fethcing the data of this document whevever this screen builds (so that when we update some changes in the data base it shows here if we refresh the page)

  //getting the socket :-
  SocketRepo socketRepo =
      SocketRepo(); //This will get the sockeClient to get the insatnce of the SocketClient class so the connection should be made if havenot

  final StreamController<String> _documentUpdatesController =
      StreamController<String>();
  @override
  void initState() {
    super.initState();
    // print("wow");
    socketRepo.joinRoom(widget
        .docId); //Joining the room with this docId (ie the current application client joined this sokect connection with this doc id)
    fethctheDocData();

    //This below function will run whenever there is some event fired by the server namely "changes" to collect the data from their which is being broadcasted
    socketRepo.changeListener((data) => {
          //This is the function which we have to pass , and we will receive the data from the server side as it was broadcasted

          //Now have to compose the controller of the quill (using the data which can be done like below) and this compose function has notify listener for the text editor document so it will get rebuild
          _quillController?.compose(
            //will append the newly changed delta ie the item2 in the listener say to the existing document delta
            quill.Delta.fromJson(data[
                'delta']), //The data we will send in the typing will have a delta property (which is what the quill document wants (it is just a document model kind of thing) and the other will be room , here using the delta)
            _quillController?.selection ??
                const TextSelection.collapsed(
                    offset: 0), //a selection is also needed
            quill.ChangeSource
                .REMOTE, //this is very important as it is telling that the source of the change in the controller or the document is remote now , because we have got some data now , but this data comes from some other client working , so this is not the local change, because if we dont pass remote here then the place where we are using the typing event caller , we will fire the event again so , if a->made change , b->gets it here , then b thinks it is the change made by 'b' so it sends to a again and this keeps on going , so prevent that we have this
          )
        });

    //Saving the data every 3 seconds:-
    Timer.periodic(const Duration(seconds: 5), (timer) {
      socketRepo.saveDoc(<String, dynamic>{
        'delta': _quillController!.document
            .toDelta(), //this is how we can get the delata of the current document from the controller
        'room': widget
            .docId, //passing the current doc id (as we want to save this only)
      });
    });

    //listening to save changes:-
    socketRepo.listenSave(
      (date) => {_documentUpdatesController.add(date)},
    );
  }

  fethctheDocData() async {
    final token = ref.read(userProvider)!.token;
    docData = await ref
        .read(docRepoProvider)
        .getDocData(docId: widget.docId, token: token);
    if (docData!.error == null && docData!.data != null) {
      _titlecontroller.text = docData!.data
          .title; //we know the data is docModel , and to get title automatically can do (docData!.data as DocModel).title
      //ie there is no error:
      final currcontent = docData!.data
          .content; //Content is the content of the document , (we have this property in the model)

      //If we have content then create a document from delta (it is a model which represent a document say) so we have to create it using the passed content and if null then we will use empty document
      _quillController = quill.QuillController(
          document: currcontent.isEmpty
              ? quill.Document()
              : quill.Document.fromDelta(quill.Delta.fromJson(currcontent)),
          selection: const TextSelection.collapsed(offset: 0));
    } else {
      isError = true;
    }
    setState(() {});

    //Listening to the changes made in the document here
    _quillController!.document.changes.listen((event) {
      //The event is a tuple having three things:-
      /*
         1) A delta (ie some document's data) -> it is the entire document data
         2) A detla -> But it is just the newly added changed (not the entire) say we have "ab" typed and we did "abc" now so this delta will have "c" only
         3) Source of the change -> if local? then it means the change is made by the user using this window , else if remote(then set by some other client , have described it in the compose method while listening to the change)
        */
      if (event.item3 == quill.ChangeSource.LOCAL) {
        //Only if changes are local then we want to broadcast them
        Map<String, dynamic> map = {
          'delta': event
              .item2, //item2 only as we dont want the entore doc to be sent each time , only the newly changed part is enough (and the compose will take care of appending the new data over existing)
          'room': widget
              .docId, //the room will have the doc id of this current docuement only , so that these changes will be broadcasted to all the clients accessing this current document only
        };
        socketRepo.typing(map); //firing the typing event
      }
    });
  }

  //Update the title:-
  updateTitle(String newTitle) async {
    final token = ref.read(userProvider)!.token;
    final scafMsg = ScaffoldMessenger.of(context);
    final errorModel = await ref
        .read(docRepoProvider)
        .updateDoctitle(docId: widget.docId, newTitle: newTitle, token: token);
    if (errorModel.error != null && errorModel.data == null) {
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
    //If we do not have the controller (which we will not for some time until the fetch request is not made , then we will show loader for that time period)
    if (_quillController == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Saving the title too:-
          updateTitle(_titlecontroller.text);

          //Saving the doc on cliking too:-
          socketRepo.saveDoc(<String, dynamic>{
            'delta': _quillController!.document.toDelta(),
            'room': widget.docId,
          });
        },
        backgroundColor: Colors.blue, // Customize the button background color
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.save,
          size: 25,
        ),
      ),
      appBar: AppBar(
        backgroundColor: bg1Color,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                //using clipboard.setData we can copy some data to the clipboard of the device , and the data is the link here which is nothing
                //but the initialUrl/doc/id of doc
                Clipboard.setData(ClipboardData(
                        text: 'http://localhost:3000/#/doc/${widget.docId}'))
                    .then((value) {
                  //After copying sending the message that the link is copied successfully
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Link copied!',
                        style: TextStyle(color: Colors.blue),
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
                backgroundColor: Colors.green.withOpacity(0.9),
              ),
            ),
          ),
        ],
        leadingWidth: MediaQuery.of(context).size.width * 0.7,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Routemaster.of(context).replace('/');
                },
                child: Image.asset(
                  'assets/images/logo.png',
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 180,
                child: TextField(
                    controller: _titlecontroller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      contentPadding: const EdgeInsets.only(left: 10),
                    ),
                    onSubmitted: (value) {
                      updateTitle(value);
                    }),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 0.1,
              ),
            ),
          ),
        ),
      ),
      body: isError
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  quill.QuillToolbar.basic(controller: _quillController!),
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 12,
                    child: SizedBox(
                      width: 750,
                      child: Card(
                        color: bg1Color,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: quill.QuillEditor.basic(
                            controller: _quillController!,
                            readOnly: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.black.withOpacity(0.9),
                        // height: 100,
                        child: Center(
                          child: StreamBuilder<String>(
                            stream: _documentUpdatesController.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                // Use the data from the stream to display the "last saved on" message
                                return Text(
                                  'Last Saved On: ${snapshot.data}',
                                  style: const TextStyle(color: Colors.blue),
                                );
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red),
                                );
                              } else {
                                // Handle the case when there's no data yet
                                return const Text(
                                  'Not saved yet!',
                                  style: TextStyle(color: Colors.red),
                                );
                              }
                            },
                          ),
                        ),
                      ))
                ],
              ),
            ),
    );
  }
}
