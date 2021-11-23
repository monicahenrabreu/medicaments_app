import 'dart:collection';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicaments_app/bloc/calendar/calendar_event.dart';
import 'package:medicaments_app/bloc/calendar/calendar_state.dart';
import 'package:medicaments_app/data/models/calendar.dart';
import 'package:medicaments_app/data/models/medicament.dart';
import 'package:medicaments_app/ui/screens/home/utils.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc() : super(CalendarInitialState()) {
    on<CalendarOnDaySelectedEvent>(_onCalendarOnDaySelectedEvent);
    on<CalendarOnRangeSelectedEvent>(_onCalendarOnRangeSelectedEvent);
    on<CalendarOnPageChangedEvent>(_onCalendarOnPageChangedEvent);
    on<CalendarOnFormatChangedEvent>(_onCalendarOnFormatChangedEvent);
    on<CalendarOnAddMedicamentEvent>(_onCalendarOnAddMedicamentEvent);
  }

  void _onCalendarOnDaySelectedEvent(
      CalendarOnDaySelectedEvent event, Emitter<CalendarState> emit) async {
    Calendar? stateCalendar = state.calendar;

    if (stateCalendar != null &&
        !isSameDay(event.calendar.selectedDay, stateCalendar.selectedDay)) {
      List<Medicament> medicamentList =
          _getEventsForDay(event.medicamentList, event.calendar.selectedDay!);

      Calendar newCalendar = Calendar(
          firstDay: calendarFirstDay,
          lastDay: calendarLastDay,
          selectedDay: event.calendar.selectedDay,
          focusedDay: event.calendar.focusedDay,
          rangeStartDay: null,
          // Important to clean those
          rangeEndDay: null,
          rangeSelectionMode: RangeSelectionMode.toggledOff,
          selectedEvents: medicamentList);

      emit(state.copyWith(calendar: newCalendar));
    }
  }

  void _onCalendarOnRangeSelectedEvent(
      CalendarOnRangeSelectedEvent event, Emitter<CalendarState> emit) async {
    Calendar? stateCalendar = state.calendar;

    if (stateCalendar != null) {
      Calendar newCalendar = Calendar(
        firstDay: calendarFirstDay,
        lastDay: calendarLastDay,
        selectedDay: null,
        focusedDay: event.calendar.focusedDay,
        rangeStartDay: event.calendar.rangeStartDay,
        // Important to clean those
        rangeEndDay: event.calendar.rangeEndDay,
        rangeSelectionMode: RangeSelectionMode.toggledOn,
      );
      emit(state.copyWith(calendar: newCalendar));
    }
  }

  void _onCalendarOnPageChangedEvent(
      CalendarOnPageChangedEvent event, Emitter<CalendarState> emit) async {
    Calendar? stateCalendar = state.calendar;

    if (stateCalendar != null) {
      Calendar newCalendar = Calendar(
          firstDay: stateCalendar.firstDay,
          lastDay: stateCalendar.lastDay,
          selectedDay: stateCalendar.selectedDay,
          focusedDay: event.focusedDay,
          rangeStartDay: stateCalendar.rangeStartDay,
          // Important to clean those
          rangeEndDay: stateCalendar.rangeEndDay,
          rangeSelectionMode: stateCalendar.rangeSelectionMode);
      emit(state.copyWith(calendar: newCalendar));
    }
  }

  void _onCalendarOnFormatChangedEvent(
      CalendarOnFormatChangedEvent event, Emitter<CalendarState> emit) async {
    Calendar? stateCalendar = state.calendar;

    if (stateCalendar != null && stateCalendar.calendarFormat != event.format) {
      Calendar newCalendar = Calendar(
          firstDay: stateCalendar.firstDay,
          lastDay: stateCalendar.lastDay,
          focusedDay: stateCalendar.focusedDay,
          calendarFormat: event.format);
      emit(state.copyWith(calendar: newCalendar));
    }
  }

  void _onCalendarOnAddMedicamentEvent(
      CalendarOnAddMedicamentEvent event, Emitter<CalendarState> emit) async {
    print("CalendarOnAddMedicamentEvent");
    emit(state.copyWith(
        calendar: event.calendar, medicamentList: event.medicamentList));
  }

  List<Medicament> _getEventsForDay(
      LinkedHashMap<DateTime, List<Medicament>>? medicamentList,
      DateTime date) {
    if (medicamentList == null) {
      return [];
    }

    //since this param date is comming with Z at the end, we need to remove it
    final _dateFormat = DateFormat('d MMM yyyy');
    String dateInString = _dateFormat.format(date);
    DateTime dateTransformed = _dateFormat.parse(dateInString);
    return medicamentList[dateTransformed] ?? [];
  }
}
