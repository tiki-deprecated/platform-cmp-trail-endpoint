/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */


mod license;
mod verify;

mod tag;
use tag::{Tag, TagType};

mod use_case;
use use_case::{UseCase, UseCaseType};

mod license_use;
use license_use::LicenseUse;



use std::error::Error;
use aws_lambda_events::apigw::ApiGatewayProxyRequest;
use lambda_runtime::LambdaEvent;

pub async fn handle(event: LambdaEvent<ApiGatewayProxyRequest>) -> Result<(), Box<dyn Error>> {
    //match on unwrapped path to call sub-handlers with json-ified body
    Ok(())
}

async fn handle_create_license() -> Result<(), Box<dyn Error>> { Ok(()) }

async fn hadle_validate_license() -> Result<(), Box<dyn Error>> { Ok(()) }
