/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

extern crate core;

use lambda_http::{
    http::{Response, StatusCode},
    run, service_fn, Error, IntoResponse, Request, RequestExt,
};

use utils::ErrorResponse;

use crate::handler::entry;

mod features;
mod handler;
mod utils;

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .with_target(false)
        .without_time()
        .init();
    run(service_fn(catch_all)).await?;
    Ok(())
}

async fn catch_all(event: Request) -> Result<impl IntoResponse, Error> {
    tracing::debug!("{:?}", event);
    let response = handler::entry(event).await.unwrap_or_else(|err| {
        tracing::error!("{:?}", err);
        if err.is::<ErrorResponse>() {
            match err.downcast::<ErrorResponse>() {
                Ok(err) => (err.status_code(), serde_json::to_string(&err).unwrap()),
                Err(err) => internal_error(err),
            }
        } else {
            internal_error(err)
        }
    });
    let response = Response::builder()
        .status(response.0)
        .header("Content-Type", "application/json")
        .header("Access-Control-Allow-Origin", "*")
        .header("Access-Control-Allow-Methods", "POST, OPTIONS")
        .header("Access-Control-Allow-Headers", "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Access-Control-Allow-Headers,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Credentials")
        .body(response.1)
        .map_err(Box::new)?;
    Ok(response)
}

fn internal_error(err: Box<dyn std::error::Error>) -> (StatusCode, String) {
    let response =
        ErrorResponse::new(StatusCode::INTERNAL_SERVER_ERROR).with_detail(&err.to_string());
    (
        response.status_code(),
        serde_json::to_string(&response).unwrap(),
    )
}
