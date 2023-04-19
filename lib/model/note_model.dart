class Note {
  int? id;
  String? title;
  String? priority;
  DateTime? date;
  int? status;
  Note({
    this.title,
    this.priority,
    this.date,
    this.status,
  });

  Note.withId({
    this.id,
    this.title,
    this.priority,
    this.date,
    this.status,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['priority'] = priority;
    map['date'] = date!.toIso8601String();
    map['status'] = status;
    return map;
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note.withId(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      priority: map['priority'],
      status: map['status'],
    );
  }
}
