## Frontend Integration for Auction dApp
Let’s create a React.js frontend that interacts with your auction smart contract using Mesh SDK and Lucid.
This guide covers the key steps for building the interface.

1. Wallet Connection Component
Allow users to connect their wallet.

WalletConnect.jsx

...
import React, { useState } from "react";
import { useWallet } from "@meshsdk/core";

export default function WalletConnect({ onWalletConnected }) {
  const { connectWallet, walletAddress } = useWallet();
  const [connected, setConnected] = useState(false);

  const handleConnect = async () => {
    await connectWallet();
    setConnected(true);
    onWalletConnected(walletAddress);
  };

  return (
    <div>
      {connected ? (
        <p>Connected: {walletAddress}</p>
      ) : (
        <button onClick={handleConnect}>Connect Wallet</button>
      )}
    </div>
  );
}

...



2. Deploy Auction
Use a button to deploy the auction smart contract.

DeployAuction.jsx

...
import React from "react";
import { BlockfrostProvider, Transaction } from "@meshsdk/core";

export default function DeployAuction({ scriptCbor, walletAddress }) {
  const provider = new BlockfrostProvider(process.env.REACT_APP_BLOCKFROST_API_KEY);

  const handleDeploy = async () => {
    const tx = new Transaction({ initiator: walletAddress, provider });

    const datum = {
      fields: [
        { constructor: 0, value: "nft_id" }, // Replace with actual NFT ID
        100, // min_bid
        0,   // current_bid
        null, // No bidder yet
        1690000000, // deadline
      ],
    };

    tx.sendAssets(
      {
        address: scriptCbor,
        datum,
      },
      { lovelace: "2000000" } // Minimum UTxO
    );

    const signedTx = await tx.sign();
    const txHash = await signedTx.submit();
    alert(`Auction deployed! TxHash: ${txHash}`);
  };

  return <button onClick={handleDeploy}>Deploy Auction</button>;
}

...

3. Submit a Bid
Allow users to place a bid on the auction.

SubmitBid.jsx

...
import React, { useState } from "react";
import { Transaction } from "@meshsdk/core";

export default function SubmitBid({ scriptAddress, walletAddress }) {
  const [bidAmount, setBidAmount] = useState("");

  const handleSubmitBid = async () => {
    const tx = new Transaction({ initiator: walletAddress });

    tx.addScriptInput(
      {
        address: scriptAddress,
        utxo: {
          txHash: "<AUCTION_UTXO_HASH>",
          index: 0,
        },
        datum: null, // Replace with the updated datum
      },
      bidAmount
    );

    const signedTx = await tx.sign();
    const txHash = await signedTx.submit();
    alert(`Bid submitted! TxHash: ${txHash}`);
  };

  return (
    <div>
      <input
        type="number"
        placeholder="Enter bid amount"
        value={bidAmount}
        onChange={(e) => setBidAmount(e.target.value)}
      />
      <button onClick={handleSubmitBid}>Submit Bid</button>
    </div>
  );
}

...

4. View Auction Status
Fetch and display the auction state.

AuctionStatus.jsx

...
import React, { useEffect, useState } from "react";
import { BlockfrostProvider } from "@meshsdk/core";

export default function AuctionStatus({ scriptAddress }) {
  const [auctionState, setAuctionState] = useState(null);
  const provider = new BlockfrostProvider(process.env.REACT_APP_BLOCKFROST_API_KEY);

  useEffect(() => {
    const fetchAuction = async () => {
      const utxos = await provider.getUtxos(scriptAddress);
      if (utxos.length > 0) {
        const datum = utxos[0].datum; // Simplified assumption
        setAuctionState(datum);
      }
    };

    fetchAuction();
  }, [scriptAddress]);

  return (
    <div>
      <h3>Auction Status</h3>
      {auctionState ? (
        <p>Current Bid: {auctionState.current_bid}</p>
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
}

...

5. App Component
Combine the components into a single app.

App.jsx

...
import React, { useState } from "react";
import WalletConnect from "./WalletConnect";
import DeployAuction from "./DeployAuction";
import SubmitBid from "./SubmitBid";
import AuctionStatus from "./AuctionStatus";

export default function App() {
  const [walletAddress, setWalletAddress] = useState("");
  const [scriptAddress, setScriptAddress] = useState("script_address_here");

  return (
    <div>
      <h1>NFT Auction dApp</h1>
      <WalletConnect onWalletConnected={setWalletAddress} />
      {walletAddress && (
        <>
          <DeployAuction scriptCbor={"compiled_script_hex"} walletAddress={walletAddress} />
          <SubmitBid scriptAddress={scriptAddress} walletAddress={walletAddress} />
          <AuctionStatus scriptAddress={scriptAddress} />
        </>
      )}
    </div>
  );
}

...

## Next Steps
1. Replace placeholders like compiled_script_hex, script_address_here, and datum with actual values     from your Aiken smart contract.
2. Test on Cardano testnet using your Blockfrost API key and wallets like Nami or Eternl.
Enhance UI/UX with frameworks like TailwindCSS or Material UI.
