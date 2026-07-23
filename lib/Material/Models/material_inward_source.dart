import 'package:midas/app/constants/app_strings.dart';

enum MaterialInwardSource {
  grn(1, AppStrings.sourceGrn),
  jobWork(2, AppStrings.sourceJobWork),
  finishGoods(3, AppStrings.sourceFinishGoods),
  // intermediate(4, AppStrings.sourceIntermediate),
  inwardQc(4, AppStrings.sourceOpeningStock);

  const MaterialInwardSource(this.id, this.label);

  final int id;
  final String label;

  static const valuesInOrder = MaterialInwardSource.values;
}
