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

  // Common labels
  static const userLabel = 'User :';
  static const assetName = 'Asset Name';
  static const assetCode = 'Asset Code';
  static const serialNo = 'Serial No.';
  static const scanAssetQr = 'Scan Asset QR';
  static const scanQrOrPressButton = 'Scan QR or Press Button for RFID';
  static const scanLocationQrHere = 'Scan Location QR Here';
  static const assetNameOrCode = 'Asset name or Asset code';
  static const assetSerialNumber = 'Asset Serial Number';
  static const rfidReaderConnected = 'RFID reader connected';
  static const removeAsset = 'Remove asset';

  // System titles
  static const assetTrackingSystem =
      'Asset Tracking and Management\nSystem';
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
  static const logoutConfirmation =
      'Are you sure you want to logout?';
  static const logoutFailed = 'Logout Failed';
  static const unableToLogout = 'Unable to logout.';
  static const unableToLogoutRetry = 'Unable to logout. Please try again.';

  // QR scanner
  static const scanQrBarcode = 'Scan QR / Barcode';
  static const unableToStartCamera = 'Unable to start camera.';
  static const alignQrWithinFrame =
      'Align the QR / barcode within the frame';

  // Asset search
  static const typeToSearchAssets = 'Type to search assets.';
  static const noAssetsFound = 'No assets found.';

  // Assign asset tag
  static const assignTag = 'Assign Tag';
  static const assignFailed = 'Assign Failed';
  static const tagAssignedSuccessfully = 'Tag assigned successfully.';
  static const unableToAssignTag = 'Unable to assign tag.';
  static const unableToAssignTagRetry = 'Unable to assign tag. Please try again.';
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
  static const enterAssetQrRfid = 'Please scan or enter an asset QR / RFID value.';
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
