/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use mytiki_core_trail_storage::content::Tag;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CreateRequest {
    ptr: String,
    origin: String,
    tags: Vec<Tag>,
    description: Option<String>,
    signature: String,
}

impl CreateRequest {
    pub fn ptr(&self) -> &str {
        &self.ptr
    }

    pub fn origin(&self) -> &str {
        &self.origin
    }

    pub fn tags(&self) -> &Vec<Tag> {
        &self.tags
    }

    pub fn description(&self) -> &Option<String> {
        &self.description
    }

    pub fn signature(&self) -> &str {
        &self.signature
    }
}
