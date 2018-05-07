pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

import "./usingOraclize.sol";

contract Betting is usingOraclize {

  /* Datatypes for oraclize */
  string public BTC;
  uint betting_duration = 0;
  bool public fetched=false;
  address public ac1 = 0x62C8BDBDFD5EC4B7F56537BC96C78068341A8F6F;
  address public ac2 = 0xCB87BDB88EEF4ABC66AE6F1A131D41021C145863;
  address public myaccount = this;

  event newOraclizeQuery(string description);
  event newPriceTicker(string price);
  event Transfer(address _from, uint256 _value);

  function Betting() {
    priceTicker();
  }

  function priceTicker() {
      oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
      update();
  }

  function __callback(bytes32 myid, string result, bytes proof) {
      if(msg.sender != oraclize_cbAddress()) throw;
      fetched = true;
      BTC = result;
      newPriceTicker(BTC);
      // return ETHXBT;
      /*reward();*/
  }

  function update() payable {
      if (oraclize_getPrice("URL") > this.balance) {
          newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
      } else {
          newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
          oraclize_query(betting_duration, "URL", "json(http://api.coinmarketcap.com/v1/ticker/bitcoin/).0.price_usd");
      }
  }
  function sendEther() payable returns (uint) {
    return msg.value;
  }
  function () payable {
   Transfer(msg.sender, msg.value);
  }
  function reward() payable {
    ac2.transfer(0.05 ether);
    /*require(myAddress.balance >5);
    if (stringToUintNormalize(BTC) >=3500) {
      ac2.transfer(1);
    }
    else if (stringToUintNormalize(BTC) <3500) {
      ac1.transfer(1);
    }*/
  }
  function stringToUintNormalize(string s) constant returns (uint result) {
    bytes memory b = bytes(s);
    uint i;
    result = 0;
    for (i = 0; i < b.length; i++) {
      uint c = uint(b[i]);
      if (c >= 48 && c <= 57) {
        result = result * 10 + (c - 48);
      }
    }
    result/=100;
  }
  function getBlocktime() returns (uint) {
    return block.timestamp;
  }
  function fetchResult() returns (string){
    return BTC;
  }
  function fetchStatus() returns (bool) {
    return fetched;
  }
}
