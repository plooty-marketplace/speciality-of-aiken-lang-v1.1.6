### **Setting Up Advanced GitHub Actions and Slack Alerts for Notifications**

Here’s a detailed guide to configuring advanced workflows in GitHub Actions and integrating Slack for real-time alerts.

---

### **1. Advanced GitHub Actions Workflow**

#### **Step 1: Add Conditional Stages**
Your pipeline can have stages like linting, testing, and deployment. Create a workflow file `.github/workflows/notifications.yml`:

```yaml
name: Notifications Pipeline

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 18
      - name: Install dependencies
        run: npm install
      - name: Lint code
        run: npm run lint

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v3
      - name: Install Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 18
      - name: Install dependencies
        run: npm install
      - name: Run tests
        run: npm test

  deploy:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v3
      - name: Deploy application
        run: npm run deploy
```

- **Lint Stage**: Ensures code quality before proceeding.
- **Test Stage**: Runs tests only if linting passes.
- **Deploy Stage**: Deploys the application to production if tests pass and the push is on the `main` branch.

---

#### **Step 2: Add Secrets for Secure Deployment**
- Go to **GitHub Repository Settings > Secrets and Variables > Actions**.
- Add secrets like `SENDGRID_API_KEY`, `FIREBASE_SERVICE_ACCOUNT`, etc.
- Access them in your workflow:
  ```yaml
      - name: Deploy application
        run: npm run deploy
        env:
          SENDGRID_API_KEY: ${{ secrets.SENDGRID_API_KEY }}
          FIREBASE_SERVICE_ACCOUNT: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
  ```

---

### **2. Slack Notifications for CI/CD**

#### **Step 1: Set Up Slack Incoming Webhook**
1. Go to your Slack workspace and create a new app:
   - Navigate to **Slack API Apps**: [Slack API](https://api.slack.com/apps).
   - Create a new app > Add **Incoming Webhooks**.
   - Generate a webhook URL (e.g., `https://hooks.slack.com/services/...`).

2. Copy the Webhook URL and save it as a GitHub secret:
   - **Name**: `SLACK_WEBHOOK_URL`.

---

#### **Step 2: Add Slack Notifications to GitHub Actions**
Integrate Slack with GitHub Actions by using a prebuilt action or a custom script.

1. **Using Prebuilt Slack Action**:
   Add this step to any job:
   ```yaml
   - name: Send Slack Notification
     uses: rtCamp/action-slack-notify@v2
     env:
       SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK_URL }}
       SLACK_USERNAME: 'GitHub Actions'
       SLACK_ICON_EMOJI: ':rocket:'
       SLACK_MESSAGE: |
         Build Status: ${{ job.status }}
         Repository: ${{ github.repository }}
         Branch: ${{ github.ref_name }}
         Commit: ${{ github.sha }}
   ```

2. **Using a Custom Script**:
   Use `curl` to send a notification:
   ```yaml
   - name: Send Slack Notification
     run: |
       curl -X POST -H 'Content-type: application/json' \
       --data '{
         "text": "GitHub Actions build status: ${{ job.status }}",
         "attachments": [
           {
             "title": "Repository",
             "text": "${{ github.repository }}"
           },
           {
             "title": "Branch",
             "text": "${{ github.ref_name }}"
           }
         ]
       }' ${{ secrets.SLACK_WEBHOOK_URL }}
   ```

---

#### **Step 3: Customize Notifications**
Customize messages for build failures or successes:
```yaml
- name: Send Slack Notification on Failure
  if: failure()
  run: |
    curl -X POST -H 'Content-type: application/json' \
    --data '{
      "text": "🚨 *Build Failed* 🚨",
      "attachments": [
        {
          "title": "Repository",
          "text": "${{ github.repository }}"
        },
        {
          "title": "Branch",
          "text": "${{ github.ref_name }}"
        },
        {
          "title": "Error Logs",
          "text": "Check the CI/CD logs for details."
        }
      ]
    }' ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

### **3. Real-Time Firebase Alerts in Slack**

#### **Step 1: Set Up Firebase Function**
Create a Cloud Function to send alerts to Slack for critical events like notification delivery failures.

1. Initialize Firebase Functions:
   ```bash
   firebase init functions
   ```

2. Write a function in `functions/index.js`:
   ```javascript
   const functions = require("firebase-functions");
   const fetch = require("node-fetch");

   exports.sendSlackAlert = functions.pubsub
     .schedule("every 1 minutes")
     .onRun(async (context) => {
       const slackWebhookUrl = process.env.SLACK_WEBHOOK_URL;

       // Simulate a critical alert
       const criticalAlert = {
         text: "🔥 High failure rate detected in push notifications!",
         attachments: [
           {
             title: "Issue",
             text: "Failure rate exceeds 10% for push notifications.",
           },
         ],
       };

       await fetch(slackWebhookUrl, {
         method: "POST",
         body: JSON.stringify(criticalAlert),
         headers: { "Content-Type": "application/json" },
       });

       console.log("Slack alert sent.");
     });
   ```

3. Deploy the function:
   ```bash
   firebase deploy --only functions
   ```

---

### **4. Monitoring GitHub Action Status in Slack**

Use tools like **GitHub-Slack integration** for live updates:
1. Go to your repository settings.
2. Enable the **Slack Notifications GitHub App**: [GitHub Slack Integration](https://github.com/apps/slack).
3. Select events to notify, such as:
   - Pull requests.
   - Push events.
   - Workflow runs.

---

### **5. Final Workflow Example**

Here’s a complete example with linting, testing, deployment, and Slack notifications:

```yaml
name: Notifications Pipeline

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 18
      - name: Install dependencies
        run: npm install
      - name: Lint code
        run: npm run lint

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v3
      - name: Install Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 18
      - name: Install dependencies
        run: npm install
      - name: Run tests
        run: npm test

      - name: Send Slack Notification
        uses: rtCamp/action-slack-notify@v2
        env:
          SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK_URL }}
          SLACK_USERNAME: 'GitHub Actions'
          SLACK_ICON_EMOJI: ':white_check_mark:'
          SLACK_MESSAGE: "✅ All tests passed for ${{ github.repository }} on ${{ github.ref_name }}!"

  deploy:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v3
      - name: Deploy application
        run: npm run deploy

      - name: Send Slack Notification
        run: |
          curl -X POST -H 'Content-type: application/json' \
          --data '{
            "text": "🚀 Deployment succeeded for ${{ github.repository }} on ${{ github.ref_name }}."
          }' ${{ secrets.SLACK_WEBHOOK_URL }}
```

---
