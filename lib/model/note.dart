class Note {
  int? id;
  late String text;

  Note(this.id, this.text);

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['text'] = text;
    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    text = map['text'];
  }
}