/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use super::{CreateRequest, CreateRsp, VerifyRequest, VerifyRsp};
use lambda_http::{http::StatusCode, Request};
use std::error::Error;

pub async fn create(event: Request) -> Result<(StatusCode, CreateRsp), Box<dyn Error>> {
    Ok((StatusCode::OK, ()))
}

pub async fn verify(event: Request) -> Result<(StatusCode, VerifyRsp), Box<dyn Error>> {
    Ok((
        StatusCode::OK,
        VerifyRsp {
            verified: false,
            reason: None,
        },
    ))
}
