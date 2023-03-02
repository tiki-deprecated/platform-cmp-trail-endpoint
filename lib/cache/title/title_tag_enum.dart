/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

enum TitleTagEnum {
  emailAddress("email_address"),
  phoneNumber("phone_number"),
  physicalAddress("physical_address"),
  contactInfo("contact_info"),
  health("health"),
  fitness("fitness"),
  paymentInfo("payment_info"),
  creditInfo("credit_info"),
  financialInfo("financial_info"),
  preciseLocation("precise_location"),
  coarseLocation("coarse_location"),
  sensitiveInfo("sensitive_info"),
  contacts("contacts"),
  messages("messages"),
  photoVideo("photo_video"),
  audio("audio"),
  gameplayContent("gameplay_content"),
  customerSupport("customer_support"),
  userContent("user_content"),
  browsingHistory("browsing_history"),
  searchHistory("search_history"),
  userId("user_id"),
  deviceId("device_id"),
  purchaseHistory("purchase_history"),
  productInteraction("product_interaction"),
  advertisingData("advertising_data"),
  usageData("usage_data"),
  crashData("crash_data"),
  performanceData("performance_data"),
  diagnosticData("diagnostic_data");

  final String _value;

  const TitleTagEnum(this._value);

  String get value => _value;

  /// Builds a TitleTagEnum from [value]
  factory TitleTagEnum.fromValue(String value) {
    for (TitleTagEnum type in TitleTagEnum.values) {
      if (type.value == value) {
        return type;
      }
    }
    throw ArgumentError.value(
        value, 'value', 'Invalid TitleTagEnum value $value');
  }
}
