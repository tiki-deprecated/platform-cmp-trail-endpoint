/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Eq, PartialEq)]
pub enum TagType {
    EmailAddress,
    PhoneNumber,
    PhysicalAddress,
    ContactInfo,
    Health,
    Fitness,
    PaymentInfo,
    CreditInfo,
    FinancialInfo,
    PreciseLocation,
    CoarseLocation,
    SensitiveInfo,
    Contacts,
    Messages,
    PhotoVideo,
    Audio,
    GameplayContent,
    CustomerSupport,
    UserContent,
    BrowsingHistory,
    SearchHistory,
    UserId,
    DeviceId,
    PurchaseHistory,
    ProductInteraction,
    AdvertisingData,
    UsageData,
    CrashData,
    PerformanceData,
    DiagnosticData,
    Custom
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Tag {
    typ:  TagType,
    value: String
}

impl Tag {
    pub fn typ(&self) -> &TagType { &self.typ }
    pub fn value(&self) -> &str { &self.value }
    
    pub fn new(string: &str) -> Self {
        let string = string.trim();
        match string { 
            "email_address" => Tag { typ: TagType::EmailAddress, value: string.to_string() },
            "phone_number" => Tag { typ: TagType::PhoneNumber, value: string.to_string() },
            "physical_address" => Tag { typ: TagType::PhysicalAddress, value: string.to_string() },
            "contact_info" => Tag { typ: TagType::ContactInfo, value: string.to_string() },
            "health" => Tag { typ: TagType::Health, value: string.to_string() },
            "fitness" => Tag { typ: TagType::Fitness, value: string.to_string() },
            "payment_info" => Tag { typ: TagType::PaymentInfo, value: string.to_string() },
            "credit_info" => Tag { typ: TagType::CreditInfo, value: string.to_string() },
            "financial_info" => Tag { typ: TagType::FinancialInfo, value: string.to_string() },
            "precise_location" => Tag { typ: TagType::PreciseLocation, value: string.to_string() },
            "coarse_location" => Tag { typ: TagType::CoarseLocation, value: string.to_string() },
            "sensitive_info" => Tag { typ: TagType::SensitiveInfo, value: string.to_string() },
            "contacts" => Tag { typ: TagType::Contacts, value: string.to_string() },
            "messages" => Tag { typ: TagType::Messages, value: string.to_string() },
            "photo_video" => Tag { typ: TagType::PhotoVideo, value: string.to_string() },
            "audio" => Tag { typ: TagType::Audio, value: string.to_string() },
            "gameplay_content" => Tag { typ: TagType::GameplayContent, value: string.to_string() },
            "customer_support" => Tag { typ: TagType::CustomerSupport, value: string.to_string() },
            "user_content" => Tag { typ: TagType::UserContent, value: string.to_string() },
            "browsing_history" => Tag { typ: TagType::BrowsingHistory, value: string.to_string() },
            "search_history" => Tag { typ: TagType::SearchHistory, value: string.to_string() },
            "user_id" => Tag { typ: TagType::UserId, value: string.to_string() },
            "device_id" => Tag { typ: TagType::DeviceId, value: string.to_string() },
            "purchase_history" => Tag { typ: TagType::PurchaseHistory, value: string.to_string() },
            "product_interaction" => Tag { typ: TagType::ProductInteraction, value: string.to_string() },
            "advertising_data" => Tag { typ: TagType::AdvertisingData, value: string.to_string() },
            "usage_data" => Tag { typ: TagType::UsageData, value: string.to_string() },
            "crash_data" => Tag { typ: TagType::CrashData, value: string.to_string() },
            "performance_data" => Tag { typ: TagType::PerformanceData, value: string.to_string() },
            "diagnostic_data" => Tag { typ: TagType::DiagnosticData, value: string.to_string() },
            _ => {
                let value = if string.starts_with("custom:") { string.to_string() } else { format!("custom:{}", string) };
                Tag { typ: TagType::Custom, value }
            }
        } 
    }
}

impl Serialize for Tag {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where S: serde::Serializer {
        serializer.serialize_str(self.value())
    }
}

impl<'de> Deserialize<'de> for Tag {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where D: serde::Deserializer<'de> {
        let string = String::deserialize(deserializer)?;
        Ok(Tag::new(&string))
    }
}

#[cfg(test)]
mod tests {
    use super::{Tag, TagType};

    #[test]
    fn test_deserialize_email() {
        let json = "\"email_address\"";
        let tag: Tag = serde_json::from_str(json).unwrap();
        assert_eq!(tag.typ(), &TagType::EmailAddress);
    }

    #[test]
    fn test_serialize_email() {
        let tag: Tag = Tag::new("email_address");
        let json = serde_json::to_string(&tag).unwrap();
        assert_eq!(json, "\"email_address\"");
    }
    
    #[test]
    fn test_new_custom_prefix() {
        let tag: Tag = Tag::new("custom:one");
        assert_eq!(tag.typ(), &TagType::Custom);
        assert_eq!(tag.value, "custom:one");
    }

    #[test]
    fn test_new_custom_no_prefix() {
        let tag: Tag = Tag::new("one");
        assert_eq!(tag.typ(), &TagType::Custom);
        assert_eq!(tag.value, "custom:one");
    }
    
    #[test]
    fn test_deserialize_custom() {
        let json = "\"custom:one\"";
        let tag: Tag = serde_json::from_str(json).unwrap();
        assert_eq!(tag.typ(), &TagType::Custom);
        assert_eq!(tag.value, "custom:one");
    }
    
    #[test]
    fn test_serialize_custom() {
        let tag: Tag = Tag::new("one");
        let json = serde_json::to_string(&tag).unwrap();
        assert_eq!(json, "\"custom:one\"");
    }
}