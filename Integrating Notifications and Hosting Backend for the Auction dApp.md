### **Integrating Notifications and Hosting Backend**

Below are detailed steps for integrating notifications and hosting the backend server for your auction dApp.

---

### **1. Backend with Notifications**

#### **Step 1: Install Dependencies**
Set up a Node.js backend to manage notifications and interact with the Cardano blockchain. Install required packages:

```bash
mkdir auction-backend
cd auction-backend
npm init -y
npm install express socket.io axios dotenv
```

#### **Step 2: Create Server with Event Notifications**
Build the server to listen for blockchain events and notify clients in real-time using **Socket.IO**.

##### **server.js**
```javascript
require("dotenv").config();
const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const axios = require("axios");

const app = express();
const server = http.createServer(app);
const io = new Server(server);

const BLOCKFROST_API_URL = "https://cardano-testnet.blockfrost.io/api/v0";
const BLOCKFROST_API_KEY = process.env.BLOCKFROST_API_KEY;

// Endpoint to fetch auction UTxOs
app.get("/auction/:address", async (req, res) => {
  const scriptAddress = req.params.address;

  try {
    const { data } = await axios.get(`${BLOCKFROST_API_URL}/addresses/${scriptAddress}/utxos`, {
      headers: { project_id: BLOCKFROST_API_KEY },
    });
    res.json(data);
  } catch (error) {
    res.status(500).send("Error fetching auction data");
  }
});

// Real-time updates
io.on("connection", (socket) => {
  console.log("A user connected");

  // Listen for auction watch requests
  socket.on("watchAuction", async (scriptAddress) => {
    console.log(`Watching auction: ${scriptAddress}`);
    setInterval(async () => {
      try {
        const { data } = await axios.get(
          `${BLOCKFROST_API_URL}/addresses/${scriptAddress}/utxos`,
          { headers: { project_id: BLOCKFROST_API_KEY } }
        );
        socket.emit("auctionUpdate", data);
      } catch (error) {
        console.error("Error fetching auction data:", error.message);
      }
    }, 5000); // Check every 5 seconds
  });

  socket.on("disconnect", () => {
    console.log("A user disconnected");
  });
});

server.listen(3000, () => console.log("Backend running on http://localhost:3000"));
```

---

#### **Step 3: Add .env File**
Create a `.env` file in your backend directory:
```env
BLOCKFROST_API_KEY=<YOUR_BLOCKFROST_API_KEY>
```

---

### **2. Hosting the Backend**

#### **Option A: Deploy on Heroku**
1. Install the Heroku CLI:
   ```bash
   npm install -g heroku
   ```
2. Log in to Heroku:
   ```bash
   heroku login
   ```
3. Create a Heroku project:
   ```bash
   heroku create auction-backend
   ```
4. Add environment variables:
   ```bash
   heroku config:set BLOCKFROST_API_KEY=<YOUR_BLOCKFROST_API_KEY>
   ```
5. Deploy your backend:
   ```bash
   git init
   git add .
   git commit -m "Deploy backend"
   heroku git:remote -a auction-backend
   git push heroku main
   ```

#### **Option B: Deploy on Vercel**
1. Install the Vercel CLI:
   ```bash
   npm install -g vercel
   ```
2. Deploy your backend:
   ```bash
   vercel
   ```
3. Add environment variables in the Vercel dashboard.

---

### **3. Frontend Integration for Notifications**

Integrate **Socket.IO** into your React frontend for real-time notifications.

#### **Install Socket.IO Client**
Install the client library:
```bash
npm install socket.io-client
```

#### **AuctionStatus.jsx (Updated)**
Modify the `AuctionStatus` component to use WebSocket updates.

```javascript
import React, { useEffect, useState } from "react";
import { io } from "socket.io-client";

export default function AuctionStatus({ scriptAddress }) {
  const [auctionState, setAuctionState] = useState(null);

  useEffect(() => {
    const socket = io("http://localhost:3000"); // Replace with your backend URL

    // Watch auction updates
    socket.emit("watchAuction", scriptAddress);

    // Listen for updates
    socket.on("auctionUpdate", (data) => {
      console.log("Auction updated:", data);
      setAuctionState(data);
    });

    return () => socket.disconnect();
  }, [scriptAddress]);

  return (
    <div>
      <h3>Auction Status</h3>
      {auctionState ? (
        <pre>{JSON.stringify(auctionState, null, 2)}</pre>
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
}
```

---

### **4. Testing**
- Deploy the backend to Heroku or Vercel.
- Update the `io()` URL in your frontend with the backend's live URL.
- Use wallets like Nami or Eternl on the Cardano testnet to simulate bids and observe real-time updates.

---

### **5. Advanced Features**
- **Email Notifications**: Use services like **SendGrid** or **Mailgun** to send email alerts for significant events (e.g., auction won).
- **Mobile Notifications**: Use **Firebase Cloud Messaging (FCM)** for push notifications.
- **Event Filtering**: Add logic to filter specific events (e.g., new bids) before notifying
- 
