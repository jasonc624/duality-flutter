import 'package:flutter/material.dart';

import 'week.dart';

class WeeksList extends StatelessWidget {
  final int weeksInYear = 52;
  static const routeName = '/weeks_list';
  @override
  Widget build(BuildContext context) {
    int currentWeek = _getCurrentWeek();

    return Scaffold(
      appBar: AppBar(
        title: Text('Reports by week'),
      ),
      body: ListView.builder(
        itemCount: weeksInYear,
        itemBuilder: (context, index) {
          bool isCurrentWeek = index + 1 == currentWeek;
          return ListTile(
              tileColor:
                  isCurrentWeek ? Colors.deepPurple.withOpacity(0.2) : null,
              leading: CircleAvatar(
                backgroundColor: isCurrentWeek ? Colors.purple : null,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight:
                        isCurrentWeek ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentWeek ? Colors.white : null,
                  ),
                ),
              ),
              title: Text(
                'Week ${index + 1}',
                style: TextStyle(
                  fontWeight:
                      isCurrentWeek ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                '${_getDateRangeForWeek(index + 1)}',
                style: TextStyle(
                  fontWeight:
                      isCurrentWeek ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeekView(weekNumber: index + 1),
                  ),
                );
              });
        },
      ),
    );
  }

  int _getCurrentWeek() {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final difference = now.difference(firstDayOfYear).inDays;
    return (difference / 7).ceil();
  }

  String _getDateRangeForWeek(int weekNumber) {
    // This is a simplified date range calculation
    // For accurate calculations, you might want to use a date library
    DateTime firstDayOfYear = DateTime(DateTime.now().year, 1, 1);
    int daysToAdd = (weekNumber - 1) * 7;
    DateTime weekStart = firstDayOfYear.add(Duration(days: daysToAdd));
    DateTime weekEnd = weekStart.add(Duration(days: 6));

    return '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
