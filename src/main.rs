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

#[cfg(test)]
mod tests {
    use std::collections::HashMap;

    use lambda_http::aws_lambda_events::apigw::{
        ApiGatewayProxyRequestContext, ApiGatewayRequestAuthorizer,
    };
    use lambda_http::http::{Method, StatusCode};
    use lambda_http::request::RequestContext;
    use serde_json::Value;
    use tokio_test::assert_ok;

    use super::*;

    #[tokio::test]
    async fn test_create() {
        let json = r#"{
    "ptr": "user_new",
    "tags": [
        "purchase_history"
    ],
    "uses": [
        {
            "usecases": [
                "attribution"
            ],
            "destinations": [
                "*"
            ]
        }
    ],
    "description": "",
    "origin": "com.mytiki",
    "terms": "test_terms",
    "signature": "MaXmqCoI2ymN85D8rfMGab+fX03x4SXOxV1qMxg7kOxsmVXZzB7cqWfkeMTCSvDdSGkJyURUh5ObD9Gg/rOOZJgi3rYfcVcBqiXinrtHUTTJjjPwidlF8W+UMvFOstunu6bqrFzSLgpxJLIeRgoYQFJ3fcGljsdni6PPWF/aKUBltM/bikqzn0kq9TyBkOjXebd4xNxG0+dWeIwbIuHCpJw87kKlTCbMaxCRrcFytUdW8fa/FGnTCimkH5L+vbYiBcxWCj3/x8z5l/tDtYZlHZJvziLy+TFDMmNV+Iwk71Rvicu3MMqrpDHPke0JmaVhTXLHF0ZaPzbq94ntWSOuKw=="
}"#;
        let mut fields: HashMap<String, Value> = HashMap::new();
        fields.insert("namespace".to_string(), "addr".into());
        fields.insert(
            "id".to_string(),
            "f0ec9cd4-e567-4282-b353-60f7c23d3627:QqQSnavEVNxJtxsSblYhL8imeZCVJefsKLWyWxXKHlI"
                .into(),
        );
        fields.insert("idB64".to_string(), "ab12".into());
        fields.insert("scopes".to_string(), "trail".into());

        let mut authorizer = ApiGatewayRequestAuthorizer::default();
        authorizer.fields = fields;

        let mut proxy_request = ApiGatewayProxyRequestContext::default();
        proxy_request.authorizer = authorizer;

        let request_context = RequestContext::ApiGatewayV1(proxy_request);
        let request: Request = Request::new(json.into())
            .with_request_context(request_context)
            .with_raw_http_path("/license/create");

        let (mut parts, body) = request.into_parts();
        parts.method = Method::POST;
        let mut headers = parts.headers;
        headers.insert("content-type", "application/json".parse().unwrap());
        parts.headers = headers;

        let request = Request::from_parts(parts, body);
        let response = catch_all(request).await;
        assert_ok!(response);
    }
}
