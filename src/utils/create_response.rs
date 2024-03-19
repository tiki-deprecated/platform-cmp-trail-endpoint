/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CreateResponse {
    id: String,
    timestamp: DateTime<Utc>,
    signature: String,
}

impl CreateResponse {
    pub fn new(id: &str, timestamp: DateTime<Utc>, signature: &str) -> Self {
        Self {
            id: id.to_string(),
            timestamp,
            signature: signature.to_string(),
        }
    }

    pub fn id(&self) -> &str {
        &self.id
    }

    pub fn timestamp(&self) -> DateTime<Utc> {
        self.timestamp
    }

    pub fn signature(&self) -> &str {
        &self.signature
    }
}
