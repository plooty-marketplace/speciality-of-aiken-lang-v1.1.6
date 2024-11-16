### **Setting Up a Real-Time Monitoring Dashboard for Alerts**

A live monitoring dashboard can help you track and visualize the alerts sent via Slack, email, and PagerDuty. Here's how to build a simple dashboard with Firebase Firestore, React (or Vue.js), and Firebase Hosting.

---

### **1. Backend: Log Alerts in Firestore**

#### **Step 1: Update Firebase Function**
Modify the `sendAlerts` function to log all alerts into Firestore. Update `functions/index.js`:

```javascript
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

// Add to the existing sendAlerts function
exports.sendAlerts = functions.https.onRequest(async (req, res) => {
  const { text, severity } = req.body;

  if (!text || !severity) {
    res.status(400).send("Missing required fields: text and severity.");
    return;
  }

  try {
    // Save the alert to Firestore
    const alertData = {
      text,
      severity,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };
    await db.collection("alerts").add(alertData);

    // Existing alert delivery logic (Slack, email, PagerDuty)
    // ...

    res.status(200).send("Alert sent and logged successfully.");
  } catch (error) {
    console.error("Failed to send and log alerts:", error);
    res.status(500).send("Failed to send and log alerts.");
  }
});
```

---

### **2. Frontend: Create a Dashboard**

#### **Step 1: Initialize React or Vue.js**
1. Create a React app:
   ```bash
   npx create-react-app alert-dashboard
   cd alert-dashboard
   ```
   Or use Vue.js:
   ```bash
   npm create vue@latest alert-dashboard
   cd alert-dashboard
   npm install
   ```

2. Install Firebase SDK:
   ```bash
   npm install firebase
   ```

#### **Step 2: Configure Firebase in the Frontend**
In `src/firebaseConfig.js`:
```javascript
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "your-api-key",
  authDomain: "your-auth-domain",
  projectId: "your-project-id",
  storageBucket: "your-storage-bucket",
  messagingSenderId: "your-messaging-sender-id",
  appId: "your-app-id",
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
```

---

#### **Step 3: Display Alerts in the Dashboard**
Use Firestore's real-time listener to fetch alerts. In `src/App.js` (React example):

```javascript
import React, { useEffect, useState } from "react";
import { collection, onSnapshot, query, orderBy } from "firebase/firestore";
import { db } from "./firebaseConfig";

function App() {
  const [alerts, setAlerts] = useState([]);

  useEffect(() => {
    const q = query(collection(db, "alerts"), orderBy("timestamp", "desc"));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      setAlerts(
        snapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }))
      );
    });
    return () => unsubscribe();
  }, []);

  return (
    <div style={{ padding: "20px" }}>
      <h1>Real-Time Alert Dashboard</h1>
      <table border="1" cellPadding="10">
        <thead>
          <tr>
            <th>Severity</th>
            <th>Message</th>
            <th>Timestamp</th>
          </tr>
        </thead>
        <tbody>
          {alerts.map((alert) => (
            <tr key={alert.id}>
              <td>{alert.severity}</td>
              <td>{alert.text}</td>
              <td>{new Date(alert.timestamp?.seconds * 1000).toLocaleString()}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default App;
```

For Vue.js, use:
```vue
<script>
import { ref, onMounted } from "vue";
import { db } from "./firebaseConfig";
import { collection, onSnapshot, query, orderBy } from "firebase/firestore";

export default {
  setup() {
    const alerts = ref([]);

    onMounted(() => {
      const q = query(collection(db, "alerts"), orderBy("timestamp", "desc"));
      onSnapshot(q, (snapshot) => {
        alerts.value = snapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }));
      });
    });

    return { alerts };
  },
};
</script>

<template>
  <div>
    <h1>Real-Time Alert Dashboard</h1>
    <table border="1" cellpadding="10">
      <thead>
        <tr>
          <th>Severity</th>
          <th>Message</th>
          <th>Timestamp</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="alert in alerts" :key="alert.id">
          <td>{{ alert.severity }}</td>
          <td>{{ alert.text }}</td>
          <td>{{ new Date(alert.timestamp.seconds * 1000).toLocaleString() }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
```

---

### **3. Deploy the Dashboard**

#### **Step 1: Build the Project**
React:
```bash
npm run build
```
Vue.js:
```bash
npm run build
```

#### **Step 2: Deploy to Firebase Hosting**
1. Initialize Firebase Hosting:
   ```bash
   firebase init hosting
   ```
2. Deploy:
   ```bash
   firebase deploy --only hosting
   ```

---

### **4. Additional Enhancements**

1. **Filter Alerts by Severity**
   Add dropdown filters for severity (`critical`, `warning`, etc.).
   ```javascript
   const [filter, setFilter] = useState("");
   const q = query(
     collection(db, "alerts"),
     orderBy("timestamp", "desc"),
     filter ? where("severity", "==", filter) : undefined
   );
   ```

2. **Add Charts**
   Use libraries like [Chart.js](https://www.chartjs.org/) or [Recharts](https://recharts.org/) to visualize:
   - Frequency of alerts by severity.
   - Alerts over time.

3. **Integrate with Notifications**
   Trigger browser notifications for critical alerts using the [Web Notifications API](https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API).

--
