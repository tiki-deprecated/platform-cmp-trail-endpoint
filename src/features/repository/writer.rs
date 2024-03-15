/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::error::Error;
use mytiki_core_trail_storage::ModelTxn;

use super::super::super::utils::SqsClient;

pub struct Writer {
    client: SqsClient
}

impl Writer {
    pub async fn new() -> Self {
        let sqs = SqsClient::new_from_env().await;
        Self { client: sqs }
    }
    
    pub async fn transaction(&self, provider: &str, address: &str, txn: &ModelTxn) -> Result<(), Box<dyn Error>> {
        let group_id = MsgGroup::new_txn(provider, address);
        self.client.send(&group_id.to_string(), txn).await?;
        Ok(())
    }
}
