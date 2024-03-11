/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;
use lambda_http::{Request, http::StatusCode};
use super::{ReqCreate, RspVerify};

pub async fn create(event: Request) -> Result<(StatusCode, ()), Box<dyn Error>> {
    Ok((StatusCode::OK, ()))
}

pub async fn verify(event: Request) -> Result<(StatusCode, RspVerify), Box<dyn Error>> {
    Ok((StatusCode::OK, RspVerify{ verified: false, reason: None }))
}