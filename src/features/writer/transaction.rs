/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Transaction {
    #[serde(default = "Utc::now")]
    timestamp: DateTime<Utc>,
    #[serde(default)]
    asset_ref: String,
    contents: String,
    user_signature: String
}

#[allow(unused)]
impl Transaction {
    pub fn new(contents: String, user_signature: String, timestamp: Option<DateTime<Utc>>, asset_ref: Option<String>) -> Self {
        Self {
            timestamp: timestamp.unwrap_or(Utc::now()),
            asset_ref: asset_ref.unwrap_or("AA==".to_string()),
            contents,
            user_signature
        }
    }

    pub fn timestamp(&self) -> DateTime<Utc> { self.timestamp }
    pub fn asset_ref(&self) -> &str { &self.asset_ref }
    pub fn contents(&self) -> &str { &self.contents }
    pub fn user_signature(&self) -> &str { &self.user_signature }
}
