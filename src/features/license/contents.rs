/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;
use chrono::{DateTime, Utc};
use super::UseCase;
use mytiki_core_trail_storage::{byte_helpers, compact_size};
use num_bigint::BigInt;

pub struct Contents {
    uses: Vec<UseCase>,
    terms: String,
    description: Option<String>,
    expiry: Option<DateTime<Utc>>,
}

impl Contents {
    pub fn new(uses: Vec<UseCase>, terms: &str, description: Option<String>, expiry: Option<DateTime<Utc>>) -> Self {
        Self { uses, terms: terms.to_string(), description, expiry }
    }
    
    pub fn uses(&self) -> &Vec<UseCase> { &self.uses }
    pub fn terms(&self) -> &str { &self.terms }
    pub fn description(&self) -> &Option<String> { &self.description }
    pub fn expiry(&self) -> Option<DateTime<Utc>> { self.expiry }
    
    pub fn to_bytes(&self) -> Result<Vec<u8>, Box<dyn Error>> {
        let mut bytes = Vec::<u8>::new();
        let uses = serde_json::to_string(&self.uses)?;
        bytes.append(&mut compact_size::encode(byte_helpers::utf8_encode(&uses)));
        bytes.append(&mut compact_size::encode(byte_helpers::utf8_encode(&self.terms)));
        if self.description.is_some() { 
            let description = self.description.as_ref().unwrap();
            bytes.append(&mut compact_size::encode(byte_helpers::utf8_encode(description))); } 
        else { bytes.append(&mut vec![0]); };
        if self.expiry.is_some() {
            let expiry_bigint = &BigInt::from(self.expiry.unwrap().timestamp());
            bytes.append(&mut compact_size::encode(byte_helpers::encode_bigint(expiry_bigint)));
        } else { bytes.append(&mut vec![0]); };
        Ok(bytes)
    }
    
    pub fn from_bytes(bytes: &Vec<u8>) -> Result<Self, Box<dyn Error>> {
        let decoded = compact_size::decode(bytes);
        let uses = &byte_helpers::utf8_decode(&decoded[0])?;
        let uses = serde_json::from_str(uses)?;
        let terms = byte_helpers::utf8_decode(&decoded[1])?;
        let description = byte_helpers::utf8_decode(&decoded[2])?;
        let description = if description.is_empty() { None } else { Some(description) };
        let expiry = byte_helpers::decode_bigint(&decoded[3]);
        let expiry = if expiry == BigInt::from(0) { None } else { DateTime::from_timestamp(expiry.to_string().parse::<i64>()?, 0) };
        Ok(Self { uses, terms, description, expiry })
    }
}

#[cfg(test)]
mod tests {
    use chrono::Utc;
    use super::{Contents, super::UseCase};

    #[test]
    fn test_bytes_basic() {
        let contents = Contents::new(vec![UseCase::attribution()], "dummy", None, None);
        let bytes = contents.to_bytes().unwrap();
        let decoded = Contents::from_bytes(&bytes).unwrap();
        assert_eq!(contents.uses, decoded.uses);
        assert_eq!(contents.terms, decoded.terms);
        assert_eq!(contents.description, decoded.description);
        assert_eq!(contents.expiry, decoded.expiry);
    }

    #[test]
    fn test_bytes_all() {
        let contents = Contents::new(vec![UseCase::attribution()], "dummy", Some("dummy".to_string()), Some(Utc::now()));
        let bytes = contents.to_bytes().unwrap();
        let decoded = Contents::from_bytes(&bytes).unwrap();
        assert_eq!(contents.uses, decoded.uses);
        assert_eq!(contents.terms, decoded.terms);
        assert_eq!(contents.description, decoded.description);
        assert_eq!(contents.expiry.unwrap().timestamp(), decoded.expiry.unwrap().timestamp());
    }
}