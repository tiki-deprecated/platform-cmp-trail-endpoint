/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use super::{Tag, LicenseUse};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct License {
    ptr: String,
    tags: Vec<Tag>,
    uses: Vec<LicenseUse>,
    terms: String,
    description: Option<String>,
    expiry: Option<DateTime<Utc>>,
}

#[allow(unused)]
impl License {
    pub fn ptr(&self) -> &str { &self.ptr }
    pub fn tags(&self) -> &Vec<Tag> { &self.tags }
    pub fn uses(&self) -> &Vec<LicenseUse> { &self.uses }
    pub fn terms(&self) -> &str { &self.terms }
    pub fn description(&self) -> &Option<String> { &self.description }
    pub fn expiry(&self) -> Option<DateTime<Utc>> { self.expiry }
}