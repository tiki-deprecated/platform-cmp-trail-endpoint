/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;

use mytiki_core_trail_storage::{
    content::{License, Schema},
    utils::{S3Client, SqsClient},
    Owner, Signer, Transaction,
};

use super::{super::super::utils::CreateResponse, CreateRequest};

pub struct LicenseService {
    s3: S3Client,
    sqs: SqsClient,
}

impl LicenseService {
    pub async fn new(s3_client: &S3Client, sqs_client: &SqsClient) -> Self {
        Self {
            s3: s3_client.clone(),
            sqs: sqs_client.clone(),
        }
    }

    pub async fn create(
        &self,
        owner: &Owner,
        signer: &Signer,
        req: &CreateRequest,
    ) -> Result<CreateResponse, Box<dyn Error>> {
        let license = License::new(
            req.uses().clone(),
            req.terms(),
            req.description().clone(),
            req.expiry(),
        );
        let transaction = Transaction::new(
            owner,
            Some(req.title().to_string()),
            &Schema::license(),
            license,
            req.signature(),
            &signer,
        )?;
        transaction.submit(&self.sqs, owner).await?;
        Ok(CreateResponse::new(
            transaction.id(),
            transaction.timestamp()?,
            transaction.app_signature(),
        ))
    }
}
