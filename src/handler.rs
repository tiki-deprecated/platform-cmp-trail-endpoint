/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::{error::Error, future::Future};

use lambda_http::{http, Request, RequestExt};
use serde::Serialize;

use super::{features::license, utils::ErrorResponse};

async fn json_body<Fut, T>(
    event: Request,
    route: impl FnOnce(Request) -> Fut,
) -> Result<(http::StatusCode, String), Box<dyn Error>>
where
    Fut: Future<Output = Result<(http::StatusCode, T), Box<dyn Error>>>,
    T: Serialize,
{
    let rsp = route(event).await?;
    Ok((rsp.0, serde_json::to_string(&rsp.1)?))
}

pub async fn entry(
    event: Request,
) -> Result<(http::StatusCode, String), Box<dyn Error + Send + Sync + 'static>> {
    match (event.method(), event.raw_http_path()) {
        (&http::Method::POST, "/license/create") => json_body(event, license::create).await,
        (&http::Method::POST, "/license/verify") => json_body(event, license::verify).await,
        _ => Err(ErrorResponse::new(http::StatusCode::NOT_FOUND).into()),
    }
    .map_err(|e| e.to_string().into())
}
