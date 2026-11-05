import 'package:get/get.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Widgets/app_message_dialog.dart';
import 'package:midas/app/constants/app_strings.dart';

class RfidFrequencyController extends GetxController {
  RfidFrequencyController({required this.rfidService});

  final RfidService rfidService;

  static const frequencies = <int>[
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  ];

  final isLoading = true.obs;
  final isConnected = false.obs;
  final isApplying = false.obs;
  final currentFrequency = RxnInt();
  final selectedFrequency = RxnInt();

  @override
  void onInit() {
    super.onInit();
    loadCurrentFrequency();
  }

  @override
  void onClose() {
    rfidService.disconnect();
    super.onClose();
  }

  Future<void> loadCurrentFrequency() async {
    isLoading.value = true;
    final connected = await rfidService.connect();
    isConnected.value = connected;
    if (!connected) {
      currentFrequency.value = null;
      selectedFrequency.value = null;
      isLoading.value = false;
      await showAppMessageDialog(AppStrings.rfidReaderUnavailable);
      return;
    }

    final frequency = await rfidService.getFrequency();
    if (frequency == null || frequency < 1) {
      currentFrequency.value = null;
      selectedFrequency.value = null;
      isLoading.value = false;
      await showAppMessageDialog(AppStrings.unableToReadFrequency);
      return;
    }

    currentFrequency.value = frequency;
    selectedFrequency.value =
        frequencies.contains(frequency) ? frequency : null;
    isLoading.value = false;
  }

  Future<void> onFrequencySelected(int? value) async {
    if (value == null || isApplying.value || value == currentFrequency.value) {
      return;
    }

    final previous = selectedFrequency.value;
    selectedFrequency.value = value;

    if (!isConnected.value) {
      selectedFrequency.value = previous;
      await showAppMessageDialog(AppStrings.rfidReaderUnavailable);
      return;
    }

    isApplying.value = true;
    final updated = await rfidService.setFrequency(value);
    if (!updated) {
      isApplying.value = false;
      selectedFrequency.value = previous;
      await showAppMessageDialog(AppStrings.unableToSetFrequency);
      return;
    }

    final confirmed = await rfidService.getFrequency();
    final displayed =
        confirmed != null && confirmed >= 1 ? confirmed : value;
    currentFrequency.value = displayed;
    selectedFrequency.value =
        frequencies.contains(displayed) ? displayed : value;
    isApplying.value = false;
  }
}
