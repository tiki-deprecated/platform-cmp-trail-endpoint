/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'title_tag_enum.dart';

class TitleTag {
  final String _value;

  TitleTag(TitleTagEnum tag) : _value = tag.value;
  const TitleTag.emailAddress() : _value = "email_address";
  const TitleTag.phoneNumber() : _value = "phone_number";
  const TitleTag.physicalAddress() : _value = "physical_address";
  const TitleTag.contactInfo() : _value = "contact_info";
  const TitleTag.health() : _value = "health";
  const TitleTag.fitness() : _value = "fitness";
  const TitleTag.paymentInfo() : _value = "payment_info";
  const TitleTag.creditInfo() : _value = "credit_info";
  const TitleTag.financialInfo() : _value = "financial_info";
  const TitleTag.preciseLocation() : _value = "precise_location";
  const TitleTag.coarseLocation() : _value = "coarse_location";
  const TitleTag.sensitiveInfo() : _value = "sensitive_info";
  const TitleTag.contacts() : _value = "contacts";
  const TitleTag.messages() : _value = "messages";
  const TitleTag.photoVideo() : _value = "photo_video";
  const TitleTag.audio() : _value = "audio";
  const TitleTag.gameplayContent() : _value = "gameplay_content";
  const TitleTag.customerSupport() : _value = "customer_support";
  const TitleTag.userContent() : _value = "user_content";
  const TitleTag.browsingHistory() : _value = "browsing_history";
  const TitleTag.searchHistory() : _value = "search_history";
  const TitleTag.userId() : _value = "user_id";
  const TitleTag.deviceId() : _value = "device_id";
  const TitleTag.purchaseHistory() : _value = "purchase_history";
  const TitleTag.productInteraction() : _value = "product_interaction";
  const TitleTag.advertisingData() : _value = "advertising_data";
  const TitleTag.usageData() : _value = "usage_data";
  const TitleTag.crashData() : _value = "crash_data";
  const TitleTag.performanceData() : _value = "performance_data";
  const TitleTag.diagnosticData() : _value = "diagnostic_data";
  const TitleTag.custom(String customTag) : _value = "custom:$customTag";

  factory TitleTag.from(String value) {
    try {
      TitleTagEnum tag = TitleTagEnum.fromValue(value);
      return TitleTag(tag);
    } catch (e) {
      return TitleTag.custom(value);
    }
  }

  String get value => _value;
}
