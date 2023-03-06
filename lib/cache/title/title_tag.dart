/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'title_tag_enum.dart';

/// Tags are included in the [TitleRecord] and describe the represented data
/// asset. Tags improve record searchability and come in handy when bulk
/// searching and filtering licenses. Use either our list of common
/// enumerations or define your own using [TitleTag.custom].
class TitleTag {
  final String _value;

  /// @nodoc
  TitleTag(TitleTagEnum tag) : _value = tag.value;
  TitleTag.emailAddress() : _value = TitleTagEnum.emailAddress.value;
  TitleTag.phoneNumber() : _value = TitleTagEnum.phoneNumber.value;
  TitleTag.physicalAddress() : _value = TitleTagEnum.physicalAddress.value;
  TitleTag.contactInfo() : _value = TitleTagEnum.contactInfo.value;
  TitleTag.health() : _value = TitleTagEnum.health.value;
  TitleTag.fitness() : _value = TitleTagEnum.fitness.value;
  TitleTag.paymentInfo() : _value = TitleTagEnum.paymentInfo.value;
  TitleTag.creditInfo() : _value = TitleTagEnum.creditInfo.value;
  TitleTag.financialInfo() : _value = TitleTagEnum.financialInfo.value;
  TitleTag.preciseLocation() : _value = TitleTagEnum.preciseLocation.value;
  TitleTag.coarseLocation() : _value = TitleTagEnum.coarseLocation.value;
  TitleTag.sensitiveInfo() : _value = TitleTagEnum.sensitiveInfo.value;
  TitleTag.contacts() : _value = TitleTagEnum.contacts.value;
  TitleTag.messages() : _value = TitleTagEnum.messages.value;
  TitleTag.photoVideo() : _value = TitleTagEnum.photoVideo.value;
  TitleTag.audio() : _value = TitleTagEnum.audio.value;
  TitleTag.gameplayContent() : _value = TitleTagEnum.gameplayContent.value;
  TitleTag.customerSupport() : _value = TitleTagEnum.customerSupport.value;
  TitleTag.userContent() : _value = TitleTagEnum.userContent.value;
  TitleTag.browsingHistory() : _value = TitleTagEnum.browsingHistory.value;
  TitleTag.searchHistory() : _value = TitleTagEnum.searchHistory.value;
  TitleTag.userId() : _value = TitleTagEnum.userId.value;
  TitleTag.deviceId() : _value = TitleTagEnum.deviceId.value;
  TitleTag.purchaseHistory() : _value = TitleTagEnum.purchaseHistory.value;
  TitleTag.productInteraction()
      : _value = TitleTagEnum.productInteraction.value;
  TitleTag.advertisingData() : _value = TitleTagEnum.advertisingData.value;
  TitleTag.usageData() : _value = TitleTagEnum.usageData.value;
  TitleTag.crashData() : _value = TitleTagEnum.crashData.value;
  TitleTag.performanceData() : _value = TitleTagEnum.performanceData.value;
  TitleTag.diagnosticData() : _value = TitleTagEnum.diagnosticData.value;

  /// Add a custom tag using the format of custom:<tag>
  TitleTag.custom(String customTag) : _value = "custom:$customTag";

  /// Builds a [TitleTag] from [value]
  factory TitleTag.from(String value) {
    try {
      TitleTagEnum tag = TitleTagEnum.fromValue(value);
      return TitleTag(tag);
    } catch (e) {
      return TitleTag.custom(value.replaceFirst('custom:', ''));
    }
  }

  /// Returns the string value for the tag
  String get value => _value;
}
