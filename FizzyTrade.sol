// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract FizzyTrade {

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
  }


  address private owner; // Owner of the contract

  Promise[] private promises;
  mapping(address => uint[]) private buyerPromises;
  mapping(address => uint[]) private sellerPromises;

  uint private feesToPay = 0; // Fees available for the owner to withdraw


  constructor() {
    owner = msg.sender;
  }

  function withdrawFees() public OwnerOnly {
    payable(owner).transfer(feesToPay);
  }


  function transferOwner(address newOwner) public OwnerOnly {
    owner = newOwner;
  }


  function createPromise(address seller, uint price) public payable {
    uint fee = price / 64;
    uint deposit = price / 32; 
    require(msg.value == price + fee + deposit, "Value sent does not match price + fee + deposit");
    promises.push(Promise(msg.sender, seller, Status.Proposed, price, fee, deposit));
    buyerPromises[msg.sender].push(promises.length-1);
    sellerPromises[seller].push(promises.length-1);
  }

  /**
   * Create a promise with a custom deposit amount.
   */
  function createCustomPromise(address seller, uint price, uint deposit) public payable {
    uint fee = deposit / 2;
    require(msg.value == price + fee + deposit, "Value sent does not match price + fee + deposit");
    promises.push(Promise(msg.sender, seller, Status.Proposed, price, fee, deposit));
    buyerPromises[msg.sender].push(promises.length-1);
    sellerPromises[seller].push(promises.length-1);
  }

  /*
   * Get list of Ids where the sender address is the buyer.
   */
  function getMyBuyerPromiseIds() public view returns (uint[] memory){
    return buyerPromises[msg.sender];
  }

  /*
   * Get list of Ids where the sender address is the seller.
   */
  function getMySellerPromiseIds() public view returns (uint[] memory) {
    return sellerPromises[msg.sender];
  }

  function getPromise(uint promiseId) public view returns (Promise memory){
    return promises[promiseId];
  }
  
  // Cancel promise before it is accepted
  function cancelPromise(uint promiseId) public ValidPromiseId(promiseId) BuyerOnly(promiseId) {
    require(promises[promiseId].status == Status.Proposed);
    promises[promiseId].status = Status.Canceled;

    //Return price, fee, and deposit to buyer
    Promise memory p = promises[promiseId];
    payable(p.buyer).transfer(p.price + p.fee + p.deposit);
  }


  function agreeToPromise(uint promiseId) public payable ValidPromiseId(promiseId) SellerOnly(promiseId) {
    require(promises[promiseId].status == Status.Proposed);
    require(msg.value == promises[promiseId].deposit, "Value sent is not equal to required deposit");
    
    promises[promiseId].status = Status.InProgress;
  }


  function refundPromise(uint promiseId) public ValidPromiseId(promiseId) SellerOnly(promiseId) {
    require(promises[promiseId].status == Status.InProgress);
    promises[promiseId].status = Status.Refunded;

    //Return deposits to buyer and seller as well as seller's price and fee
    Promise memory p = promises[promiseId];
    payable(p.buyer).transfer(p.price + p.fee + p.deposit);
    payable(p.seller).transfer(p.deposit);
  }


  function burnPromise(uint promiseId) public ValidPromiseId(promiseId) BuyerOnly(promiseId) {
    require(promises[promiseId].status == Status.InProgress);
    promises[promiseId].status = Status.Burnt;

    //Return fee to buyer and burn the rest of the money in the contract from this promise
    Promise memory p = promises[promiseId];
    payable(p.buyer).transfer(p.fee);
  }


  function completePromise(uint promiseId) public ValidPromiseId(promiseId) BuyerOnly(promiseId) {
    require(promises[promiseId].status == Status.InProgress);
    promises[promiseId].status = Status.Completed;
    
    // Return deposits to buyer and seller and pay fee to contract
    Promise memory p = promises[promiseId];
    payable(p.buyer).transfer(p.deposit);
    payable(p.seller).transfer(p.deposit + p.price);
    feesToPay += p.fee;
  }

}
