/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */


use lambda_http::{Request, Response, Body, Error};

pub async fn handle(event: Request) -> Result<Response<Body>, Error> {
    tracing::debug!("{:?}", event);
    let rsp = Response::builder()
        .status(200)
        .header("content-type", "text/html")
        .body("Hello AWS Lambda HTTP request".into())
        .map_err(Box::new)?;
    Ok(rsp)
}

#[cfg(test)]
mod tests {
    #[tokio::test]
    async fn local() {
        println!("placeholder");
        assert_eq!(1, 1);
    }
}
