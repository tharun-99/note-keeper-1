import 'package:flutter/material.dart';
import 'package:note_keeper/screens/note_list.dart';
import 'dart:async';
import 'package:note_keeper/models/note.dart';
import 'package:note_keeper/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget{
  final Note note;
  final String appBarTitle;
  NoteDetail(this.note,this.appBarTitle);
  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note,this.appBarTitle);
  }
}
class NoteDetailState extends State<NoteDetail>{
  var _formKey=GlobalKey<FormState>();
  static var _priorities=['High','Low'];
  DatabaseHelper helper=DatabaseHelper();
  Note note;
  String appBarTitle;
  TextEditingController titleController=TextEditingController();
  TextEditingController descriptionController=TextEditingController();
  NoteDetailState(this.note,this.appBarTitle);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle=Theme.of(context).textTheme.title;
    titleController.text=note.title;
    descriptionController.text=note.description;
    
    return WillPopScope(
      
      onWillPop: (){
        //executes when user presses back button in device
        moveToLastScreen();
      },
        child:Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(icon: Icon(
          Icons.arrow_back),
          onPressed: (){
          //executes when the user presses the back button present on the appbar
            moveToLastScreen();
          },
        ),),
      
      body:Form(key: _formKey,
        child:
      Padding(
        padding: EdgeInsets.only(top: 15.0,left: 10.0,right: 10.0),
        child: ListView(
          children: <Widget>[
            //first element of the listview
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropDownStringItem){
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                  
              }).toList(),
                style: textStyle,
                value: "Low",
                onChanged: (valueSelectedByUser){
                  setState(() {
                    debugPrint('user selected $valueSelectedByUser');
                    updatePriorityAsInt(valueSelectedByUser);
                  });
                },
              ),
            ),
            //second element in listview
            
            Padding(
              padding: (EdgeInsets.only(top:15.0,bottom: 15.0)),
              child: TextFormField(
                // ignore: missing_return
                validator: (value){
                  if(value.isEmpty){
                    return 'Please enter title';
                  }
                },
                controller: titleController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('title changed');
                  updateTitle();
                },
                decoration: InputDecoration(
                  labelText: 'title',
                  labelStyle: textStyle,
                  errorStyle: TextStyle(color: Colors.redAccent,fontSize: 15.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
            ),
            //third element in listview
            Padding(
              padding: (EdgeInsets.only(top:15.0,bottom: 15.0)),
              child: TextFormField(
                // ignore: missing_return
                validator: (value){
                  if(value.isEmpty){
                    return 'Please enter description';
                  }
                },
                controller: descriptionController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('description changed');
                  updateDescription();
                },
                decoration: InputDecoration(
                    labelStyle: textStyle,
                    labelText: 'description',
                    errorStyle: TextStyle(color: Colors.redAccent,fontSize: 15.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),
            //fourth element in listview i.e row with two elements
            
            Padding(
              padding: EdgeInsets.only(
                top: 15.0,bottom: 15.0
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        'Save',textScaleFactor: 1.5,
                      ),
                      onPressed: (){
                        setState(() {
                          if(_formKey.currentState.validate()){
                            debugPrint('save button clicked');
                            _save();
                          }
                        });
                      },
                    ),
                  ),
                  Container(width: 10.0,),
                  Expanded( child: RaisedButton(
                    color: Theme.of(context).primaryColorDark,
                    textColor: Theme.of(context).primaryColorLight,
                    child: Text(
                      'Delete',textScaleFactor: 1.5,
                    ),
                    onPressed: (){
                      setState(() {
                        debugPrint('delete button clicked');
                        _delete();
  
                      });
                    },
                  ),
                  
                  ),
                ],
              ),
            )
          ],
        ),
      ),),
    ));
  }
  //to move from note detail to note list
  void moveToLastScreen()
  {
    Navigator.pop(context,true);
  }
  //to change string priority into integer value before storing into database
  void updatePriorityAsInt(String value){
    switch (value){
      case 'High':note.priority=1;
      break;
      case 'Low' :note.priority=2;
      break;
    }
  }
  //to change integer priority to string to display in dropdown button
  String getPriorityAsString(int value){
    String priority;
    switch (value){
      
      case 1:priority=_priorities[0];
      break;
      case 2:priority=_priorities[1];
      break;
    }
    return priority;
  }
  //update title of note object
  void updateTitle(){
    note.title=titleController.text;
  }
  //update description of note object
  void updateDescription(){
    note.description=descriptionController.text;
  }
  //to save the note entered by user
  void _save() async{
    var result;
    moveToLastScreen();
    note.date=DateFormat.yMMMd().format(DateTime.now());
    if(note.id!=null){//update operation
      result=await helper.updateNote(note);
  }
    else {//insert operation
      result =await helper.insertNote(note);
    }
    if(result!=0){//success
      _showAlertDilog('Status','Note Saved Successfully');
    }
    else{//failure
      _showAlertDilog('Status','Some Error Occured');
    }
    
}
void _showAlertDilog(String title,String message){
    AlertDialog alertDialog=AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context,
    builder: (_)=>alertDialog);
}
void _delete() async{
    moveToLastScreen();
    //if the user tries to delete the note which is not created yet
    if(note.id==null){
      _showAlertDilog('Status','No note was deleted');
      return;
    }
    //if user tries to delete an old note
    int result =await helper.deleteNote(note.id);
    if (result!=0){
      _showAlertDilog('Status','Note Deleted Successfully');
    }
    else
      _showAlertDilog('Status', 'Error Occured While Deleting');
}

}