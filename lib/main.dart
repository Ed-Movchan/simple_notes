import 'package:flutter/material.dart';
import 'package:simple_notes/db/database.dart';
import 'package:simple_notes/model/note.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Simple Note',
      debugShowCheckedModeBanner: false,
      home: NotePage(),
    );
  }
}

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _noteTextController = TextEditingController();

  late Future<List<Note>> _notesList;
  late String _noteText;
  bool isUpdate = false;
  int? noteIdForUpdate;

  @override
  void initState() {
    super.initState();
    updateNoteList();
  }

  updateNoteList() {
    setState(() {
      _notesList = DBProvider.db.getNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Note'),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder(
              future: _notesList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return generateList(snapshot.data as List<Note>);
                }
                if (snapshot.data == null ||
                    (snapshot.data as List<Note>).isEmpty) {
                  return const Text('No Data Found');
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
          Form(
            key: _formStateKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null) {
                        return 'Please Enter Text';
                      }
                      if (value.trim() == "") {
                        return "Only Space is Not Valid!!!";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _noteText = value!;
                    },
                    controller: _noteTextController,
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.greenAccent,
                            width: 2,
                            style: BorderStyle.solid),
                      ),
                      labelText: "Text",
                      icon: Icon(
                        Icons.note_add,
                        color: Colors.black,
                      ),
                      fillColor: Colors.white,
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  textStyle: const TextStyle(color: Colors.white),
                ),
                child: Text(
                  (isUpdate ? 'UPDATE' : 'ADD'),
                ),
                onPressed: () {
                  if (isUpdate) {
                    if (_formStateKey.currentState!.validate()) {
                      _formStateKey.currentState!.save();
                      DBProvider.db
                          .updateNote(Note(noteIdForUpdate!, _noteText))
                          .then((data) {
                        setState(() {
                          isUpdate = false;
                        });
                      });
                    }
                  } else {
                    if (_formStateKey.currentState!.validate()) {
                      _formStateKey.currentState!.save();
                      // DBProvider.db.insertStudent(Student(null, _studentName));
                      DBProvider.db.insertNote(Note(null, _noteText));
                    }
                  }
                  _noteTextController.text = '';
                  updateNoteList();
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  textStyle: const TextStyle(color: Colors.white),
                ),
                child: Text(
                  (isUpdate ? 'CANCEL UPDATE' : 'CLEAR'),
                ),
                onPressed: () {
                  _noteTextController.text = '';
                  setState(() {
                    isUpdate = false;
                    noteIdForUpdate = null; // null;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  SingleChildScrollView generateList(List<Note> notes) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 3),
          borderRadius: const BorderRadius.all(Radius.circular(5) //
              ),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: DataTable(
            horizontalMargin: 10,
            border: TableBorder.all(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black38,
                width: 1,
                style: BorderStyle.solid),
            columns: const [
              DataColumn(
                label: Text('TEXT',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              DataColumn(
                label: Text('DELETE',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ],
            rows: notes
                .map(
                  (note) => DataRow(
                      selected: true,
                      cells: [
                    DataCell(Text(note.text), onTap: () {
                      setState(() {
                        isUpdate = true;
                        noteIdForUpdate = note.id;
                      });
                      _noteTextController.text = note.text;
                    }),
                    DataCell(
                      IconButton(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          DBProvider.db.deleteStudent(note.id);
                          updateNoteList();
                        },
                      ),
                    ),
                  ]),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
