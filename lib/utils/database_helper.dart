import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_keeper/models/note.dart';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;
  
  String noteTable='note_table';
  String colId='id';
  String colTitle='title';
  String colDescription='description';
  String colPriority='priority';
  String colDate='date';
  
  DatabaseHelper._createInstance();//named constructor to create instance

  factory DatabaseHelper(){
    if(_databaseHelper==null)
      _databaseHelper=DatabaseHelper._createInstance();
    return _databaseHelper;
  }
  
  Future<Database> get database async{
    if(_database==null)
      _database=await initializeDatabase();
    return _database;
  }
  
  Future<Database> initializeDatabase() async{
    //get directory for both android and ios
    Directory directory=await getApplicationDocumentsDirectory();
    String path=directory.path+'notes.db';
    //open /create the database at the given path
    var notesDatabase=await openDatabase(path,version: 1,onCreate: _createDb);
    return notesDatabase;
  }
  
  void _createDb(Database db,int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,'
            '$colTitle TEXT,$colDescription TEXT,$colPriority TEXT,$colDate TEXT)');
  }
  //Fetch operation get all note objects from database
    
    Future<List<Map<String,dynamic>>> getNoteMapList() async{
      
      Database db=await this.database;
      var result=await db.query(noteTable,orderBy: '$colPriority ASC');
      return result;
    }
   //Insert operation to insert a object into database
     Future<int> insertNote(Note note) async{
    
    Database db=await this.database;
    var result=await db.insert(noteTable,note.toMap());
    return result;
}
//Update operation to update any value in database
     Future<int> updateNote(Note note) async{
    var db=await this.database;
    var result=db.update(noteTable, note.toMap(),where: '$colId=?',whereArgs: [note.id]);
    return result;
}

//Delete operation to delete any note from database
     Future<int> deleteNote(int id) async{
    var db=await this.database;
    int result=await db.rawDelete('DELETE FROM $noteTable WHERE $colId=$id');
    return result;
     }
     
     //Get no of Note objects in database
Future<int> getCount() async{
    Database db=await this.database;
    List<Map<String,dynamic>> x=await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result =Sqflite.firstIntValue(x);
    return result;
}
  //get map list and convert it to note list
Future<List<Note>> getNoteList() async{
    var noteMapList=await getNoteMapList();
     int count =noteMapList.length;
     List<Note> noteList =List<Note>();
     //for loop to create a note list from map list
  for (int i=0;i<count ;i++){
    noteList.add(Note.fromMapObject(noteMapList[i]));
  }
  return noteList;
}
  
}