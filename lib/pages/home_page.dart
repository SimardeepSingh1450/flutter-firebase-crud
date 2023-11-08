import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecrud/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore service
  final FirestoreService firestoreService = FirestoreService();

  //text controller
  final TextEditingController textController = TextEditingController();

  //open a dailogbox to add a note
  void openNoteBox({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  //button to save
                  ElevatedButton(
                      onPressed: () {
                        if (docID == null) {
                          //add a new note
                          firestoreService.addNote(textController.text);
                        } else {
                          //update an existing note
                          firestoreService.updateNote(
                              docID, textController.text);
                        }
                        //clear the text controller
                        textController.clear();

                        //close the box
                        Navigator.pop(context);
                      },
                      child: Text("ADD"))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Notes")),
      floatingActionButton: FloatingActionButton(
          onPressed: openNoteBox, child: const Icon(Icons.add)),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNotesStream(),
          builder: (context, snapshot) {
            //if we hav data,get all the docs
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;

              //display as a list
              return ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    //get each individual doc
                    DocumentSnapshot document = notesList[index];
                    String docID = document.id;

                    //get note from each doc
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String noteText = data['note'];

                    //display as a list tile
                    return ListTile(
                        title: Text(noteText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //update button
                            IconButton(
                              onPressed: () => openNoteBox(docID: docID),
                              icon: const Icon(Icons.settings),
                            ),

                            //delete button
                            IconButton(
                              onPressed: () =>
                                  firestoreService.deleteNote(docID),
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ));
                  });
            } else {
              //no data
              return Text("NO NOTES...");
            }
          }),
    );
  }
}
