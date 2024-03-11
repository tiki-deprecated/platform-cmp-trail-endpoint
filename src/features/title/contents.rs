/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use chrono::{DateTime, Utc};
use super::Tag;

pub struct Contents {
    ptr: String,
    origin: Option<String>,
    tags: Vec<Tag>,
    description: Option<String>,
    timestamp: DateTime<Utc>
}