/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;
use mytiki_core_trail_storage::{Owner, S3Client, Signer};

use crate::{features::{license::ReqCreate, record::Record, title::Title::Model as Title}, utils::json_body::json_body};

use super::{super::Repository, model::Model as License};
use lambda_http::{http::StatusCode, Request};

pub struct Service {}

impl Service {

  pub async fn create(&self, req: Request) -> Result<(StatusCode, License), Box<dyn Error>>{
    let (owner, s3_client, signer) = Self::setup_env(req).await?;
    let repository = Repository::new(&owner).await;
    let json_str = match json_body(req) {
      Ok(json) => json,
      Err(_) => return Err("malformed json body".into()), // handle 400 malformed json
    };
    let request = serde_json::from_str::<ReqCreate>(json_str.as_str());

    // verify signature

    let title = Title::new(
      request.ptr(),
      request.origin(),
      request.tags(),
      request.description(),
      request.user_signature(),
    );
    let title_txn = title.to_transaction(&owner, &signer)?;
    repository.write_transaction(&title_txn);

    let license = License::new(
      title_txn.id().to_string(),
      request.uses(),
      request.terms(),
      request.description(),
      request.expiry(),
      request.user_signature()
    );
    let license_txn = license.to_transaction(&owner, &signer)?;
    repository.write_transaction(&license_txn);

    return Ok((StatusCode::CREATED, license));
  }

  pub async fn verify(&self) -> Result<(), Box<dyn Error>>{
      //get last block
      //get last transaction
      //get the schema
      //
      
      //crawl backwards up transaction list to find the last license. 
      Ok(())
  }

  async fn setup_env(req: Request) -> Result<(Owner, S3Client, Signer), Box<dyn Error>> {
    let user_id = req.requestContext.authorizer.id.as_str();
    let role = req.requestContext.authorizer.role.as_str();
    let (provider, address) = match role.as_str() {
        "addr" => {
            let mut parts = user_id.splitn(2, ':');
            let provider = parts.next();
            let address = parts.next();
            (provider.as_str(), address.as_str())
      }
      _ => (user_id, None),
    };

    let owner = Owner::new(provider, address);
    let s3_client = S3Client::from_env().await;
    let signer = Signer::get(&s3_client, &owner).await?;
    return Ok((owner, s3_client, signer));
  }
}