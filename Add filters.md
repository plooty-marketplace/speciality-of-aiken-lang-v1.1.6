Let’s add **filters** for severity and integrate **charts** to make the alert dashboard more functional and visually engaging.

---

### **1. Add Filters by Severity**

#### **Step 1: Update the React Frontend**

Modify the `App.js` to include a dropdown for filtering alerts by severity.

```javascript
import React, { useEffect, useState } from "react";
import { collection, onSnapshot, query, where, orderBy } from "firebase/firestore";
import { db } from "./firebaseConfig";

function App() {
  const [alerts, setAlerts] = useState([]);
  const [filter, setFilter] = useState("");

  useEffect(() => {
    const alertQuery = filter
      ? query(
          collection(db, "alerts"),
          where("severity", "==", filter),
          orderBy("timestamp", "desc")
        )
      : query(collection(db, "alerts"), orderBy("timestamp", "desc"));

    const unsubscribe = onSnapshot(alertQuery, (snapshot) => {
      setAlerts(
        snapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }))
      );
    });

    return () => unsubscribe();
  }, [filter]);

  return (
    <div style={{ padding: "20px" }}>
      <h1>Real-Time Alert Dashboard</h1>
      <label>Filter by Severity: </label>
      <select onChange={(e) => setFilter(e.target.value)} value={filter}>
        <option value="">All</option>
        <option value="critical">Critical</option>
        <option value="warning">Warning</option>
        <option value="info">Info</option>
      </select>
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
- The dropdown (`<select>`) allows users to choose a severity level.
- The `query` dynamically adjusts based on the `filter` state.
- Alerts update in real-time based on the filter.

---

### **2. Add Charts for Visualizing Alerts**

#### **Step 1: Install Chart.js**
Install the Chart.js library in your project:
```bash
npm install chart.js react-chartjs-2
```

#### **Step 2: Add a Bar Chart for Alert Counts by Severity**
Update the `App.js` to include a chart alongside the table:

```javascript
import React, { useEffect, useState } from "react";
import { collection, onSnapshot, query, orderBy } from "firebase/firestore";
import { db } from "./firebaseConfig";
import { Bar } from "react-chartjs-2";

function App() {
  const [alerts, setAlerts] = useState([]);
  const [chartData, setChartData] = useState({});

  useEffect(() => {
    const alertQuery = query(collection(db, "alerts"), orderBy("timestamp", "desc"));
    const unsubscribe = onSnapshot(alertQuery, (snapshot) => {
      const data = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      setAlerts(data);

      // Prepare data for the chart
      const counts = data.reduce(
        (acc, alert) => {
          acc[alert.severity] = (acc[alert.severity] || 0) + 1;
          return acc;
        },
        { critical: 0, warning: 0, info: 0 }
      );

      setChartData({
        labels: ["Critical", "Warning", "Info"],
        datasets: [
          {
            label: "Alert Counts",
            data: [counts.critical, counts.warning, counts.info],
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
      <div style={{ maxWidth: "600px", margin: "20px auto" }}>
        <Bar data={chartData} options={{ responsive: true, maintainAspectRatio: false }} />
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
- **Chart.js** creates a bar chart showing the count of each severity type (`Critical`, `Warning`, `Info`).
- The chart updates automatically when new alerts are logged.

---

### **3. Add Alerts Over Time (Optional)**

For visualizing alerts over time, you can use a line chart with **timestamps** on the x-axis and counts on the y-axis.

Modify the chart data preparation to group alerts by day/hour:
```javascript
const countsOverTime = alerts.reduce((acc, alert) => {
  const date = new Date(alert.timestamp?.seconds * 1000).toDateString();
  acc[date] = (acc[date] || 0) + 1;
  return acc;
}, {});

// Prepare line chart data
const lineChartData = {
  labels: Object.keys(countsOverTime),
  datasets: [
    {
      label: "Alerts Over Time",
      data: Object.values(countsOverTime),
      borderColor: "#36A2EB",
      fill: false,
    },
  ],
};
```

---

### **4. Deploy Updated Dashboard**

1. Build the updated project:
   ```bash
   npm run build
   ```

2. Deploy to Firebase Hosting:
   ```bash
   firebase deploy --only hosting
   ```

--
