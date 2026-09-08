import 'package:ebooking_desktop/models/reservation_model.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

NTagVariant reservationTagVariant(ReservationStatus status) {
  switch (status) {
    case ReservationStatus.pending:
      return NTagVariant.outline;
    case ReservationStatus.confirmed:
      return NTagVariant.accent;
    case ReservationStatus.cancelled:
    case ReservationStatus.rejected:
    case ReservationStatus.completed:
      return NTagVariant.neutral;
  }
}
