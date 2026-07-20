class AppStrings {
  AppStrings._();

  // App
  static const appTitle = 'Midas';
  static const defaultOrgLabel = 'GSSPL';
  static const emptyValue = '-';
  static const notAvailable = 'N/A';

  // Common actions
  static const login = 'Login';
  static const logout = 'Logout';
  static const cancel = 'Cancel';
  static const save = 'Save';
  static const submit = 'Submit';
  static const success = 'Success';
  static const ok = 'OK';

  // Common labels
  static const userLabel = 'User :';
  static const assetName = 'Asset Name';
  static const assetCode = 'Asset Code';
  static const serialNo = 'Serial No.';
  static const tagCode = 'Tag code';
  static const locationCode = 'Location Code';
  static const location = 'Location';
  static const scanAssetQr = 'Scan Asset QR';
  static const scanQrOrPressButton = 'Scan QR or Press Button for RFID';
  static const scanLocationQrHere = 'Scan Location QR Here';
  static const assetNameOrCode = 'Asset name or Asset code';
  static const assetSerialNumber = 'Asset Serial Number';
  static const rfidReaderConnected = 'RFID reader connected';
  static const removeAsset = 'Remove asset';

  // System titles
  static const assetTrackingSystem = 'Asset Tracking and Management\nSystem';
  static const equipmentMaintenanceSystem =
      'Equipment Maintenance Management\nSystem';

  // Login
  static const userName = 'User Name';
  static const password = 'Password';
  static const poweredByG = 'Powered By G';
  static const loginFailed = 'Login Failed';
  static const authTokenNotReceived = 'Authentication token not received.';
  static const invalidUsernameOrPassword = 'Invalid username or password.';
  static const unableToLogin = 'Unable to login. Please try again.';

  // Domain dialog
  static const noDomains = 'No Domains';
  static const noDomainListReturned = 'No domain list returned from server.';

  // Home
  static const dashboard = 'Dashboard';
  static const assetsTab = 'ASSETS';
  static const equipmentsTab = 'EQUIPMENTS';
  static const noModulesAvailable = 'No modules available for your account.';

  // Menu titles
  static const assignAssetTag = 'Assign Asset Tag';
  static const deAssignAssetTag = 'DeAssign Asset Tag';
  static const assignLocationTag = 'Assign Location Tag';
  static const changeLocationByLocation = 'Change Location By Location';
  static const changeLocationByAsset = 'Change Location By Asset';
  static const identifyAsset = 'Identify Asset';
  static const searchAsset = 'Search Asset';
  static const auditAssets = 'Audit Assets';
  static const linkEquipmentTag = 'Link Equipment Tag';
  static const delinkEquipmentTag = 'Delink Equipment Tag';
  static const identifyEquipment = 'Identify Equipment';

  // Logout dialog
  static const logoutConfirmation = 'Are you sure you want to logout?';
  static const logoutFailed = 'Logout Failed';
  static const unableToLogout = 'Unable to logout.';
  static const unableToLogoutRetry = 'Unable to logout. Please try again.';

  // QR scanner
  static const scanQrBarcode = 'Scan QR / Barcode';
  static const unableToStartCamera = 'Unable to start camera.';
  static const alignQrWithinFrame = 'Align the QR / barcode within the frame';

  // Asset search
  static const typeToSearchAssets = 'Type to search assets.';
  static const noAssetsFound = 'No assets found.';

  // Assign asset tag
  static const assignTag = 'Assign Tag';
  static const assignFailed = 'Assign Failed';
  static const tagAssignedSuccessfully = 'Tag assigned successfully.';
  static const unableToAssignTag = 'Unable to assign tag.';
  static const unableToAssignTagRetry =
      'Unable to assign tag. Please try again.';
  static const assetRequired = 'Asset Required';
  static const selectAssetNameOrCode =
      'Please select an asset name or asset code.';

  // DeAssign asset tag
  static const fetchDetails = 'Fetch Details';
  static const fetchFailed = 'Fetch Failed';
  static const unableToFetchAssetDetails = 'Unable to fetch asset details.';
  static const unableToFetchAssetDetailsRetry =
      'Unable to fetch asset details. Please try again.';
  static const assetDetailsRequired = 'Asset Details Required';
  static const fetchDetailsBeforeDeassign =
      'Please fetch asset details before de-assigning.';
  static const deAssignFailed = 'DeAssign Failed';
  static const assetTagDeassignedSuccessfully =
      'Asset tag de-assigned successfully.';
  static const unableToDeassignAssetTag = 'Unable to de-assign asset tag.';
  static const unableToDeassignAssetTagRetry =
      'Unable to de-assign asset tag. Please try again.';

  // Assign location tag
  static const assignLocationWithAsset = 'Assign Location with Asset';
  static const assetQrRequired = 'Asset QR Required';
  static const enterAssetQrRfid =
      'Please scan or enter an asset QR / RFID value.';
  static const duplicateAsset = 'Duplicate Asset';
  static const assetTagAlreadyInList = 'This asset tag is already in the list.';
  static const locationRequired = 'Location Required';
  static const enterLocationQrRfid =
      'Please scan or enter a location QR / RFID value.';
  static const assetsRequired = 'Assets Required';
  static const addAtLeastOneAssetQr = 'Please add at least one asset QR code.';
  static const locationAssignedSuccessfully = 'Location assigned successfully.';
  static const unableToAssignLocation = 'Unable to assign location.';
  static const unableToAssignLocationRetry =
      'Unable to assign location. Please try again.';

  // Change location by location
  static const scanSourceLocation = 'Scan Source Location QR';
  static const scanDestinationLocationQr = 'Scan Destination Location QR';
  static const shift = 'Shift';
  static const transit = 'Transit';
  static const remarks = 'Remarks';
  static const selectRemarks = 'Select Remarks';
  static const assetNameOrTagCode = 'Asset name or Tag code';
  static const assetsDetails = 'Assets Details :';
  static const change = 'Change';
  static const changeTypeRequired = 'Change Type Required';
  static const selectShiftOrTransit = 'Please select Shift or Transit.';
  static const remarkRequired = 'Remark Required';
  static const selectRemarkFromDropdown = 'Please select a remark.';
  static const selectAtLeastOneAsset = 'Please select at least one asset.';
  static const destinationLocationRequired = 'Destination Location Required';
  static const enterDestinationLocationQrRfid =
      'Please scan or enter a destination location QR / RFID value.';
  static const changeLocationFailed = 'Change Failed';
  static const locationChangedSuccessfully = 'Location changed successfully.';
  static const unableToChangeLocation = 'Unable to change location.';
  static const unableToChangeLocationRetry =
      'Unable to change location. Please try again.';
  static const unableToFetchLocationDetails =
      'Unable to fetch location details.';
  static const unableToFetchLocationDetailsRetry =
      'Unable to fetch location details. Please try again.';
  static const noAssetsAtLocation = 'No assets found at this location.';

  // Change location by asset
  static const scanAssetQrOrPressButton = 'Scan Asset QR or Press Button for RFID';
  static const currentLocation = 'Current Location';
  static const update = 'Update';
  static const addAssetTagRequired = 'Asset Tag Required';
  static const addAtLeastOneAssetTag = 'Please add at least one asset tag.';
  static const identifyAssetsFailed = 'Identify Assets Failed';
  static const unableToIdentifyAssets = 'Unable to identify assets.';
  static const duplicateAssetTag = 'Duplicate Asset Tag';
  static const assetTagAlreadyAdded = 'This asset tag is already in the list.';
  static const identifiedAssetsRequired = 'Identified Assets Required';
  static const identifyAssetsBeforeUpdate =
      'Please identify assets before updating location.';

  // Link equipment tag
  static const equipmentNameOrCode = 'Equipment name or code';
  static const linkTag = 'Link Tag';
  static const startTypingToSearchEquipment =
      'Start typing to search equipment';
  static const noResultsFound = 'No results found';
  static const equipmentRequired = 'Equipment Required';
  static const selectEquipmentFirst = 'Please select equipment first.';
  static const equipmentTagLinkedSuccessfully =
      'Equipment tag linked successfully.';
  static const unableToLinkEquipmentTag = 'Unable to link equipment tag.';
  static const unableToLinkEquipmentTagRetry =
      'Unable to link equipment tag. Please try again.';
  static const unableToFetchEquipmentList =
      'Unable to fetch equipment list. Please try again.';

  // Delink equipment tag
  static const delinkTag = 'Delink Tag';
  static const confirmDelink = 'Confirm Delink';
  static const confirmDelinkEquipmentMessage =
      'Are you sure you want to delink this equipment?';
  static const yes = 'Yes';
  static const no = 'No';
  static const equipmentDetailsRequired = 'Equipment Details Required';
  static const fetchDetailsBeforeDelink =
      'Please fetch equipment details before delinking.';
  static const unableToFetchEquipmentDetails =
      'Unable to fetch equipment details.';
  static const unableToFetchEquipmentDetailsRetry =
      'Unable to fetch equipment details. Please try again.';
  static const equipmentTagDelinkedSuccessfully =
      'Equipment tag delinked successfully.';
  static const unableToDelinkEquipmentTag = 'Unable to delink equipment tag.';
  static const unableToDelinkEquipmentTagRetry =
      'Unable to delink equipment tag. Please try again.';

  // Identify equipment
  static const jobCardNumber = 'Job Card Number';
  static const unableToDownloadJobCardReport =
      'Unable to download job card report.';
  static const storagePermissionRequired =
      'Storage permission is required to download the job card PDF.';

  // Search asset
  static const assetNameCodeOrTagCode = 'Asset name/code or Tag code';
  static const stopTrackingBeforeChangingAsset =
      'Please stop tracking before selecting another asset.';
  static const unableToStartAssetTracking = 'Unable to start asset tracking.';
  static const unableToStartAssetTrackingRetry =
      'Unable to start asset tracking. Please try again.';
  static const trackingDataSavedSuccessfully =
      'Tracking data saved successfully.';
  static const unableToSaveTrackingData = 'Unable to save tracking data.';
  static const unableToSaveTrackingDataRetry =
      'Unable to save tracking data. Please try again.';
  static const noTrackingDataScanned =
      'Scanning has been stopped. No data was scanned.';

  // Audit assets
  static const selectAuditName = 'Select Audit Name';
  static const totalAssets = 'Total Assets';
  static const assetsFound = 'Assets Found';
  static const missingAssets = 'Missing Assets';
  static const alienAssets = 'Alien Assets';
  static const invalidTagCount = 'Invalid Tag Count';
  static const validUnassignedTagCount = 'Valid Unassigned Tag Count';
  static const start = 'Start';
  static const stop = 'Stop';
  static const noAuditsFound = 'No audits found.';
  static const scanFailed = 'Scan Failed';
  static const rfidReaderUnavailable =
      'RFID reader is not available. Please connect the device.';
  static const unableToFetchAuditsRetry =
      'Unable to fetch audits. Please try again.';
  static const unableToFetchAuditSummaryRetry =
      'Unable to fetch audit summary. Please try again.';
  static const auditDataSavedSuccessfully = 'Audit data saved successfully.';
  static const unableToSaveAuditData = 'Unable to save audit data.';
  static const unableToSaveAuditDataRetry =
      'Unable to save audit data. Please try again.';

  // Shared validation / snackbars
  static const qrRfidRequired = 'QR / RFID Required';
  static const scanOrEnterQrRfid = 'Please scan or enter a QR / RFID value.';
  static const scanOrEnterQrRfidFirst =
      'Please scan or enter a QR / RFID value first.';

  // Formatted strings
  static String version(String value) =>
      'Version ${value.isEmpty ? notAvailable : value}';

  static String macAddress(String value) => 'Mac Address : $value';

  static String cameraError(String errorCode) =>
      '$unableToStartCamera\n$errorCode';
}
