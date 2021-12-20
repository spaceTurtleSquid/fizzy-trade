// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;





contract FizzSwap {

  enum Status {
    Proposed,
    Canceled,
    InProgress,
    Refunded,
    Completed,
    Burnt
  }


  struct Promise {
    address buyer;
    address seller;
    Status status;
    uint price;
    uint fee;
    uint deposit;
  }


  modifier BuyerOnly(uint promiseId) {
    require(msg.sender == promises[promiseId].buyer, "Must be the buyer in this promise to issue this command");
    _;
  }


  modifier SellerOnly(uint promiseId) {
    require(msg.sender == promises[promiseId].seller, "Must be the seller in this promise to issue this command");
    _;
  }


  modifier OwnerOnly() {
    require(msg.sender == owner, "Must be contract owner to issue this command");
    _;
  }


  modifier ValidPromiseId(uint promiseId) {
    require(promiseId < promises.length, "Promise Id invalid, too large");
    _;
