/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */


use std::error::Error;
use super::{Transaction, MsgGroup, super::super::utils::SqsClient};

pub struct Service {
    client: SqsClient
}

impl Service {
    pub async fn transaction(
        &self,
        provider: &str,
        address: &str,
        txn: &Transaction
    ) -> Result<(), Box<dyn Error>> {
        let group_id = MsgGroup::new_txn(provider, address);
        self.client.send(&group_id.to_string(), txn).await?;
        Ok(())
    }
}