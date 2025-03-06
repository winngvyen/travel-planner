import 'package:flutter/material.dart';

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

  void _addPlan(String name, String description, DateTime date) {
    setState(() {
      plans.add(Plan(name: name, description: description, date: date));
    });
  }

  void _toggleCompletion(int index) {
    setState(() {
      plans[index].isCompleted = !plans[index].isCompleted;
    });
  }

  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  void _editPlan(int index) {
    TextEditingController nameController = TextEditingController(text: plans[index].name);
    TextEditingController descriptionController = TextEditingController(text: plans[index].description);
    DateTime selectedDate = plans[index].date;

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
                  plans[index].name = nameController.text;
                  plans[index].description = descriptionController.text;
                  plans[index].date = selectedDate;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Adoption & Travel Planner")),
      body: ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(plans[index].name),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _toggleCompletion(index);
            },
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.check, color: Colors.white),
            ),
            child: GestureDetector(
              onDoubleTap: () => _deletePlan(index),
              child: ListTile(
                title: Text(
                  plans[index].name,
                  style: TextStyle(
                    decoration: plans[index].isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text("${plans[index].description} - ${plans[index].date.toLocal()}".split(' ')[0]),
                onLongPress: () => _editPlan(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPlan("New Plan", "Description", DateTime.now()),
        child: Icon(Icons.add),
      ),
    );
  }
}
