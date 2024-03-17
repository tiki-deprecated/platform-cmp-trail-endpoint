/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use super::{super::super::utils::CreateResponse, CreateRequest};
use mytiki_core_trail_storage::{
    content::{Schema, Title},
    utils::{S3Client, SqsClient},
    Owner, Signer, Transaction,
};
use std::error::Error;

pub struct TitleService {
    s3: S3Client,
    sqs: SqsClient,
}

impl TitleService {
    pub async fn new() -> Self {
        Self {
            s3: S3Client::from_env().await,
            sqs: SqsClient::from_env().await,
        }
    }

    pub async fn create(
        &self,
        owner: &Owner,
        signer: &Signer,
        req: CreateRequest,
    ) -> Result<CreateResponse, Box<dyn Error>> {
        let title = Title::new(
            req.ptr(),
            req.orign(),
            req.tags().clone(),
            req.description().clone(),
        );
        let transaction = Transaction::new(
            &self.sqs,
            owner,
            None,
            Schema::title(),
            title,
            req.signature(),
            &signer,
        )
        .await?;
        Ok(CreateResponse::new(
            transaction.id(),
            transaction.timestamp()?,
            transaction.app_signature(),
        ))
    }
}
