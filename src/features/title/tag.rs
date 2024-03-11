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
            "email_address" => Self { typ: TagType::EmailAddress, value: string.to_string() },
            "phone_number" => Self { typ: TagType::PhoneNumber, value: string.to_string() },
            "physical_address" => Self { typ: TagType::PhysicalAddress, value: string.to_string() },
            "contact_info" => Self { typ: TagType::ContactInfo, value: string.to_string() },
            "health" => Self { typ: TagType::Health, value: string.to_string() },
            "fitness" => Self { typ: TagType::Fitness, value: string.to_string() },
            "payment_info" => Self { typ: TagType::PaymentInfo, value: string.to_string() },
            "credit_info" => Self { typ: TagType::CreditInfo, value: string.to_string() },
            "financial_info" => Self { typ: TagType::FinancialInfo, value: string.to_string() },
            "precise_location" => Self { typ: TagType::PreciseLocation, value: string.to_string() },
            "coarse_location" => Self { typ: TagType::CoarseLocation, value: string.to_string() },
            "sensitive_info" => Self { typ: TagType::SensitiveInfo, value: string.to_string() },
            "contacts" => Self { typ: TagType::Contacts, value: string.to_string() },
            "messages" => Self { typ: TagType::Messages, value: string.to_string() },
            "photo_video" => Self { typ: TagType::PhotoVideo, value: string.to_string() },
            "audio" => Self { typ: TagType::Audio, value: string.to_string() },
            "gameplay_content" => Self { typ: TagType::GameplayContent, value: string.to_string() },
            "customer_support" => Self { typ: TagType::CustomerSupport, value: string.to_string() },
            "user_content" => Self { typ: TagType::UserContent, value: string.to_string() },
            "browsing_history" => Self { typ: TagType::BrowsingHistory, value: string.to_string() },
            "search_history" => Self { typ: TagType::SearchHistory, value: string.to_string() },
            "user_id" => Self { typ: TagType::UserId, value: string.to_string() },
            "device_id" => Self { typ: TagType::DeviceId, value: string.to_string() },
            "purchase_history" => Self { typ: TagType::PurchaseHistory, value: string.to_string() },
            "product_interaction" => Self { typ: TagType::ProductInteraction, value: string.to_string() },
            "advertising_data" => Self { typ: TagType::AdvertisingData, value: string.to_string() },
            "usage_data" => Self { typ: TagType::UsageData, value: string.to_string() },
            "crash_data" => Self { typ: TagType::CrashData, value: string.to_string() },
            "performance_data" => Self { typ: TagType::PerformanceData, value: string.to_string() },
            "diagnostic_data" => Self { typ: TagType::DiagnosticData, value: string.to_string() },
            _ => {
                let value = if string.starts_with("custom:") { string.to_string() } else { format!("custom:{}", string) };
                Self { typ: TagType::Custom, value }
            }
        } 
    }
    
    pub fn email_address() -> Self { Tag::new("email_address") }
    pub fn phone_number() -> Self { Tag::new("phone_number") }
    pub fn physical_address() -> Self { Tag::new("physical_address") }
    pub fn contact_info() -> Self { Tag::new("contact_info") }
    pub fn health() -> Self { Tag::new("health") }
    pub fn fitness() -> Self { Tag::new("fitness") }
    pub fn payment_info() -> Self { Tag::new("payment_info") }
    pub fn credit_info() -> Self { Tag::new("credit_info") }
    pub fn financial_info() -> Self { Tag::new("financial_info") }
    pub fn precise_location() -> Self { Tag::new("precise_location") }
    pub fn coarse_location() -> Self { Tag::new("coarse_location") }
    pub fn sensitive_info() -> Self { Tag::new("sensitive_info") }
    pub fn contacts() -> Self { Tag::new("contacts") }
    pub fn messages() -> Self { Tag::new("messages") }
    pub fn photo_video() -> Self { Tag::new("photo_video") }
    pub fn audio() -> Self { Tag::new("audio") }
    pub fn gameplay_content() -> Self { Tag::new("gameplay_content") }
    pub fn customer_support() -> Self { Tag::new("customer_support") }
    pub fn user_content() -> Self { Tag::new("user_content") }  
    pub fn browsing_history() -> Self { Tag::new("browsing_history") }
    pub fn search_history() -> Self { Tag::new("search_history") }
    pub fn user_id() -> Self { Tag::new("user_id") }
    pub fn device_id() -> Self { Tag::new("device_id") }
    pub fn purchase_history() -> Self { Tag::new("purchase_history") }
    pub fn product_interaction() -> Self { Tag::new("product_interaction") }
    pub fn advertising_data() -> Self { Tag::new("advertising_data") }
    pub fn usage_data() -> Self { Tag::new("usage_data") }
    pub fn crash_data() -> Self { Tag::new("crash_data") }
    pub fn performance_data() -> Self { Tag::new("performance_data") }
    pub fn diagnostic_data() -> Self { Tag::new("diagnostic_data") }
    pub fn custom(string: &str) -> Self { Self::new(&format!("customer:{}", string))}
    
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