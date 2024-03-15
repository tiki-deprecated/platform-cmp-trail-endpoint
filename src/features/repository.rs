/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

mod reader;
use reader::Reader;

mod writer;
mod writer_group;

use writer::Writer;

use std::error::Error;
use mytiki_core_trail_storage::{Block, Metadata, ModelTxn, Owner};

pub struct Repository {
    owner: Owner,
    writer: Writer,
    reader: Reader
}

impl Repository {
    pub async fn new(owner: &Owner) -> Self { 
        Self { owner: owner.clone(), writer: Writer::new().await, reader: Reader::new().await }
    }
  
    pub async fn write_transaction(&self, transaction: &ModelTxn) -> Result<(), Box<dyn Error>> {
      let provider = self.owner.provider().clone()
        .ok_or::<Box<dyn Error>>(Box::<dyn Error>::from("Provider is None"))?;
      let address = self.owner.address().clone()
        .ok_or::<Box<dyn Error>>(Box::<dyn Error>::from("Address is None"))?;
      self.writer.transaction(provider.as_str(), address.as_str(), transaction).await
    }

    pub async fn read_metadata(&self) -> Result<Metadata, Box<dyn Error>> {
      let provider = self.owner.provider().clone()
          .ok_or::<Box<dyn Error>>(Box::<dyn Error>::from("Provider is None"))?;
      let address = self.owner.address().clone()
          .ok_or::<Box<dyn Error>>(Box::<dyn Error>::from("Address is None"))?;
      self.reader.metadata(provider.as_str(), address.as_str()).await
    }
  
    
    pub async fn read_block(&self, id: &str) -> Result<Block, Box<dyn Error>> {
      let provider = self.owner.provider().clone()
          .ok_or::<Box<dyn Error>>(Box::<dyn Error>::from("Provider is None"))?;
      let address = self.owner.address().clone()
          .ok_or::<Box<dyn Error>>(Box::<dyn Error>::from("Address is None"))?;
      self.reader.block(provider.as_str(), address.as_str(), id).await
    }
}
 