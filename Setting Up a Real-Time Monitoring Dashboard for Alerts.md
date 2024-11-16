Here’s how to implement a **working demo** of the **GitHub Actions + Firebase Functions** pipeline, with added support for multiple alert channels like **email** and **PagerDuty**.

---

### **1. Working Demo of GitHub Actions + Firebase Functions**

#### **Step 1: Complete Firebase Functions Deployment Workflow**
Use the `.github/workflows/firebase-deploy.yml` file to automate function deployments:

```yaml
name: Deploy Firebase Functions

on:
  push:
    paths:
      - "functions/**"

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
          firebase auth:login --no-localhost
          firebase use --add default

      - name: Deploy Functions
        run: firebase deploy --only functions
```

#### **Step 2: Example Firebase Function with Alerting**
In `functions/index.js`, add a function that integrates **Slack**, **email**, and **PagerDuty**:

```javascript
const functions = require("firebase-functions");
const fetch = require("node-fetch");
const nodemailer = require("nodemailer");

exports.sendAlerts = functions.https.onRequest(async (req, res) => {
  const { text, severity } = req.body;

  if (!text || !severity) {
    res.status(400).send("Missing required fields: text and severity.");
    return;
  }

  const slackWebhook = functions.config().slack.webhook_url;
  const emailRecipient = functions.config().email.recipient;

  try {
    // Send Slack Alert
    await fetch(slackWebhook, {
      method: "POST",
      body: JSON.stringify({
        text: `*${severity.toUpperCase()}*: ${text}`,
        attachments: [{ text: "Check the logs for details." }],
      }),
      headers: { "Content-Type": "application/json" },
    });

    // Send Email Alert
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: functions.config().email.sender,
        pass: functions.config().email.password,
      },
    });

    await transporter.sendMail({
      from: functions.config().email.sender,
      to: emailRecipient,
      subject: `${severity.toUpperCase()} Alert`,
      text: text,
    });

    // Simulate PagerDuty Alert
    if (severity === "critical") {
      await fetch("https://events.pagerduty.com/v2/enqueue", {
        method: "POST",
        body: JSON.stringify({
          routing_key: functions.config().pagerduty.api_key,
          event_action: "trigger",
          payload: {
            summary: text,
            severity: "critical",
            source: "firebase-functions",
          },
        }),
        headers: { "Content-Type": "application/json" },
      });
    }

    console.log("Alerts sent successfully.");
    res.status(200).send("Alerts sent successfully.");
  } catch (error) {
    console.error("Failed to send alerts:", error);
    res.status(500).send("Failed to send alerts.");
  }
});
```

---

### **2. Adding Email Alerts with Gmail**

#### **Step 1: Set Up Gmail SMTP Credentials**
1. Use a dedicated Gmail account for sending alerts.
2. Enable **"Allow less secure apps"** in Gmail settings (or set up an app password for increased security).
3. Add the credentials to Firebase Functions:
   ```bash
   firebase functions:config:set email.sender="your-email@gmail.com" \
       email.password="your-password" \
       email.recipient="recipient-email@example.com"
   ```

#### **Step 2: Deploy Updated Function**
Run:
```bash
firebase deploy --only functions
```

---

### **3. Adding PagerDuty Alerts**

#### **Step 1: Set Up PagerDuty Integration**
1. Go to **PagerDuty** > **Integrations**.
2. Create a new **Event Rules** integration.
3. Copy the **Integration Key** (routing key) and set it in Firebase:
   ```bash
   firebase functions:config:set pagerduty.api_key="your-pagerduty-integration-key"
   ```

#### **Step 2: Deploy Updated Function**
Run:
```bash
firebase deploy --only functions
```

---

### **4. Testing the Alert System**

#### **Step 1: Test Slack Alerts**
Use a tool like `Postman` or `cURL` to trigger the function:
```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"text": "Critical issue detected!", "severity": "critical"}' \
  https://<your-cloud-function-url>/sendAlerts
```

You should see:
- A Slack notification in the configured channel.
- An email alert in the recipient's inbox.
- A PagerDuty incident created for critical issues.

#### **Step 2: Monitor Logs**
Check logs in the Firebase Console to ensure all alerts are sent successfully.

---

### **5. Enhance the Demo with GitHub Workflow Trigger**

#### **Trigger Alerts on Workflow Failures**
Update your GitHub Actions workflow to trigger the Firebase function when a step fails.

1. Add a Slack Notification Step in the workflow:
   ```yaml
   - name: Send Alert to Firebase
     if: failure()
     run: |
       curl -X POST -H "Content-Type: application/json" \
       -d '{"text": "Build failed for ${{ github.repository }}", "severity": "critical"}' \
       https://<your-cloud-function-url>/sendAlerts
   ```

---

### **6. Live Monitoring Dashboard**
Combine alerts with a live dashboard to monitor the system in real-time:
- Use **Firebase Firestore** to log all events.
- Create a **React** or **Vue.js** frontend to visualize alert statistics.

--
