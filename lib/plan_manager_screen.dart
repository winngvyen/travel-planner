import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<Plan>> _plansByDate = {};

  void _addPlan(String name, String description, DateTime date) {
    setState(() {
      Plan newPlan = Plan(name: name, description: description, date: date);
      plans.add(newPlan);
      _plansByDate.putIfAbsent(date, () => []).add(newPlan);
    });
  }

  void _toggleCompletion(Plan plan) {
    setState(() {
      plan.isCompleted = !plan.isCompleted;
    });
  }

  void _deletePlan(Plan plan) {
    setState(() {
      _plansByDate[plan.date]?.remove(plan);
      plans.remove(plan);
    });
  }

  void _editPlan(Plan plan) {
    TextEditingController nameController = TextEditingController(text: plan.name);
    TextEditingController descriptionController = TextEditingController(text: plan.description);
    DateTime selectedDate = plan.date;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Plan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Plan Name"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: Text("Pick Date"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _plansByDate[plan.date]?.remove(plan);
                  plan.name = nameController.text;
                  plan.description = descriptionController.text;
                  plan.date = selectedDate;
                  _plansByDate.putIfAbsent(selectedDate, () => []).add(plan);
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _updatePlanDate(Plan plan, DateTime newDate) {
    setState(() {
      _plansByDate[plan.date]?.remove(plan);
      plan.date = newDate;
      _plansByDate.putIfAbsent(newDate, () => []).add(plan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Adoption & Travel Planner")),
      body: Column(
        children: [
          // Calendar Widget
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
          ),
          Expanded(
            child: DragTarget<Plan>(
              onAccept: (plan) {
                _updatePlanDate(plan, _selectedDate);
              },
              builder: (context, candidateData, rejectedData) {
                return ListView.builder(
                  itemCount: _plansByDate[_selectedDate]?.length ?? 0,
                  itemBuilder: (context, index) {
                    Plan plan = _plansByDate[_selectedDate]![index];
                    return Dismissible(
                      key: Key(plan.name),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _toggleCompletion(plan);
                      },
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                      child: GestureDetector(
                        onDoubleTap: () => _deletePlan(plan),
                        onLongPress: () => _editPlan(plan),
                        child: Draggable<Plan>(
                          data: plan,
                          feedback: Material(
                            child: Container(
                              padding: EdgeInsets.all(8),
                              color: Colors.blue,
                              child: Text(plan.name, style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          childWhenDragging: Container(),
                          child: ListTile(
                            title: Text(
                              plan.name,
                              style: TextStyle(
                                decoration: plan.isCompleted ? TextDecoration.lineThrough : null,
                                color: plan.isCompleted ? Colors.green : Colors.black,
                              ),
                            ),
                            subtitle: Text("${plan.description} - ${plan.date.toLocal()}".split(' ')[0]),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPlan("New Plan", "Description", _selectedDate),
        child: Icon(Icons.add),
      ),
    );
  }
}
