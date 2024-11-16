### **Integrating GitHub Actions with Firebase Functions and Advanced Alert Systems**

This guide covers connecting GitHub Actions to Firebase Functions for automated deployments and setting up an alert system for critical events.

---

### **1. Deploying Firebase Functions Using GitHub Actions**

#### **Step 1: Set Up Firebase in Your Project**
1. **Initialize Firebase Functions**:
   ```bash
   firebase init functions
   ```
2. **Set Up Firebase CLI Authentication**:
   Login to Firebase:
   ```bash
   firebase login
   ```

#### **Step 2: Configure Firebase Authentication in GitHub**
1. Generate a service account key:
   - Go to the **Firebase Console** > **Project Settings** > **Service Accounts** > **Generate New Private Key**.
   - Download the key as a JSON file.

2. Add the service account key to your GitHub repository:
   - Go to **Settings > Secrets and Variables > Actions**.
   - Add a secret named `FIREBASE_SERVICE_ACCOUNT`.
   - Paste the content of the JSON file into the secret.

---

#### **Step 3: Create GitHub Actions Workflow**
Add a `.github/workflows/firebase-deploy.yml` file for deploying functions.

```yaml
name: Deploy Firebase Functions

on:
  push:
    paths:
      - "functions/**" # Trigger only if changes are made to functions directory

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 18

      - name: Install Firebase CLI
        run: npm install -g firebase-tools

      - name: Authenticate with Firebase
        env:
          FIREBASE_SERVICE_ACCOUNT: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
        run: |
          echo "${FIREBASE_SERVICE_ACCOUNT}" > firebase-key.json
          firebase login:ci --no-localhost
          firebase use --add default
          firebase functions:config:set \
            slack.webhook_url="${{ secrets.SLACK_WEBHOOK_URL }}"

      - name: Deploy Firebase Functions
        run: firebase deploy --only functions
```

---

### **2. Setting Up Firebase Functions for Alerts**

#### **Step 1: Write the Firebase Function**
Create a function to send Slack alerts for critical events, such as notification delivery failures.

In `functions/index.js`:

```javascript
const functions = require("firebase-functions");
const fetch = require("node-fetch");

exports.sendSlackAlert = functions.https.onRequest(async (req, res) => {
  const { text, severity } = req.body;

  // Ensure the request contains the necessary data
  if (!text || !severity) {
    res.status(400).send("Missing required fields: text and severity.");
    return;
  }

  // Send alert to Slack
  const webhookUrl = functions.config().slack.webhook_url;

  const message = {
    text: `*Alert: ${severity.toUpperCase()}*\n${text}`,
    attachments: [
      {
        title: "Timestamp",
        text: new Date().toISOString(),
        color: severity === "critical" ? "danger" : "warning",
      },
    ],
  };

  try {
    await fetch(webhookUrl, {
      method: "POST",
      body: JSON.stringify(message),
      headers: { "Content-Type": "application/json" },
    });

    console.log("Alert sent to Slack.");
    res.status(200).send("Alert sent to Slack.");
  } catch (error) {
    console.error("Failed to send alert:", error);
    res.status(500).send("Failed to send alert.");
  }
});
```

#### **Step 2: Deploy the Function**
Deploy the function using the GitHub Actions workflow created earlier or manually:
```bash
firebase deploy --only functions
```

---

### **3. Trigger Alerts Automatically**

#### **Step 1: Monitor Key Metrics**
Add triggers in your application or Firebase to send alerts. For example:
- High error rates.
- Notification delivery failures.

#### **Step 2: Invoke the Slack Function**
From your backend or other Firebase functions, call the Slack alert function:
```javascript
const axios = require("axios");

async function triggerSlackAlert(text, severity) {
  await axios.post("https://<your-firebase-function-url>", {
    text,
    severity,
  });
}

// Example usage
triggerSlackAlert("Push notification delivery failure detected!", "critical");
```

#### **Step 3: Schedule Health Checks**
You can schedule periodic checks to ensure all services are running.

In `functions/index.js`:
```javascript
exports.healthCheck = functions.pubsub.schedule("every 1 minutes").onRun(async () => {
  const allSystemsOperational = true; // Replace with real health check logic

  if (!allSystemsOperational) {
    await triggerSlackAlert("Health check failed!", "critical");
  }

  console.log("Health check completed.");
});
```

Deploy this scheduled function:
```bash
firebase deploy --only functions
```

---

### **4. Advanced Alert Features**

#### **Custom Severity Levels**
Enhance alert messages with severity-specific formatting:
- **Critical**: Red color, bold text.
- **Warning**: Yellow color, italic text.
- **Info**: Blue color, plain text.

#### **Slack Channel Routing**
Send alerts to different channels based on the severity level:
```javascript
const channel = severity === "critical" ? "#critical-alerts" : "#general-alerts";
const message = {
  channel,
  text: `*${severity.toUpperCase()}*: ${text}`,
};
```

#### **Dynamic Slack Actions**
Add interactive buttons to Slack alerts:
```javascript
attachments: [
  {
    title: "Resolve Issue",
    actions: [
      {
        type: "button",
        text: "Acknowledge",
        url: "https://your-app-dashboard/resolve",
      },
    ],
  },
];
```

---

### **5. Debugging and Logs**

1. **View Logs in Firebase Console**:
   - Go to **Firebase Console** > **Functions** > **Logs**.

2. **Log Structured Data**:
   Use `console.log` to output structured logs for easier debugging:
   ```javascript
   console.log(JSON.stringify({ severity: "critical", message: "Function failed." }));
   ```

3. **Set Up Alerts for Errors**:
   Use Firebase Crashlytics for monitoring unexpected errors in production.

--
