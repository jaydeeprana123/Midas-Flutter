import 'package:midas/app/constants/app_strings.dart';

enum MaterialInwardSource {
  grn(1, AppStrings.sourceGrn),
  inwardQc(2, AppStrings.sourceInwardQc),
  jobWork(3, AppStrings.sourceJobWork),
  finishGoods(4, AppStrings.sourceFinishGoods),
  intermediate(5, AppStrings.sourceIntermediate);

  const MaterialInwardSource(this.id, this.label);

  final int id;
  final String label;

  static const valuesInOrder = MaterialInwardSource.values;
}
