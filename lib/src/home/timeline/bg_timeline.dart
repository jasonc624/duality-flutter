import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';

class CustomBackgroundExample extends StatelessWidget {
  final Function(DateTime) onDateChanged;
  final DateTime initialDate;

  const CustomBackgroundExample({
    Key? key,
    required this.onDateChanged,
    required this.initialDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasyDateTimeLine(
      initialDate: initialDate,
      onDateChange: (selectedDate) {
        onDateChanged(selectedDate);
      },
      headerProps: const EasyHeaderProps(
        monthPickerType: MonthPickerType.switcher,
        dateFormatter: DateFormatter.fullDateDMY(),
      ),
      dayProps: const EasyDayProps(
        dayStructure: DayStructure.dayStrDayNum,
        activeDayStyle: DayStyle(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff3371FF),
                Color(0xff8426D6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
