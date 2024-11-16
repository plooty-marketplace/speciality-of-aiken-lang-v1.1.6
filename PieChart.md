Let’s add **pie charts** for a percentage distribution of alerts and customize filters further for advanced use cases.

---

### **1. Add a Pie Chart for Percentage Distribution**

#### **Step 1: Install Chart.js (if not already installed)**
Ensure that Chart.js and react-chartjs-2 are installed:
```bash
npm install chart.js react-chartjs-2
```

#### **Step 2: Add a Pie Chart**
Update your `App.js` to include a pie chart for percentage distribution by severity.

```javascript
import React, { useEffect, useState } from "react";
import { collection, onSnapshot, query, orderBy } from "firebase/firestore";
import { db } from "./firebaseConfig";
import { Pie } from "react-chartjs-2";

function App() {
  const [alerts, setAlerts] = useState([]);
  const [pieChartData, setPieChartData] = useState({});

  useEffect(() => {
    const alertQuery = query(collection(db, "alerts"), orderBy("timestamp", "desc"));
    const unsubscribe = onSnapshot(alertQuery, (snapshot) => {
      const data = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      setAlerts(data);

      // Prepare data for the pie chart
      const counts = data.reduce(
        (acc, alert) => {
          acc[alert.severity] = (acc[alert.severity] || 0) + 1;
          return acc;
        },
        { critical: 0, warning: 0, info: 0 }
      );

      const total = counts.critical + counts.warning + counts.info;
      setPieChartData({
        labels: ["Critical", "Warning", "Info"],
        datasets: [
          {
            data: [
              ((counts.critical / total) * 100).toFixed(2),
              ((counts.warning / total) * 100).toFixed(2),
              ((counts.info / total) * 100).toFixed(2),
            ],
            backgroundColor: ["#FF6384", "#FFCE56", "#36A2EB"],
          },
        ],
      });
    });

    return () => unsubscribe();
  }, []);

  return (
    <div style={{ padding: "20px" }}>
      <h1>Real-Time Alert Dashboard</h1>
      <div style={{ maxWidth: "400px", margin: "20px auto" }}>
        <h2>Alert Distribution</h2>
        <Pie data={pieChartData} options={{ responsive: true, maintainAspectRatio: false }} />
      </div>
      <table border="1" cellPadding="10" style={{ marginTop: "20px" }}>
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

#### **Explanation**
- The pie chart shows the percentage distribution of each severity type (Critical, Warning, Info).
- It dynamically updates as new alerts are added.

---

### **2. Enhance Filters with Multiple Conditions**

#### **Step 1: Add Advanced Filters**
Modify the UI to include additional filter conditions, such as a **time range** or **multiple severities**.

```javascript
import React, { useEffect, useState } from "react";
import { collection, onSnapshot, query, where, orderBy } from "firebase/firestore";
import { db } from "./firebaseConfig";

function App() {
  const [alerts, setAlerts] = useState([]);
  const [filter, setFilter] = useState({ severity: "", startDate: "", endDate: "" });

  useEffect(() => {
    let alertQuery = query(collection(db, "alerts"), orderBy("timestamp", "desc"));

    if (filter.severity) {
      alertQuery = query(alertQuery, where("severity", "==", filter.severity));
    }

    const unsubscribe = onSnapshot(alertQuery, (snapshot) => {
      const data = snapshot.docs
        .map((doc) => ({ id: doc.id, ...doc.data() }))
        .filter((alert) => {
          if (filter.startDate) {
            const startDate = new Date(filter.startDate).getTime();
            if (alert.timestamp?.seconds * 1000 < startDate) return false;
          }
          if (filter.endDate) {
            const endDate = new Date(filter.endDate).getTime();
            if (alert.timestamp?.seconds * 1000 > endDate) return false;
          }
          return true;
        });

      setAlerts(data);
    });

    return () => unsubscribe();
  }, [filter]);

  return (
    <div style={{ padding: "20px" }}>
      <h1>Real-Time Alert Dashboard</h1>
      <div style={{ marginBottom: "20px" }}>
        <label>Severity: </label>
        <select
          onChange={(e) => setFilter({ ...filter, severity: e.target.value })}
          value={filter.severity}
        >
          <option value="">All</option>
          <option value="critical">Critical</option>
          <option value="warning">Warning</option>
          <option value="info">Info</option>
        </select>
        <label style={{ marginLeft: "20px" }}>Start Date: </label>
        <input
          type="date"
          onChange={(e) => setFilter({ ...filter, startDate: e.target.value })}
        />
        <label style={{ marginLeft: "20px" }}>End Date: </label>
        <input
          type="date"
          onChange={(e) => setFilter({ ...filter, endDate: e.target.value })}
        />
      </div>
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

#### **Explanation**
- Filters allow selecting **severity** and filtering by **start and end dates**.
- Alerts update in real time based on the chosen criteria.

---

### **3. Combine All Enhancements**

With filters, a pie chart, and a table, your dashboard will look something like this:
- **Top Section**: Pie chart for distribution.
- **Middle Section**: Filters for severity and time range.
- **Bottom Section**: Table showing filtered alerts.

---

### **4. Deploy the Updated Dashboard**

1. Build the updated project:
   ```bash
   npm run build
   ```

2. Deploy to Firebase Hosting:
   ```bash
   firebase deploy --only hosting
   ```

--
