/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use super::CreateRequestUse;
use chrono::{DateTime, Utc};
use mytiki_core_trail_storage::content::Tag;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ComboRequest {
    ptr: String,
    origin: String,
    tags: Vec<Tag>,
    uses: Vec<CreateRequestUse>,
    terms: String,
    description: Option<String>,
    expiry: Option<DateTime<Utc>>,
    signature: String,
}

impl ComboRequest {
    pub fn ptr(&self) -> &str {
        &self.ptr
    }

    pub fn origin(&self) -> &str {
        &self.origin
    }

    pub fn tags(&self) -> &Vec<Tag> {
        &self.tags
    }

    pub fn uses(&self) -> &Vec<CreateRequestUse> {
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
