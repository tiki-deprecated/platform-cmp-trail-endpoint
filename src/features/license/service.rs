/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;
use super::{super::Repository, RspVerify};

pub struct Service {
    repository: Repository
}

impl Service {
    //create
    //verify
    
    pub async fn new(provider: &str, address: &str) -> Self {
        let repository = Repository::new(provider, address).await;
        Self { repository }
    }
    
    pub async fn verify(&self) -> Result<(), Box<dyn Error>>{
        let metadata = self.repository.read_metadata().await?;
        
        //get last block
        //get last transaction
        //get the schema
        //
        
        //crawl backwards up transaction list to find the last license. 
        
        
        
        
        Ok(())
    }
}