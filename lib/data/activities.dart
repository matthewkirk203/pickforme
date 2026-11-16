import 'package:flutter/material.dart';

/// A single selectable activity.
class Activity {
  const Activity({required this.title, required this.category});
  final String title;
  final String category;

  @override
  bool operator ==(Object other) =>
      other is Activity && other.title == title && other.category == category;

  @override
  int get hashCode => Object.hash(title, category);
}

/// Metadata for a category card.
class Category {
  const Category({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
  final String name;
  final IconData icon;
  final Color color;
  final String description;
}

const List<Category> categories = [
  Category(
    name: 'Outside',
    icon: Icons.park_rounded,
    color: Color(0xFF4CAF7D),
    description: 'Fresh air & nature',
  ),
  Category(
    name: 'Creative',
    icon: Icons.palette_rounded,
    color: Color(0xFF9C6ADE),
    description: 'Make & imagine',
  ),
  Category(
    name: 'Relaxing',
    icon: Icons.self_improvement_rounded,
    color: Color(0xFF4A90D9),
    description: 'Calm & restore',
  ),
  Category(
    name: 'Physical',
    icon: Icons.fitness_center_rounded,
    color: Color(0xFFE8843C),
    description: 'Move & stretch',
  ),
];

const List<Activity> allActivities = [
  // Outside
  Activity(title: 'Go for a walk around the block', category: 'Outside'),
  Activity(title: 'Sit in the courtyard and listen to birds', category: 'Outside'),
  Activity(title: 'Take photos of 3 interesting things outside', category: 'Outside'),
  Activity(title: 'Water the patio plants', category: 'Outside'),
  // Creative
  Activity(title: 'Sketch a simple object nearby', category: 'Creative'),
  Activity(title: 'Listen to a new album with eyes closed', category: 'Creative'),
  Activity(title: 'Write a 3-sentence journal entry', category: 'Creative'),
  Activity(title: 'Color a page in a coloring book', category: 'Creative'),
  // Relaxing
  Activity(title: 'Do 5 slow deep-breathing cycles', category: 'Relaxing'),
  Activity(title: 'Listen to a 10-minute guided meditation', category: 'Relaxing'),
  Activity(title: 'Do light shoulder and neck stretches', category: 'Relaxing'),
  Activity(title: 'Drink a cold glass of flavored water', category: 'Relaxing'),
  // Physical
  Activity(title: 'Do 10 seated leg raises', category: 'Physical'),
  Activity(title: 'Throw a soft ball back and forth', category: 'Physical'),
  Activity(title: 'Do a gentle hallway stretch routine', category: 'Physical'),
  Activity(title: 'Stand up and balance on one foot for 30 seconds', category: 'Physical'),
];

List<Activity> activitiesFor(String category) =>
    allActivities.where((a) => a.category == category).toList();
