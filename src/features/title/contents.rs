/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;
use chrono::DateTime;
use num_bigint::BigInt;
use mytiki_core_trail_storage::{byte_helpers, compact_size};
use super::Tag;

pub struct Contents {
    ptr: String,
    origin: String,
    tags: Vec<Tag>,
    description: Option<String>
}

impl Contents {
    pub fn new(ptr: &str, origin: &str, tags: Vec<Tag>, description: Option<String>) -> Self {
        Self { ptr: ptr.to_string(), origin: origin.to_string(), tags, description }
    }
    
    pub fn ptr(&self) -> &str { &self.ptr }
    pub fn origin(&self) -> &str { &self.origin }
    pub fn tags(&self) -> &Vec<Tag> { &self.tags }
    pub fn description(&self) -> &Option<String> { &self.description }

    pub fn to_bytes(&self) -> Result<Vec<u8>, Box<dyn Error>> {
        let mut bytes = Vec::<u8>::new();
        let tags = serde_json::to_string(&self.tags)?;
        bytes.append(&mut compact_size::encode(byte_helpers::utf8_encode(&self.ptr)));
        bytes.append(&mut compact_size::encode(byte_helpers::utf8_encode(&self.origin)));
        if self.description.is_some() {
            let description = self.description.as_ref().unwrap();
            bytes.append(&mut compact_size::encode(byte_helpers::utf8_encode(&description))); 
        }
        else { bytes.append(&mut vec![0]); };
        bytes.append(&mut compact_size::encode(byte_helpers::utf8_encode(&tags)));
        Ok(bytes)
    }

    pub fn from_bytes(bytes: &Vec<u8>) -> Result<Self, Box<dyn Error>> {
        let decoded = compact_size::decode(bytes);
        let ptr = byte_helpers::utf8_decode(&decoded[0])?;
        let origin = byte_helpers::utf8_decode(&decoded[1])?;
        let description = byte_helpers::utf8_decode(&decoded[2])?;
        let description = if description.is_empty() { None } else { Some(description) };
        let tags = byte_helpers::utf8_decode(&decoded[3])?;
        let tags = serde_json::from_str(&tags)?;
        Ok(Self { ptr, origin, description, tags })
    }
}

#[cfg(test)]
mod tests {
    use super::{Contents, super::Tag};

    #[test]
    fn test_bytes_basic() {
        let contents = Contents::new("dummy", "dummy", vec![Tag::email_address()], None);
        let bytes = contents.to_bytes().unwrap();
        let decoded = Contents::from_bytes(&bytes).unwrap();
        assert_eq!(contents.tags, decoded.tags);
        assert_eq!(contents.ptr, decoded.ptr);
        assert_eq!(contents.description, decoded.description);
        assert_eq!(contents.origin, decoded.origin);
    }

    #[test]
    fn test_bytes_all() {
        let contents = Contents::new("dummy", "dummy", vec![Tag::email_address()], Some("dummy".to_string()));
        let bytes = contents.to_bytes().unwrap();
        let decoded = Contents::from_bytes(&bytes).unwrap();
        assert_eq!(contents.tags, decoded.tags);
        assert_eq!(contents.ptr, decoded.ptr);
        assert_eq!(contents.description, decoded.description);
        assert_eq!(contents.origin, decoded.origin);
    }
}