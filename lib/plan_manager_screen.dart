import 'package:flutter/material.dart';

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<String> plans = [];

  void _addPlan(String plan) {
    setState(() {
      plans.add(plan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Adoption & Travel Planner")),
      body: ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(plans[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPlan("New Plan"),
        child: Icon(Icons.add),
      ),
    );
  }
}
