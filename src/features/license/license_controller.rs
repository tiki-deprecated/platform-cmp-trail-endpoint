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
    Block, Metadata, Signer, Transaction,
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
    let s3_client = S3Client::new("us-east-2", "mytiki-ocean-core-trail-write").await;
    let context = AuthorizationContext::new(&event.request_context())?;
    let mut rsp = license::VerifyRsp {
        verified: false,
        reason: Some("No license with permissive uses found".to_string()),
    };
    let metadata = verify_metadata(&s3_client, &context).await;
    match metadata {
        Ok(metadata) => {
            for block in metadata.blocks() {
                let block = Block::read(&s3_client, &context.owner(), block).await;
                match block {
                    Ok(block) => {
                        let valid_transaction = verify_transactions(&block.transactions());
                        if valid_transaction.is_ok() {
                            rsp = valid_transaction.unwrap();
                        }
                    }
                    Err(e) => tracing::warn!("Failed to read block. Skipping. {:?}", e),
                }
            }
        }
        Err(e) => rsp = e,
    };
    Ok((StatusCode::OK, rsp))
}

async fn verify_metadata(
    s3_client: &S3Client,
    context: &AuthorizationContext,
) -> Result<Metadata, license::VerifyRsp> {
    let metadata = Metadata::get(s3_client, context.owner()).await;
    match metadata {
        Ok(metadata) => Ok(metadata),
        Err(_) => Err(license::VerifyRsp {
            verified: false,
            reason: Some("No trail found.".to_string()),
        }),
    }
}

fn verify_transactions(transactions: &Vec<Transaction>) -> Result<license::VerifyRsp, ()> {
    for transaction in transactions {
        if transaction.schema().typ().eq(&SchemaType::License) {
            let license = transaction.contents::<License>();
            match license {
                Ok(license) => {
                    return match license.uses().is_empty() {
                        true => Ok(license::VerifyRsp {
                            verified: false,
                            reason: Some(
                                "Most recent license does allow any use cases.".to_string(),
                            ),
                        }),
                        false => Ok(license::VerifyRsp {
                            verified: true,
                            reason: None,
                        }),
                    }
                }
                Err(e) => tracing::warn!("Failed to read license. Skipping. {:?}", e),
            }
        }
    }
    Err(())
}
