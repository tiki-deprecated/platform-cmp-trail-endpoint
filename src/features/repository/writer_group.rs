/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

#[derive(Debug, PartialEq, Eq)]
pub enum WriterGroupType { Initialize, Transaction }

#[derive(Debug)]
pub struct WriterGroup {
    typ: WriterGroupType,
    id: String
}

#[allow(unused)]
impl WriterGroup {
    pub fn new_txn(provider: &str, address: &str) -> Self { Self { typ: WriterGroupType::Transaction, id: format!("{}:{}", provider, address) } }
    pub fn new_init(provider: &str) -> Self { Self { typ: WriterGroupType::Initialize, id: format!("{}", provider) } }
    
    pub fn typ(&self) -> &WriterGroupType { &self.typ }
    pub fn id(&self) -> &str {
        &self.id
    }
    
    pub fn to_string(&self) -> String {
        match self.typ {
            WriterGroupType::Initialize => format!("init:{}", self.id),
            WriterGroupType::Transaction => format!("txn:{}", self.id),
        }
    }
}

