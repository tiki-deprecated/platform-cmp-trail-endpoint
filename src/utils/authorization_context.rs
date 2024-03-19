/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use super::ErrorResponse;
use lambda_http::http::StatusCode;
use lambda_http::request::RequestContext;
use mytiki_core_trail_storage::Owner;
use std::error::Error;

pub struct AuthorizationContext {
    namespace: Option<String>,
    owner: Owner,
    scopes: Vec<String>,
}

impl AuthorizationContext {
    pub fn new(request_context: &RequestContext) -> Result<Self, Box<dyn Error>> {
        let fields = request_context
            .authorizer()
            .ok_or::<ErrorResponse>(ErrorResponse::new(StatusCode::UNAUTHORIZED))?
            .clone()
            .fields;
        let namespace = fields
            .get("namespace")
            .map_or(None, serde_json::Value::as_str);
        let id = fields.get("id").map_or(None, serde_json::Value::as_str);
        let scopes = fields
            .get("scopes")
            .unwrap_or(&serde_json::Value::from(Vec::<String>::new()))
            .as_array()
            .unwrap_or(&vec![])
            .iter()
            .map(|s| s.as_str().unwrap_or("").to_string())
            .collect::<Vec<String>>();
        let owner = match id {
            Some(id) => {
                let split = id.split(":").collect::<Vec<&str>>();
                let provider = split.get(0).map_or(None, |v| Some(v.to_string()));
                let id = split.get(1).map_or(None, |v| Some(v.to_string()));
                Owner::new(provider, id)
            }
            None => Owner::new(None, None),
        };
        Ok(Self {
            namespace: namespace.map(str::to_string),
            owner,
            scopes,
        })
    }

    pub fn namespace(&self) -> &Option<String> {
        &self.namespace
    }

    pub fn owner(&self) -> &Owner {
        &self.owner
    }

    pub fn scopes(&self) -> &Vec<String> {
        &self.scopes
    }
}
