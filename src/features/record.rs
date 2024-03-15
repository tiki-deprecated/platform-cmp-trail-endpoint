use std::error::Error;
use mytiki_core_trail_storage::{ModelTxn, Owner, Signer};

pub(crate) trait Record<T>{
  fn from_transaction(transaction: ModelTxn) -> Result<T, Box<dyn Error>>;
  fn to_transaction(&self, owner: &Owner, signer: &Signer) -> Result<ModelTxn, Box<dyn Error>>;
}