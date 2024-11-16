
Advanced Notification Integration


### **Advanced Notification Integration**

Let’s set up **email notifications** and **mobile push notifications** for your auction dApp. These features enhance the user experience by keeping users informed of key events, such as bids or auction closure.

---

###### **1. Email Notifications with SendGrid**

#### **Step 1: Set Up SendGrid Account**
1. Create an account on [SendGrid](https://sendgrid.com/).
2. Go to **Settings > API Keys**, create a new API key, and copy it.

#### **Step 2: Install SendGrid Library**
Install the SendGrid Node.js SDK:
```bash
npm install @sendgrid/mail
```

#### **Step 3: Add Email Notification Logic**
Update your backend to include an email notification function.

##### **server.js (Updated)**
```javascript
const sgMail = require("@sendgrid/mail");
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// Function to send an email
const sendEmail = async (to, subject, content) => {
  const message = {
    to,
    from: "your_email@example.com", // Replace with your verified sender email
    subject,
    text: content,
  };

  try {
    await sgMail.send(message);
    console.log("Email sent to:", to);
  } catch (error) {
    console.error("Error sending email:", error.message);
  }
};

// Trigger email on auction events
io.on("connection", (socket) => {
  socket.on("watchAuction", async (scriptAddress) => {
    console.log(`Watching auction: ${scriptAddress}`);

    setInterval(async () => {
      // Simulated logic to detect a new bid
      const newBid = Math.random() > 0.8; // Replace with actual logic
      if (newBid) {
        sendEmail(
          "user@example.com", // Replace with the bidder's email
          "New Bid on Auction",
          `A new bid has been placed on auction at ${scriptAddress}`
        );
      }
    }, 5000); // Check every 5 seconds
  });
});
```

---

### **2. Mobile Push Notifications with Firebase**

#### **Step 1: Set Up Firebase**
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project and enable **Firebase Cloud Messaging (FCM)**.
3. Download the `google-services.json` file for Android or `GoogleService-Info.plist` for iOS.

#### **Step 2: Install Firebase SDK**
Install Firebase for your React frontend:
```bash
npm install firebase
```

#### **Step 3: Add Firebase Configuration**
Create a `firebase.js` file in your frontend to initialize Firebase.

##### **firebase.js**
```javascript
import firebase from "firebase/app";
import "firebase/messaging";

const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
};

firebase.initializeApp(firebaseConfig);

export const messaging = firebase.messaging();
```

---

#### **Step 4: Request Notification Permissions**
Request permission for notifications in your React app.

##### **NotificationPermission.jsx**
```javascript
import React from "react";
import { messaging } from "./firebase";

export default function NotificationPermission() {
  const requestPermission = async () => {
    try {
      const token = await messaging.getToken();
      console.log("Notification token:", token);
      alert("Notification permission granted!");
    } catch (error) {
      console.error("Error getting notification token:", error.message);
    }
  };

  return (
    <button onClick={requestPermission}>
      Enable Notifications
    </button>
  );
}
```

---

#### **Step 5: Send Push Notifications from Backend**
Install the Firebase Admin SDK in your backend:
```bash
npm install firebase-admin
```

Initialize Firebase Admin SDK in your backend and send notifications.

##### **server.js (Updated)**
```javascript
const admin = require("firebase-admin");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(require("./firebase-service-account.json")),
});

// Function to send push notifications
const sendPushNotification = async (token, title, body) => {
  const message = {
    token,
    notification: { title, body },
  };

  try {
    await admin.messaging().send(message);
    console.log("Push notification sent:", title);
  } catch (error) {
    console.error("Error sending push notification:", error.message);
  }
};

// Trigger notification on auction events
io.on("connection", (socket) => {
  socket.on("watchAuction", async (scriptAddress) => {
    setInterval(async () => {
      // Simulated logic to detect an event
      const auctionEnded = Math.random() > 0.8; // Replace with actual logic
      if (auctionEnded) {
        sendPushNotification(
          "user_fcm_token", // Replace with the user's FCM token
          "Auction Ended",
          `The auction at ${scriptAddress} has ended!`
        );
      }
    }, 5000); // Check every 5 seconds
  });
});
```

---

### **3. Testing and Deployment**

1. **Email Testing**:
   - Verify the sender email in your SendGrid account.
   - Test by triggering a new bid or auction event.

2. **Push Notification Testing**:
   - Install the frontend app on your device.
   - Allow notification permissions and obtain the FCM token.
   - Trigger a backend event to send a notification.

3. **Deploy Backend**:
   - Use Heroku or Vercel as outlined earlier to deploy your backend server.
   - Ensure the Firebase service account JSON is included in the deployment.

4. **Frontend Integration**:
   - Ensure `NotificationPermission` is included in your React app for users to enable notifications.

---

### **Next Steps**
- Add user management to associate email/FCM tokens with wallet addresses.
- Enhance logic to filter relevant events (e.g., specific auctions or user bids).
- Optimize notifications with scheduled reminders or personalized updates.

Would you like further assistance with managing user subscriptions or deploying Firebase services?
