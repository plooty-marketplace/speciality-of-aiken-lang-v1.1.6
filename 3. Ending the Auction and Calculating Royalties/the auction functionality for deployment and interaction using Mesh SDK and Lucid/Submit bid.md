## Submit Bid

Submitting bids with Lucid involves crafting a transaction with script inputs and redeemers.

...
async function submitBid(scriptAddress, datum, redeemer, bidAmount) {
  const tx = await lucid
    .newTx()
    .collectFrom([{
      txHash: "<AUCTION_UTXO_HASH>",
      outputIndex: 0,
    }], redeemer)
    .payToContract(scriptAddress, { inline: datum }, { lovelace: bidAmount })
    .complete();

  const signedTx = await tx.sign().complete();
  const txHash = await signedTx.submit();
  console.log(`Bid Submitted at TxHash: ${txHash}`);
}

...

## Comparison: Mesh SDK vs. Lucid
1. Feature	Mesh SDK	Lucid
2. Ease of Use	Beginner-friendly, high-level API.	Requires understanding of Plutus.
3. Flexibility	Good for simple use cases.	Ideal for complex contracts.
4. Integration Speed	Faster to set up.	Slower but highly customizable.
5. Deployment	Built-in support for Plutus.	Custom scripts need more setup.
6. Comparison: Mesh SDK vs. Lucid

## Feature	Mesh SDK	Lucid

1. Ease of Use	Beginner-friendly, high-level API.	Requires understanding of Plutus.
2. Flexibility	Good for simple use cases.	Ideal for complex contracts.
3. Integration Speed	Faster to set up.	Slower but highly customizable.
4. Deployment	Built-in support for Plutus.	Custom scripts need more setup.


## Next Steps
1. Testing: Deploy the contract on a Cardano testnet and submit mock bids to validate logic.
2. Frontend Integration: Use a framework like React.js to integrate Mesh/Lucid functions into a dApp interface.
