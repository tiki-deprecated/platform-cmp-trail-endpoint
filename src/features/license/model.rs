/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;
use chrono::{DateTime, Utc};
use crate::features::record::Record;

use super::{super::{super::utils::{ContentSchema, ContentType}, repository}, contents::Contents, UseCase};
use mytiki_core_trail_storage::{byte_helpers::{self, base64_encode}, ModelTxn, Owner, Signer};

pub struct Model {
    id: Option<String>,
    title: String,
    timestamp: DateTime<Utc>,
    contents: Contents,
    user_signature: String
}

impl Model {
  pub fn new(title: String, uses: Vec<UseCase>, terms: &str, description: Option<String>, expiry: Option<DateTime<Utc>>, user_signature: &str) -> Model {
      let contents = Contents::new(uses, terms, description, expiry);
      Model { id: None, title, timestamp: Utc::now(), contents, user_signature: user_signature.to_string() }
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
            title: transaction.asset_ref().to_string(),
            timestamp: transaction.timestamp(),
            contents,
            user_signature: transaction.user_signature().to_string()
        })
    }

    fn to_transaction(&self, owner: &Owner, signer: &Signer) -> Result<ModelTxn, Box<dyn Error>> {
      let contents = &self.contents.to_bytes()?;
      let bytes = ContentSchema::title().serialize(&contents)?;
      let txn = ModelTxn::new(
        self.timestamp,
        self.title.as_str(), 
        base64_encode(contents).as_str(),
        self.user_signature.as_str(),
        owner,
        signer,
      )?;
      self.id = Some(txn.id().to_string());
      Ok(txn)
    }
}
