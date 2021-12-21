## fizzy-trade

A solidity contract allowing one party to buy something from another party using ether where the thing being sold cannot be verified as having been transfered on chain (i.e. physical goods).

For example, if a customer wanted to buy a fish bowl from a supplier in a different city. Since the bowl cannot be bought in person, either the customer would have to send the money before the bowl was sent or the supplier would have to send the bowl before receiving payment. In the first case, the seller could just pocket the money and not send the bowl and in the second the customer could receive the bowl and not send the money. 

This contract attempts to solve such problems so that cheating is disinsentivised for both parties.


### How it works:
The buyer would create a promise to pay x ether to the seller's address and send the purchase price (agreed on with seller off chain) along with a deposit and fee (less than deposit) to the contract.
Before the seller accepts the promise, the buyer can cancel the contract and get their money (purchase price, deposit, and fee) back.

The seller can then accept the promise by sending an equal deposit to the contract. After which they would send out the physical good being sold.

At this point the buyer can no longer cancel the contract. However if there has been some mistake the seller can refund the contract and all the deposits, the fee, and the purchase price will be returned to their respective parties.

At this point the buyer can, upon receiving the bowl, verify the promise as being completed. This will send the purchase price to the seller, return the deposits, and make the fee available to the contract holder.
If however the buyer doesn't receive the bowl and cannot get the seller to give them a refund they can instead burn the promise in which case both deposits and the purchase price will be burnt and the contract fee will be returned to the buyer.

This way both the buyer and the seller would lose money if the contract gets burned so they both have an incentive to make sure the promise is completed.
This incentive does mean that a buyer that has been swindled has an incentive to complete the promise anyway but this is mitigated by the fact that human beings are not perfectly rational. The fee being returned means that the buyer will still get some money back if they burn the promise which softens the blow compared with if they got no money back. Perhaps more importantly, human beings don't like being swindled. As such a significant number of people would accept a slightly larger loss to cause a cheating seller to lose money.

An added benefit of the fee being returned in the event of a burned promise is that the owner of the contract (eventually a DAO hopefully) is incentivised to invest in things that make it more likely that promises will be completed. 

Currently, the fee is set at half the value of the deposit.

### TODO (in no particular order):
- Allow for custom deposits with different amounts for each party.
- Add erc-721 functionality to the promises so a seller could sell the rights to collect the purchase price to a shipper who would then be responsible for getting the product to the buyer. This would require promises storing data on what the off chain good being bought is.
- Add the option to buy with erc-20 tokens instead of ether if feasible
- Write version in Cairo if the fees on starknet are low enough to warrant it relative to other layer twos
- Optimise gas costs
- Setup DAO/token
