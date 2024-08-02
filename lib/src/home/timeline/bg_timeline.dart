import 'package:duality/src/providers/uiState.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBackgroundExample extends ConsumerWidget {
  final DateTime initialDate;

  const CustomBackgroundExample({
    Key? key,
    required this.initialDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UiState uistate = ref.read(uiStateProvider.notifier);
    return EasyDateTimeLine(
      initialDate: initialDate,
      onDateChange: (selectedDate) {
        uistate.setDate(selectedDate);
      },
      headerProps: const EasyHeaderProps(
        monthPickerType: MonthPickerType.switcher,
        dateFormatter: DateFormatter.fullDateMonthAsStrDY(),
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
