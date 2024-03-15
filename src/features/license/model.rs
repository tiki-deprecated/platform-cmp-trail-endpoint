/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;
use chrono::{DateTime, Utc};
use crate::features::record::Record;

use super::{Contents, super::{repository, super::utils::{ContentSchema, ContentType}}};
use mytiki_core_trail_storage::{byte_helpers};

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

  fn to_transaction(&self) -> Result<repository::Transaction, Box<dyn Error>> {
        let contents = self.contents.to_bytes()?;
        let bytes = ContentSchema::title().serialize(&contents)?;
        let contents = byte_helpers::base64_encode(&bytes);
        let transaction = repository::Transaction::new(&contents, &self.user_signature, Some(self.timestamp), None );
        Ok(transaction)
    }
}
