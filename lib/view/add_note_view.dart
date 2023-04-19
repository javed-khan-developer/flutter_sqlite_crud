import 'package:flutter/material.dart';
import 'package:flutter_sqlite_crud/controller/database.dart';
import 'package:flutter_sqlite_crud/view/home_view.dart';
import 'package:intl/intl.dart';

import '../model/note_model.dart';
import '../widget/custom_app_bar.dart';

class AddNoteView extends StatefulWidget {
  final Note? note;
  final Function? updateNoteList;
  const AddNoteView({super.key, this.note, this.updateNoteList});

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  String _title = '';
  String _priority = 'Low';
  String titleText = 'Add Note';
  String btnText = 'Add Note';

  final TextEditingController _dateController = TextEditingController();
  DateTime _date = DateTime.now();
  final DateFormat _dateFormatatter = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _title = widget.note!.title!;
      _date = widget.note!.date!;
      _priority = widget.note!.priority!;
      setState(() {
        btnText = "Update Note";
        titleText = "Update Note";
      });
    } else {
      setState(() {
        btnText = "Add Note";
        titleText = "Add Note";
      });
    }
    _dateController.text = _dateFormatatter.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: titleText),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onSaved: (newValue) => _title = newValue!,
                    initialValue: _title,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    readOnly: true,
                    controller: _dateController,
                    onTap: _handleDatePicker,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                    icon: const Icon(Icons.arrow_downward),
                    items: _priorities.map((String priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _priority = value.toString();
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                    value: _priority,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 40),
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                        onPressed: _submit, child: Text(btnText)),
                  ),
                  widget.note != null
                      ? Container(
                          margin: const EdgeInsets.symmetric(vertical: 40),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton(
                              onPressed: _delete, child: const Text('Delete')),
                        )
                      : const SizedBox.shrink()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2010),
        lastDate: DateTime(2050));
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
    }
    _dateController.text = _dateFormatatter.format(date!);
  }

  _submit() {
    _formKey.currentState!.save();
    print('$_title,$_date,$_priority');
    Note note = Note(
      title: _title,
      date: _date,
      priority: _priority,
    );
    if (widget.note == null) {
      note.status = 0;
      DatabaseHelper.instance.insertNote(note);
      goToHomeView();
    } else {
      note.id = widget.note!.id;
      note.status = widget.note!.status;
      DatabaseHelper.instance.updateNote(note);
      goToHomeView();
    }
    widget.updateNoteList!();
  }

  _delete() {
    DatabaseHelper.instance.deleteNote(widget.note!.id!);
    goToHomeView();
    widget.updateNoteList!();
  }

  void goToHomeView() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(),
        ));
  }
}
