Use Lucid to deploy the auction contract:
...
async function deployAuction(scriptCbor, datum, lovelaceAmount) {
  const scriptAddress = lucid.utils.validatorToAddress({
    type: "PlutusV2",
    script: scriptCbor,
  });

  const tx = await lucid
    .newTx()
    .payToAddress(scriptAddress, { lovelace: lovelaceAmount }, datum)
    .complete();

  const signedTx = await tx.sign().complete();
  const txHash = await signedTx.submit();
  console.log(`Deployed Auction Contract at TxHash: ${txHash}`);
}

...
