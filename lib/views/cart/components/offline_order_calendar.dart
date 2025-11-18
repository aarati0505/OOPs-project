import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_defaults.dart';

class OfflineOrderCalendar extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final DateTime? selectedDate;

  const OfflineOrderCalendar({
    super.key,
    this.onDateSelected,
    this.selectedDate,
  });

  @override
  State<OfflineOrderCalendar> createState() => _OfflineOrderCalendarState();
}

class _OfflineOrderCalendarState extends State<OfflineOrderCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate ?? DateTime.now();
    _selectedDay = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Date'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onDateSelected?.call(selectedDay);
              }
            },
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Set reminder for selected date
                    if (_selectedDay != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reminder set for ${_selectedDay!.toString().split(' ')[0]}'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.alarm),
                  label: const Text('Set Reminder'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedDay != null) {
                      Navigator.pop(context, _selectedDay);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a date')),
                      );
                    }
                  },
                  child: const Text('Confirm Date'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

