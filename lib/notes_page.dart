import 'package:flutter/material.dart';
import 'database/database_helper.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<Map<String, dynamic>> notes = [];
  Future<void> loadNotes() async {
    final data = await DatabaseHelper.getNotes();

    setState(() {
      notes = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: notes.isEmpty
    ? const Center(
        child: Text('No notes yet'),
      )
    : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];

          return ListTile(
                  title: Text(note['title']),
                  subtitle: Text(note['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          titleController.text = note['title'];
                          descriptionController.text =
                              note['description'] ?? '';

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Edit Note'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Title',
                                      ),
                                    ),
                                    TextField(
                                      controller: descriptionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Description',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await DatabaseHelper.updateNote(
                                        note['id'],
                                        {
                                          'title': titleController.text,
                                          'description':
                                              descriptionController.text,
                                        },
                                      );

                                      await loadNotes();

                                      titleController.clear();
                                      descriptionController.clear();

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('Update'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),

                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await DatabaseHelper.deleteNote(note['id']);

                          await loadNotes();
                        },
                      ),
                    ],
                  ),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Note'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                       controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await DatabaseHelper.insertNote({
                        'title': titleController.text,
                        'description': descriptionController.text,
                      });

                      titleController.clear();
                      descriptionController.clear();

                      await loadNotes();

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
