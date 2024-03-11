/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;
use mytiki_core_trail_storage::{S3Client, Block, Metadata, Owner};

pub struct Reader {
    client: S3Client
}

impl Reader {
    pub async fn new() -> Self {
        let s3 = S3Client::new_from_env().await;
        Self { client: s3 }
    }
    
    pub async fn metadata(&self, provider: &str, address: &str) -> Result<Metadata, Box<dyn Error>> {
        let owner = Owner::new(Some(provider.to_string()), Some(address.to_string()));
        let metadata = Metadata::get(&self.client, &owner).await?;
        Ok(metadata)
    }
    
    pub async fn block(&self, provider: &str, address: &str, id: &str) -> Result<Block, Box<dyn Error>> {
        let owner = Owner::new(Some(provider.to_string()), Some(address.to_string()));
        let block = Block::read(&self.client, &owner, id).await?;
        Ok(block)
    }
}
