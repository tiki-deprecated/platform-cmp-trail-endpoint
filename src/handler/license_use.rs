/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use serde::{Deserialize, Serialize};
use super::UseCase;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct LicenseUse {
    #[serde(alias = "usecases")]
    use_cases: Vec<UseCase>,
    destinations: Option<Vec<String>>
}

impl LicenseUse {
    pub fn use_cases(&self) -> &Vec<UseCase> { &self.use_cases }
    pub fn destinations(&self) -> &Option<Vec<String>> { &self.destinations }
}
