/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;
use chrono::DateTime;
use num_bigint::BigInt;
use mytiki_core_trail_storage::{byte_helpers, compact_size, ModelTxn};
use crate::utils::{ContentSchema, ContentType};

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

    
}