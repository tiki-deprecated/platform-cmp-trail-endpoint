/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use lambda_http::http::StatusCode;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::{error, fmt};

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ErrorResponse {
    status: u16,
    message: String,
    id: Option<String>,
    detail: Option<String>,
    properties: Option<HashMap<String, String>>,
    #[serde(skip)]
    source: Option<Box<dyn error::Error>>,
}

impl fmt::Display for ErrorResponse {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f,
            "{}: {} - {{ id: {:#?}, detail: {:#?}, properties: {:#?} }}",
            self.status, self.message, self.id, self.detail, self.properties
        )
    }
}

impl error::Error for ErrorResponse {}

impl ErrorResponse {
    pub fn new(status: StatusCode) -> Self {
        Self {
            status: status.as_u16(),
            message: status.canonical_reason().unwrap_or("").to_string(),
            id: None,
            detail: None,
            properties: None,
            source: None,
        }
    }

    pub fn with_id(mut self, id: &str) -> Self {
        self.id = Some(id.to_string());
        self
    }

    pub fn with_detail(mut self, detail: &str) -> Self {
        self.detail = Some(detail.to_string());
        self
    }

    pub fn with_properties(mut self, properties: HashMap<String, String>) -> Self {
        self.properties = Some(properties);
        self
    }

    pub fn with_source(mut self, source: Box<dyn error::Error>) -> Self {
        self.source = Some(source);
        self
    }

    pub fn status(&self) -> u16 {
        self.status
    }

    pub fn status_code(&self) -> StatusCode {
        StatusCode::from_u16(self.status).unwrap()
    }

    pub fn message(&self) -> &str {
        &self.message
    }

    pub fn id(&self) -> &Option<String> {
        &self.id
    }

    pub fn detail(&self) -> &Option<String> {
        &self.detail
    }

    pub fn properties(&self) -> &Option<HashMap<String, String>> {
        &self.properties
    }

    pub fn source(&self) -> &Option<Box<dyn error::Error>> {
        &self.source
    }
}
