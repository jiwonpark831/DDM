import 'package:ddm/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/color.dart';

class DDaySettingsPage extends StatefulWidget {
  @override
  _DDaySettingsPageState createState() => _DDaySettingsPageState();
}

class _DDaySettingsPageState extends State<DDaySettingsPage> {
  List<dynamic> ddayList = [];

  void addNewDDay() {
    setState(() {
      ddayList.add({"title": "", "date": ""});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      ddayList = appState.currentuser.dday;
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("디데이 설정하기"),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: ddayList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DDayItem(
                          title: ddayList[index]["title"],
                          date: ddayList[index]["date"],
                          index: index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class DDayItem extends StatefulWidget {
  String title;
  String date;
  int index;

  DDayItem({required this.title, required this.date, required this.index});

  @override
  _DDayItemState createState() => _DDayItemState();
}

class _DDayItemState extends State<DDayItem> {
  bool isExpanded = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  bool option = true;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
    dateController.text = widget.date;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      option = appState.currentuser.dday[widget.index]['option'];
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: AppColor.primary,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title.isEmpty ? "제목 없음" : widget.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.date.isEmpty
                              ? "날짜 없음"
                              : option
                                  ? "~ ${widget.date}"
                                  : "${widget.date} ~",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.primary),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: "제목"),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("디데이"),
                        SizedBox(width: 10),
                        Checkbox(
                          value: option,
                          onChanged: (value) {
                            if (option == !value! && option == false) {
                              option = value;
                            }
                            setState(() {});
                          },
                        ),
                        Text("날짜수"),
                        SizedBox(width: 10),
                        Checkbox(
                          value: !option,
                          onChanged: (value) {
                            if (option == value! && option == true) {
                              option = !value;
                            }
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: "날짜",
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dateController.text =
                                "${pickedDate.year}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      // ElevatedButton(
                      //   onPressed: () {
                      //     setState(() {
                      //       isExpanded = false;
                      //       appState.changeDDay('','',true,widget.index);
                      //       titleController.text='';
                      //       dateController.text='';
                      //     });
                      //   },
                      //   style: ElevatedButton.styleFrom(foregroundColor: Colors.greenAccent),
                      //   child: Text("초기화"),
                      // ),
                      // SizedBox(width:20),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        width: 350,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isExpanded = false;
                              appState.changeDDay(titleController.text,
                                  dateController.text, option, widget.index);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary, elevation: 0),
                          child: Text(
                            "저장하기",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ])
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
