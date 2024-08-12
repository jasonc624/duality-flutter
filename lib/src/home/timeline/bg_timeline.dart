import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/uiState.dart';

class CustomBackgroundExample extends ConsumerWidget {
  const CustomBackgroundExample({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uistateProv = ref.watch(uiStateProvider);
    DateTime _selectedDate = uistateProv['selectedDate'];
    UiState uistate = ref.read(uiStateProvider.notifier);
    return EasyDateTimeLine(
      initialDate: _selectedDate,
      onDateChange: (selectedDate) {
        uistate.setDate(selectedDate);
      },
      headerProps: const EasyHeaderProps(
        centerHeader: true,
        monthPickerType: MonthPickerType.dropDown,
        dateFormatter: DateFormatter.fullDateMonthAsStrDY(),
      ),
      dayProps: const EasyDayProps(
        dayStructure: DayStructure.dayStrDayNum,
        height: 65.0,
        activeDayStyle: DayStyle(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(51, 113, 255, 1),
                Color.fromRGBO(132, 38, 214, 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
