/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;
use chrono::{DateTime, Utc};
use super::{Contents, super::{repository, super::utils::{ContentSchema, ContentType}}};
use mytiki_core_trail_storage::{byte_helpers, Transaction};

pub struct Model {
    id: Option<String>,
    timestamp: DateTime<Utc>,
    contents: Contents,
    user_signature: String
}

impl Model {
    pub fn new(contents: Contents, user_signature: &str) -> Model {
        Model { id: None, timestamp: Utc::now(), contents, user_signature: user_signature.to_string() }
    }
    
    pub fn from_transaction(transaction: &Transaction) -> Result<Self, Box<dyn Error>> { 
        let contents = byte_helpers::base64_decode(&transaction.contents())?;
        let schema = ContentSchema::deserialize(&contents)?;
        if schema.0.typ().clone() != ContentType::Title { Err("Not a title")? }
        let contents = Contents::from_bytes(&schema.1)?;
        Ok(Self {
            id: Some(transaction.id().to_string()),
            timestamp: transaction.timestamp(),
            contents,
            user_signature: transaction.user_signature().to_string()
        })
    }
    
    pub fn to_transaction(&self) -> Result<Transaction, Box<dyn Error>> {
        let contents = self.contents.to_bytes()?;
        let bytes = ContentSchema::title().serialize(&contents)?;
        
        Transaction::new()
        
        
        
        Ok(transaction)
    }
}