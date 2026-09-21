# 🔴 RedFlag – The Fraud Files

> **Every Transaction Tells a Story. We Find the Red Flags.**

## 📌 Project Overview

RedFlag – The Fraud Files is a pure SQL-based financial fraud detection project developed using MySQL.

The project analyzes transaction data and identifies suspicious user behaviour through 12 different fraud detection patterns.

The project uses a fictional Indian fintech payment dataset called PayFast.

---

## 🎯 Project Objectives

- Identify suspicious transaction behaviour.
- Detect unusual user and merchant activity.
- Analyze financial transactions using SQL.
- Apply basic and advanced SQL concepts.
- Identify potential fraud patterns.

---

## 🗃️ Dataset Details

| Item | Details |
|---|---|
| Database | redflag |
| Table | transactions |
| Total Transactions | 200,594 |
| Unique Users | 1,475 |
| Unique Merchants | 800 |
| Time Period | January–June 2024 |
| Payment Modes | UPI, CARD, NETBANKING, WALLET |
| Transaction Status | SUCCESS, FAILED |

---

## 🚩 Fraud Detection Patterns

1. Velocity Fraud
2. Round-Amount Clustering
3. Card Testing
4. Failed-Then-Succeeded Transactions
5. Odd-Hour Concentration
6. Mule Accounts
7. Refund Abuse
8. Merchant Collusion
9. Just-Under-Threshold Transactions
10. Dormant-Then-Active Accounts
11. Velocity Spike
12. Geographic Impossibility

---

## 🛠️ Technology Stack

- MySQL
- SQL
- Common Table Expressions (CTEs)
- Subqueries
- EXISTS
- Window Functions
- GROUP BY and HAVING
- Date and Time Functions

---

## ⭐ Key Features

- Pure SQL-based fraud detection.
- 12 different fraud detection patterns.
- Suspicious user behaviour analysis.
- Financial transaction analysis.
- Advanced SQL query implementation.
- Real-world fintech use case.

---

## 📁 Repository Structure

```text
RedFlag-The-Fraud-Files/
│
├── README.md
│
├── sql/
│   └── RedFlag_Sharvari.sql
│
├── poster/
│   └── RedFlag_Poster.png
│
├── screenshots/
│   └── database_verification.png
│
└── docs/
```

---

## ▶️ How to Run the Project

### Step 1: Open MySQL Workbench

### Step 2: Open the SQL File

Open:

```text
RedFlag_Sharvari.sql
```

### Step 3: Select the Required Database

```sql
USE redflag;
```

### Step 4: Verify the Dataset

```sql
SELECT COUNT(*) AS total_rows
FROM transactions;
```

### Step 5: Execute the Queries

Run the fraud detection queries pattern by pattern.

---

## 📊 Project Highlights

- Analyzes 200,594 transactions.
- Includes 1,475 unique users.
- Includes 800 unique merchants.
- Detects 12 suspicious transaction patterns.
- Uses MySQL and advanced SQL concepts.
- Designed for academic and portfolio purposes.

---

## 🎓 Learning Outcomes

Through this project, I improved my understanding of:

- SQL querying
- Data analysis
- Fraud detection concepts
- Database management
- CTEs and subqueries
- Window functions
- Date and time analysis

---

## 👩‍💻 Author

**Sharvari Rajendra Patil**

**Project:** RedFlag – The Fraud Files

**Technology:** MySQL and SQL

---

## 🔐 Project Tagline

> **Detect the Pattern. Prevent the Threat.**

---

## ⚠️ Disclaimer

The PayFast dataset is fictional/synthetic and is used for educational and analytical purposes only.
