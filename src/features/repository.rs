/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

mod reader;
use reader::Reader;

mod writer;
mod writer_group;
mod transaction;

use writer::Writer;
pub use writer::Transaction;

use std::error::Error;
use mytiki_core_trail_storage::{Metadata, Block, Owner};

pub struct Repository {
    owner: Owner,
    writer: Writer,
    reader: Reader
}

impl Repository {
    pub async fn new(owner: &Owner) -> Self { 
        Self { owner: owner.clone(), writer: Writer::new().await, reader: Reader::new().await }
    }
  
    pub async fn write_transaction(&self, transaction: &Transaction) -> Result<(), Box<dyn Error>> {
        self.writer.transaction(&self.provider, &self.address, transaction).await
    }
    
    pub async fn read_metadata(&self) -> Result<Metadata, Box<dyn Error>> {
        self.reader.metadata(&self.provider, &self.address).await
    }
    
    pub async fn read_block(&self, id: &str) -> Result<Block, Box<dyn Error>> {
        self.reader.block(&self.provider, &self.address, id).await
    }
}
 