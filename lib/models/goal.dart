import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  final String goal_string;
  final String fk_group_id;
  final String fk_user_id;
  final String timestamp;
  final List urls;
  final List likes;
  final bool completed;


  Goal({
    this.id,
    this.goal_string,
    this.fk_group_id,
    this.fk_user_id,
    this.timestamp,
    this.urls,
    this.likes,
    this.completed,
  });

  factory Goal.fromDocument(DocumentSnapshot doc) {
    return Goal(
      id: doc['id'],
      goal_string: doc['goal_string'],
      fk_group_id: doc['fk_group_id'],
      fk_user_id: doc['fk_user_id'],
      timestamp: doc['timestamp'],
      urls: doc['urls'],
      likes: doc['likes'],
      completed: doc['completed'],
    );
  }

}