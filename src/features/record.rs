use std::error::Error;
use mytiki_core_trail_storage::{ModelTxn, Signer};

pub(crate) trait Record<T>{
  fn from_transaction(transaction: ModelTxn) -> Result<T, Box<dyn Error>>;
  fn to_transaction(&self, address: &str, signer: &Signer) -> Result<ModelTxn, Box<dyn Error>>;
}