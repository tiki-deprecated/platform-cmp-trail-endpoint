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
    pub fn new(uses: Vec<UseCase>, terms: String, description: Option<String>, expiry: Option<DateTime<Utc>>) -> Self {
        Self { uses, terms, description, expiry }
    }
    
    pub fn to_bytes(&self) -> Result<Vec<u8>, Box<dyn Error>> {
        let mut bytes = Vec::<u8>::new();
        let uses = serde_json::to_string(&self.uses)?;
        bytes.append(&mut compact_size::encode(byte_helpers::utf8_encode(&uses)));
        bytes.append(&mut compact_size::encode(byte_helpers::utf8_encode(&self.terms)));
        if self.description.is_some() { bytes.append(&mut compact_size::encode(byte_helpers::utf8_encode(&self.terms))); } 
        else { bytes.append(&mut vec![1]); };
        if self.expiry.is_some() {
            let expiry_bigint = &BigInt::from(self.expiry.unwrap().timestamp());
            bytes.append(&mut compact_size::encode(byte_helpers::encode_bigint(expiry_bigint)));
        } else { bytes.append(&mut vec![1]); };
        Ok(bytes)
    }
   
}