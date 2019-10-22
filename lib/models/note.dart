class Note {
  int _id;
  String _title;
  String _description;
  String _date;
  int _priority;
  
  Note(this._title, this._date, this._priority, [this._description]);
  
  Note.withId(this._id, this._title, this._date,
      this._priority, [this._description]);
  
  int get priority => _priority;
  
  String get date => _date;
  
  String get description => _description;
  
  String get title => _title;
  
  int get id => _id;
  
  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2)
      _priority = newPriority;
  }
  
  set date(String newDate) {
    _date = newDate;
  }
  
  set description(String newDescription) {
    if (newDescription.length <= 255)
      _description = newDescription;
  }
  
  set title(String newTitle) {
    if (newTitle.length <= 255)
      _title = newTitle;
  }
  
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null)
      map['id'] = _id;
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;
    return map;
  }
  
  //extract a note object from a map object
  Note.fromMapObject(Map<String, dynamic>map){
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._priority = map['priority'];
    this._date = map['date'];
  }
}


