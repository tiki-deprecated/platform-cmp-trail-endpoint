/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use super::super::{
    super::utils::{AuthorizationContext, CreateResponse, ErrorResponse},
    license, title,
};
use lambda_http::{http::StatusCode, Request, RequestExt, RequestPayloadExt};
use mytiki_core_trail_storage::content::{License, SchemaType};
use mytiki_core_trail_storage::{
    utils::{S3Client, SqsClient},
    Block, Metadata, Signer,
};
use std::error::Error;

pub async fn create(event: Request) -> Result<(StatusCode, CreateResponse), Box<dyn Error>> {
    let s3_client = S3Client::from_env().await;
    let sqs_client = SqsClient::from_env().await;
    let context = AuthorizationContext::new(&event.request_context())?;
    let signer = Signer::get(&s3_client, &context.owner()).await?;
    let request = event
        .payload::<license::ComboRequest>()?
        .ok_or::<ErrorResponse>(
            ErrorResponse::new(StatusCode::BAD_REQUEST).with_detail("Invalid body"),
        )?;
    let title_request = title::CreateRequest::new(
        request.ptr(),
        request.origin(),
        request.tags().clone(),
        request.description().clone(),
        request.signature(),
    );
    let title_response = title::Service::new(&s3_client, &sqs_client)
        .create(&context.owner(), &signer, &title_request)
        .await?;
    let license_request = license::CreateRequest::new(
        title_response.id(),
        request.uses().clone(),
        request.terms(),
        request.description().clone(),
        request.expiry(),
        request.signature(),
    );
    let response = license::Service::new(&s3_client, &sqs_client)
        .await
        .create(&context.owner(), &signer, &license_request)
        .await?;
    Ok((StatusCode::OK, response))
}

pub async fn verify(event: Request) -> Result<(StatusCode, license::VerifyRsp), Box<dyn Error>> {
    let s3_client = S3Client::from_env().await;
    let context = AuthorizationContext::new(&event.request_context())?;
    let metadata = Metadata::get(&s3_client, &context.owner()).await?;
    for block in metadata.blocks() {
        let block = Block::read(&s3_client, &context.owner(), block).await?;
        for transaction in block.transactions() {
            if transaction.schema().typ().eq(&SchemaType::License) {
                let license = transaction.contents::<License>()?;
                if !license.uses().is_empty() {
                    return Ok((
                        StatusCode::OK,
                        license::VerifyRsp {
                            verified: true,
                            reason: None,
                        },
                    ));
                }
            }
        }
    }
    Ok((
        StatusCode::OK,
        license::VerifyRsp {
            verified: false,
            reason: Some("No license with permissive uses found".to_string()),
        },
    ))
}
