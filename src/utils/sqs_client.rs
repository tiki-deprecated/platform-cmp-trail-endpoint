/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

use std::{env, error::Error};
use aws_config::{meta::region::RegionProviderChain, BehaviorVersion};
use aws_sdk_sqs::{config::Region, Client};
use serde::Serialize;

pub struct SqsClient {
    sqs: Client,
    queue: String
}

impl SqsClient {
    pub async fn new(region: &str, queue: &str) -> Self {
        let config = aws_config::defaults(BehaviorVersion::latest())
            .region(Region::new(String::from(region)))
            .load().await;
        Self {
            sqs: Client::new(&config),
            queue: queue.to_string()
        }
    }

    pub async fn new_from_env() -> Self {
        let region = RegionProviderChain::default_provider()
            .or_else("us-east-2")
            .region().await.unwrap();
        let queue = match env::var("TIKI_QUEUE") {
            Ok(queue) => queue,
            Err(_) => panic!("Please set TIKI_QUEUE"),
        };
        Self::new(region.as_ref(), &queue).await
    }

    pub async fn send<T>(&self, group_id: &str, message: &T) -> Result<(), Box<dyn Error>> where T: Serialize {
        self.sqs.send_message()
            .queue_url(&self.queue)
            .message_group_id(group_id)
            .message_body(serde_json::to_string(message)?)
            .send()
            .await?;
        Ok(())
    }
}
