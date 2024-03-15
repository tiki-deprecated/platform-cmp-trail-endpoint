/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;
use chrono::{DateTime, Utc};
use crate::utils::{ContentSchema, ContentType};
use crate::features::record::Record;

use super::Contents;
use mytiki_core_trail_storage::{byte_helpers::{self, base64_encode}, compact_size, ModelTxn, Signer};

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
}


impl Record<Model> for Model {

  fn from_transaction(transaction: ModelTxn) -> Result<Self, Box<dyn Error>> {
    let schema = ContentSchema::deserialize(&transaction.bytes())?;
    if schema.0.typ().clone() != ContentType::Title { Err("Not a title")? }
    let decoded = compact_size::decode(&schema.1);
    let ptr = byte_helpers::utf8_decode(&decoded[0])?;
    let origin = byte_helpers::utf8_decode(&decoded[1])?;
    let description = byte_helpers::utf8_decode(&decoded[2])?;
    let description = if description.is_empty() { None } else { Some(description) };
    let tags = byte_helpers::utf8_decode(&decoded[3])?;
    let tags = serde_json::from_str(&tags)?;
    let contents = Contents::new(ptr.as_str(), origin.as_str(), tags, description);
    Ok(Self {
        id: Some(transaction.id().to_string()),
        timestamp: transaction.timestamp(),
        contents,
        user_signature: transaction.user_signature().to_string()
    })
  }
  
  fn to_transaction(&self, address: &str, signer: &Signer) -> Result<ModelTxn, Box<dyn Error>> {
      let contents = &self.contents.to_bytes()?;
      let bytes = ContentSchema::title().serialize(&contents)?;
      let txn = ModelTxn::new(
        address,
        self.timestamp,
        "", 
        base64_encode(contents).as_str(),
        self.user_signature.as_str(),
        signer,
      );
      Ok(txn?)
  }
}
