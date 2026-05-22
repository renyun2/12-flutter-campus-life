import '../../data/models/models.dart';

double calcGpa(List<GradeItem> items) {
  if (items.isEmpty) return 0;
  var credit = 0.0;
  var weighted = 0.0;
  for (final g in items) {
    credit += g.credit;
    weighted += g.score * g.credit;
  }
  if (credit == 0) return 0;
  return (weighted / credit / 25 * 100).roundToDouble() / 100;
}
