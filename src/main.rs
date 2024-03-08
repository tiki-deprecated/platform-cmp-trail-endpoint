/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

mod handler;

use lambda_runtime::{run, service_fn, Error, LambdaEvent};
use aws_lambda_events::{event::apigw::ApiGatewayProxyRequest};

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .with_target(false)
        .without_time()
        .init();
    run(service_fn(catch_all)).await
}

async fn catch_all(event: LambdaEvent<ApiGatewayProxyRequest>) -> Result<(), Error> {
    tracing::debug!("{:?}", event);
    match handler::handle(event).await {
        Ok(_) => Ok(()),
        Err(e) => {
            tracing::error!("{:?}", e);
            Err(Error::from(e.to_string()))
        }
    }
}

#[cfg(test)]
mod tests {
    use std::collections::HashMap;
    use std::env;
    use aws_lambda_events::sqs::{SqsEvent, SqsMessage};
    use lambda_runtime::LambdaEvent;
    use super::catch_all;
    use tokio_test::assert_ok;

    #[tokio::test]
    async fn init() {
        env::set_var("TIKI_BUCKET", "mytiki-core-trail-write");
        env::set_var("TIKI_REGION", "us-east-2");
        env::set_var("AWS_PROFILE", "sandbox-mike");
        let body = "{ \"timestamp\": \"2024-03-04T20:32:59+0000\", \"key\": \"MIIEowIBAAKCAQEAybqBmkgsVwH1RCGNQW/exEOmQ8T0zn2knGzawaB93QMw+miNFYz9zpgXFqMATljJ698CplLmDvFmxBHW5lQmmwNBZzqqHqG76ynjMf3Dt5ZZD/RLvf3hTUjbiZXOpwXH6FppnbT6bMbZlYOBgFlNsBz06mEJSH0mmxPuYaAhR5VR4cFXdPKarZzngMv/XNpQvt1ZRtq1IZ0oyZvLbUExwfMqaHAMPR8Yi2PsC97i5rfFlkW6OzQHYzQdbLqmriDT06zcYnamFmhQXvjMdqw2cp3CZi8xvQshzN927LK2yHUwW64OIJp7w6rCtJidXkssh1nflAbJ6TT8TTPlZZBiHQIDAQABAoIBAAKuVuCdCvHRFdhk9cKj4PsMxx3pdTN1WgW2MKYYIvQYAcOiNhXOPOVNAimL2wovhed7nEZnnaUfMjVy4z9GaQjwXyMnFXG4xo2Wje1xKPO8rMxYe9U3lZH4YOqQMiHoIsMEyJiO+jEN54BkMglppm2rxNmElqH+/89Z0XY8sZSI8nMfIgCVif3n4Ov+o0ZBmzm+as34iQs8hm4rbY5juyRKGtsOkiA64YxFQ7g+Xp3wIOTeaPL5uSr1Yyu+FknXySBn1AyZvwwAxlRRI759UKnxn/jXNRMIhHddz6Zb2l/xORk180A4PO0YwvwjJ6W1Vxs54WYWPRFnsSA1sQpqGmUCgYEA1S9ageLHsWxM9L+90x9vJhhb62POpo9rl7hdL2wxaBfN0bH0yCz0QFvFNQeZ697U0PpjBdPSem9aSupNLLmuKojPnKtSQtKnahEi9fMzC3RKcZCiZOM8MQbHnfwqlVBLkS150rHdMQcMeSx+BEnV6msYvp5DgUuvBzlRAWCh5s8CgYEA8j4iUM33mcRvveL8KjaxkIk4FU3uqTzKgBwpO/KTTjbb0zpS8h6RMTKdP4muOj83pwQi1OpE/6xELnd6Gwp4QTC4FPi+y/jbjFbPD1kh1IGe4Gv7VlUUKFudR7IS79ufw3+arD77Q+Dckr8GYZH2oqRXSFquqgGGY55fuyJH41MCgYBxmCbo+NchUiz7aUQTwDcwnGA2YFtX4yoYkROOVl9JMQ3pw6JEG7gWpw/A/wjkZzsNE646B7GqrbT2IDz5LQOCBJ5jw+I0Wxz75p+zYGB9pPyZ4NC3Y2HKWet54kkqgLuTYyD7xOyw2CmsU6neTR2gKGrp/1jHB3X/KmpgioYafwKBgQC991/twjfDjDqczJ43dIC2+gTTIDRi31tmL69eZZKDKZ4l/X0ChloSHMEYDJ5m6yB3h1TRZ44Iek1VqzhEcGdxqAUT3SWyy0tQuNrUDG/tOGEhWUzWnQ2bwIyMpucW1kJpi23+Wb2ts28GXWthpJenX/1arlJ+24dKI+6qz+1UJQKBgCBnRLan1L8T8xy+ukPrsrsefmkqROCdrLOMzqw62/YSmxjEJT/h5NEBTOmmbrTL1J9TPdVtp8UclV2fX/DER6VBdsr0oBzx0dixoobmKTEbkk19j0T0LPVzzxG+2ARRhYbmjDB281nlFGQcTeN/b13kMigXRV/Myca1eqxKzIP/\" }";
        
        let event = LambdaEvent {
            payload: SqsEvent { records: vec![
                SqsMessage {
                    message_id: Some("MessageId-1".to_string()),
                    receipt_handle: None,
                    body: Some(body.to_string()),
                    md5_of_body: None,
                    md5_of_message_attributes: None,
                    attributes: HashMap::from([(
                        "MessageGroupId".to_string(),
                        "init:1234".to_string()
                    )]),
                    message_attributes: Default::default(),
                    event_source_arn: None,
                    event_source: None,
                    aws_region: None
                }
            ]},
            context: Default::default(),
        };

        let res = catch_all(event).await;
        assert_ok!(res);
    }
}

