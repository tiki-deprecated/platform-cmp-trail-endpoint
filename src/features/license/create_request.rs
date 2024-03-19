/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use chrono::{DateTime, Utc};
use mytiki_core_trail_storage::content::Use;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CreateRequest {
    title: String,
    uses: Vec<Use>,
    terms: String,
    description: Option<String>,
    expiry: Option<DateTime<Utc>>,
    signature: String,
}

impl CreateRequest {
    pub fn new(
        title: &str,
        uses: Vec<Use>,
        terms: &str,
        description: Option<String>,
        expiry: Option<DateTime<Utc>>,
        signature: &str,
    ) -> Self {
        Self {
            title: title.to_string(),
            uses,
            terms: terms.to_string(),
            description,
            expiry,
            signature: signature.to_string(),
        }
    }

    pub fn title(&self) -> &str {
        &self.title
    }

    pub fn uses(&self) -> &Vec<Use> {
        &self.uses
    }

    pub fn terms(&self) -> &str {
        &self.terms
    }

    pub fn description(&self) -> &Option<String> {
        &self.description
    }

    pub fn expiry(&self) -> Option<DateTime<Utc>> {
        self.expiry
    }

    pub fn signature(&self) -> &str {
        &self.signature
    }
}
