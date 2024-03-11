/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

#[derive(Debug, PartialEq, Eq)]
pub enum MsgGroupType { Initialize, Transaction }

#[derive(Debug)]
pub struct MsgGroup {
    typ: MsgGroupType,
    id: String
}

#[allow(unused)]
impl MsgGroup {
    pub fn new_txn(provider: &str, address: &str) -> Self { Self { typ: MsgGroupType::Transaction, id: format!("{}:{}", provider, address) } }
    pub fn new_init(provider: &str) -> Self { Self { typ: MsgGroupType::Initialize, id: format!("{}", provider) } }
    
    pub fn typ(&self) -> &MsgGroupType { &self.typ }
    pub fn id(&self) -> &str {
        &self.id
    }
    
    pub fn to_string(&self) -> String {
        match self.typ {
            MsgGroupType::Initialize => format!("init:{}", self.id),
            MsgGroupType::Transaction => format!("txn:{}", self.id),
        }
    }
}

