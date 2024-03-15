use std::error::Error;

use lambda_http::{Body, Request};

pub fn json_body(req: Request) -> Result<String, Box<dyn Error>> {
  let body_bytes = match req.body() {
    Body::Empty => Vec::new(),
    Body::Text(text) => text.as_bytes().to_vec(),
    Body::Binary(bytes) => bytes.to_vec(),
  };

  return Ok(String::from_utf8(body_bytes)?);
}