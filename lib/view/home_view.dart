import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/note_model.dart';
import '../controller/database.dart';
import '../utility/priority_color.dart';
import '../widget/custom_app_bar.dart';
import 'add_note_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Note>> _noteList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  Note note = Note();
  _updateNoteList() {
    _noteList = DatabaseHelper.instance.getNoteList();
  }

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'MY NOTES'),
      body: FutureBuilder(
        future: _noteList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final int completeNoteCount = snapshot.data!
              .where((Note note) => note.status == 1)
              .toList()
              .length;
          return ListView.builder(
            itemCount: int.parse(snapshot.data!.length.toString()),
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Text('$completeNoteCount of ${snapshot.data!.length}'),
                    const SizedBox(height: 10),
                  ],
                );
              }
              return Dismissible(
                  confirmDismiss: (DismissDirection direction) async {
                    final confirm = showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return _deleteDialog(context, snapshot, index);
                      },
                    );
                    return confirm;
                  },
                  direction: DismissDirection.endToStart,
                  key: Key(snapshot.data![index].toString()),
                  background: Container(color: Colors.red),
                  child: _buildNotes(snapshot.data![index]));
            },
          );
        },
      ),
      floatingActionButton: addNoteButton(context),
    );
  }

  AlertDialog _deleteDialog(
      BuildContext context, AsyncSnapshot<List<Note>> snapshot, int index) {
    return AlertDialog(
      title: const Text('Are you sure you want to delete'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
            _delete(snapshot.data![index].id!);
          },
          child: const Text('Yes'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text('No'),
        ),
      ],
    );
  }

  FloatingActionButton addNoteButton(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteView(
                updateNoteList: _updateNoteList,
              ),
            ));
      },
    );
  }

  Widget _buildNotes(Note note) {
    return Column(
      children: [
        ListTile(
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Icon(
              color: priorityColor(note.priority!),
              Icons.circle,
              size: 20,
            ),
          ),
          title: Text(
            note.title!,
            style: TextStyle(
              decoration: note.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough,
            ),
          ),
          subtitle: Text(
            '${_dateFormatter.format(note.date!)}-${note.priority}',
            style: TextStyle(
              decoration: note.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough,
            ),
          ),
          trailing: Checkbox(
            value: note.status == 1 ? true : false,
            onChanged: (value) {
              setState(() {
                note.status = value! ? 1 : 0;
              });
              DatabaseHelper.instance.updateNote(note);
              _updateNoteList();
            },
          ),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddNoteView(
                        updateNoteList: _updateNoteList(),
                        note: note,
                      ))),
        ),
        const Divider()
      ],
    );
  }

  _delete(int id) {
    note.id = id;
    DatabaseHelper.instance.deleteNote(note.id!);
  }
}
