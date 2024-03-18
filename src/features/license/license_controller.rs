/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;

use lambda_http::{http::StatusCode, Request, RequestExt, RequestPayloadExt};

use mytiki_core_trail_storage::{
    utils::{S3Client, SqsClient},
    Signer,
};

use super::{
    super::super::utils::{AuthorizationContext, CreateResponse, ErrorResponse},
    CreateRequest, Service, VerifyRsp,
};

pub async fn create(event: Request) -> Result<(StatusCode, CreateResponse), Box<dyn Error>> {
    let s3_client = S3Client::from_env().await;
    let sqs_client = SqsClient::from_env().await;
    let context = AuthorizationContext::new(&event.request_context());
    let signer = Signer::get(&s3_client, &context.owner()).await?;
    let request = event.payload::<CreateRequest>()?.ok_or(
        ErrorResponse::new(StatusCode::BAD_REQUEST)
            .with_detail("Invalid body")
            .into(),
    )?;
    let response = Service::new(&s3_client, &sqs_client)
        .await
        .create(&context.owner(), &signer, &request)
        .await?;
    Ok((StatusCode::OK, response))
}

pub async fn verify(event: Request) -> Result<(StatusCode, VerifyRsp), Box<dyn Error>> {
    let response = VerifyRsp {
        verified: false,
        reason: None,
    };
    Ok((StatusCode::OK, response))
}
