import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:midas/Material/Controllers/search_material_controller.dart';
import 'package:midas/SearchAsset/Models/gps_data_model.dart';
import 'package:midas/Shared/Widgets/midas_toolbar_logo.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';

class SearchMaterialView extends GetView<SearchMaterialController> {
  const SearchMaterialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _MaterialLookupField(),
                      const SizedBox(height: 22),
                      _StartStopButtons(),
                      const SizedBox(height: 16),
                      const _ScannedMaterialMap(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialLookupField extends GetView<SearchMaterialController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.openMaterialLookup,
      child: IgnorePointer(
        child: TextField(
          controller: controller.materialController,
          readOnly: true,
          showCursor: false,
          enableInteractiveSelection: false,
          onTap: controller.openMaterialLookup,
          onTapAlwaysCalled: true,
          style: AppTextStyles.body(color: Colors.black87),
          decoration: InputDecoration(
            labelText: AppStrings.materialNameCodeOrTagCode,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: const Tooltip(
              message: AppStrings.rfidReaderConnected,
              child: Icon(
                Icons.sensors,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Center(child: MidasToolbarLogo(height: 34)),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.materialTrackingSystem,
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle(),
          ),
          const SizedBox(height: 12),
          Text(AppStrings.searchMaterial, style: AppTextStyles.loginTitle()),
        ],
      ),
    );
  }
}

class _StartStopButtons extends GetView<SearchMaterialController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: controller.canStart ? controller.start : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: controller.isStarting.value
                    ? AppTheme.primary
                    : const Color(0xFFBDBDBD),
              ),
              child: controller.isStarting.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(AppStrings.start),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.canStop ? controller.stop : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                disabledBackgroundColor: const Color(0xFFBDBDBD),
              ),
              child: const Text(AppStrings.stop),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannedMaterialMap extends StatefulWidget {
  const _ScannedMaterialMap();

  @override
  State<_ScannedMaterialMap> createState() => _ScannedMaterialMapState();
}

class _ScannedMaterialMapState extends State<_ScannedMaterialMap> {
  static const _initialCamera = CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );

  GoogleMapController? _mapController;
  List<GpsDataModel> _readings = const [];
  int _fitGeneration = 0;

  SearchMaterialController get _controller =>
      Get.find<SearchMaterialController>();

  bool get _mapsSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _fitReadings(List<GpsDataModel> readings) async {
    final generation = ++_fitGeneration;
    final controller = _mapController;
    if (controller == null || readings.isEmpty || !mounted) return;

    final points = readings
        .map((reading) => LatLng(reading.latitude, reading.longitude))
        .toList();

    if (generation != _fitGeneration || !mounted) return;

    try {
      if (points.length == 1 || _boundsAreDegenerate(points)) {
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(points.first, 16),
        );
        return;
      }

      var south = points.first.latitude;
      var north = points.first.latitude;
      var west = points.first.longitude;
      var east = points.first.longitude;
      for (final point in points) {
        if (point.latitude < south) south = point.latitude;
        if (point.latitude > north) north = point.latitude;
        if (point.longitude < west) west = point.longitude;
        if (point.longitude > east) east = point.longitude;
      }

      if (generation != _fitGeneration || !mounted) return;
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(south, west),
            northeast: LatLng(north, east),
          ),
          48,
        ),
      );
    } catch (_) {
      // The map can reject a camera update before its first layout.
    }
  }

  bool _boundsAreDegenerate(List<LatLng> points) {
    var south = points.first.latitude;
    var north = points.first.latitude;
    var west = points.first.longitude;
    var east = points.first.longitude;
    for (final point in points) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }
    return (north - south).abs() < 0.00001 && (east - west).abs() < 0.00001;
  }

  Set<Marker> _markersFor(List<GpsDataModel> readings) {
    return readings
        .map(
          (reading) => Marker(
            markerId: MarkerId(reading.rfidNumber),
            position: LatLng(reading.latitude, reading.longitude),
            consumeTapEvents: true,
            onTap: () =>
                _showDetails(_controller.detailsFor(reading.rfidNumber)),
          ),
        )
        .toSet();
  }

  void _showDetails(MaterialScanMarkerDetails details) {
    final name = details.materialName.trim().isEmpty
        ? AppStrings.notAvailable
        : details.materialName.trim();
    final code = details.materialCode.trim().isEmpty
        ? AppStrings.notAvailable
        : details.materialCode.trim();
    final tag = details.tagCode.trim().isEmpty
        ? AppStrings.notAvailable
        : details.tagCode.trim();

    Get.dialog<void>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppStrings.scannedMaterial,
          style: AppTextStyles.body(
            color: Colors.black87,
            weight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailLine(label: AppStrings.materialNameLabel, value: name),
            const SizedBox(height: 8),
            _DetailLine(label: AppStrings.materialCodeLabel, value: code),
            const SizedBox(height: 8),
            _DetailLine(label: AppStrings.tagCodeLabel, value: tag),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              AppStrings.ok,
              style: AppTextStyles.button(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_mapsSupported) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 280,
          width: double.infinity,
          child: ColoredBox(
            color: const Color(0xFFE8E8EE),
            child: Center(
              child: Text(
                AppStrings.mapAvailableOnMobile,
                style: AppTextStyles.body(color: Colors.black54),
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 280,
        width: double.infinity,
        child: Obx(() {
          final readings = _controller.scanMarkers.toList();
          final previous = _readings;
          _readings = readings;
          if (!_samePositions(previous, readings)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fitReadings(readings);
            });
          }

          return GoogleMap(
            initialCameraPosition: _initialCamera,
            markers: _markersFor(readings),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
            },
            onMapCreated: (controller) {
              _mapController = controller;
              _fitReadings(readings);
            },
          );
        }),
      ),
    );
  }

  bool _samePositions(List<GpsDataModel> previous, List<GpsDataModel> next) {
    if (previous.length != next.length) return false;
    for (var i = 0; i < previous.length; i++) {
      if (previous[i].rfidNumber != next[i].rfidNumber ||
          previous[i].latitude != next[i].latitude ||
          previous[i].longitude != next[i].longitude) {
        return false;
      }
    }
    return true;
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: AppTextStyles.body(color: Colors.black87),
    );
  }
}
