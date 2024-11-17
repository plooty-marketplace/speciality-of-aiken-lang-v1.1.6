Great! Let’s focus on refining **role-based access** with custom permissions, implementing **real-time notifications** for different roles, and optimizing for a **mobile-friendly layout**.

### **1. Role-Based Access with Custom Permissions**

You can further extend role-based access by checking user roles from **Firebase Firestore** or any other data source to manage permissions dynamically. Here's how you can implement that.

#### **A. Storing User Roles in Firestore**

Create a **Firestore collection** called `users` to store role information for each user. Each document can represent a user, with fields like `role` (`admin`, `viewer`, etc.).

Example document:

```json
{
  "email": "user@example.com",
  "role": "admin"
}
```

#### **B. Fetching User Roles After Login**

Once the user logs in, fetch their role from Firestore and apply different UI logic based on the role.

Here’s how you can do it:

```javascript
import { getFirestore, doc, getDoc } from "firebase/firestore";
import { getAuth, onAuthStateChanged } from "firebase/auth";
import { useEffect, useState } from "react";

const db = getFirestore();
const auth = getAuth();

const App = () => {
  const [user, setUser] = useState(null);
  const [role, setRole] = useState(null);

  useEffect(() => {
    onAuthStateChanged(auth, async (user) => {
      if (user) {
        setUser(user); // User is logged in
        // Fetch role from Firestore
        const userDoc = await getDoc(doc(db, "users", user.uid));
        if (userDoc.exists()) {
          setRole(userDoc.data().role);
        }
      } else {
        setUser(null); // User is not logged in
        setRole(null);
      }
    });
  }, []);

  const handleLogin = async () => {
    try {
      await signInWithEmailAndPassword(auth, "user@example.com", "password123");
    } catch (error) {
      console.error("Login failed", error);
    }
  };

  return (
    <div style={{ padding: "20px" }}>
      {user ? (
        <>
          <h1>Welcome, {user.email}</h1>
          {role === "admin" ? (
            <div>
              <h2>Admin Dashboard</h2>
              {/* Admin Features */}
            </div>
          ) : role === "viewer" ? (
            <div>
              <h2>Viewer Dashboard</h2>
              {/* Viewer Features */}
            </div>
          ) : (
            <h2>Loading your role...</h2>
          )}
        </>
      ) : (
        <div>
          <h1>Please Log In</h1>
          <button onClick={handleLogin}>Log In</button>
        </div>
      )}
    </div>
  );
};

export default App;
```

### **2. Real-Time Notifications for Role-Based Actions**

Real-time notifications will allow you to alert users of important actions such as new **critical alerts** or changes in their **permissions**. We will use **Firebase Firestore** with **Firestore listeners** (`onSnapshot`) to provide real-time updates.

#### **A. Firebase Firestore Listener for Real-Time Data**

First, you’ll need to listen for changes in **alerts** or any other data in your Firestore collection, then trigger notifications.

```javascript
import { getFirestore, collection, query, where, onSnapshot } from "firebase/firestore";
import { useEffect, useState } from "react";
import { toast } from "react-toastify";

const db = getFirestore();

const App = () => {
  const [alerts, setAlerts] = useState([]);
  
  // Firebase listener for critical alerts
  useEffect(() => {
    const alertsQuery = query(collection(db, "alerts"), where("severity", "==", "critical"));
    
    const unsubscribe = onSnapshot(alertsQuery, (snapshot) => {
      const newAlerts = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      }));
      setAlerts(newAlerts);

      // Send toast notification when a critical alert is added
      newAlerts.forEach(alert => {
        toast.error(`New Critical Alert: ${alert.text}`);
      });
    });

    return () => unsubscribe();
  }, []);

  return (
    <div>
      <h1>Real-Time Alerts</h1>
      {alerts.map(alert => (
        <div key={alert.id}>
          <h2>{alert.severity}</h2>
          <p>{alert.text}</p>
          <p>{new Date(alert.timestamp).toLocaleString()}</p>
        </div>
      ))}
    </div>
  );
};

export default App;
```

In this example, the app listens for **critical alerts** in real-time and displays them. If a new **critical alert** is added to Firestore, it triggers a toast notification.

#### **B. Real-Time User Role Notification**

If you want to notify users of changes in their roles, you can use a similar approach. For example, if the admin changes a user’s role to **viewer**, you can send a real-time notification to that user.

```javascript
useEffect(() => {
  const userQuery = query(collection(db, "users"), where("role", "==", "viewer"));
  
  const unsubscribe = onSnapshot(userQuery, (snapshot) => {
    snapshot.docs.forEach(doc => {
      const user = doc.data();
      if (user.role === "viewer") {
        toast.success(`Your role has been updated to ${user.role}`);
      }
    });
  });

  return () => unsubscribe();
}, []);
```

### **3. Mobile-Friendly Layouts**

For mobile-first designs, you'll want to ensure your charts, tables, and other UI elements adapt to the screen size. Here’s how you can optimize your **layout** for mobile:

#### **A. Make Your Tables Scrollable on Small Screens**

Add `overflow-x` to your table container to ensure it’s scrollable on smaller screens.

```css
.table-container {
  overflow-x: auto;
}

table {
  min-width: 600px;  /* Ensure table content fits on larger screens */
}
```

For very small screens, you can use **CSS Flexbox** to stack the content vertically:

```css
@media (max-width: 768px) {
  .container {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  table {
    width: 100%;  /* Make table full-width on small screens */
  }
}
```

#### **B. Responsive Charts**

For **Chart.js** or other charts, ensure they resize properly:

```javascript
const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,  // Allow resizing based on container size
};
```

### **Next Steps:**

With these updates, your app will:
1. **Control access** based on roles (`admin`, `viewer`).
2. Show **real-time notifications** for critical alerts or role updates.
3. Be optimized for mobile screens with **responsive layouts** and **charts*
