# Azure Banking Data Engineering Pipeline

> A production-grade, end-to-end Azure Data Engineering pipeline for banking transaction analytics, real-time fraud detection, and compliance-grade reporting dashboards.

---

## Project Overview

This project simulates a real-world banking data engineering pipeline built on **Microsoft Azure**. It ingests high-volume financial transaction data from multiple sources, applies PySpark transformations and enrichment logic, detects fraudulent transactions, and delivers interactive Power BI dashboards for business and compliance stakeholders.

---

## Architecture

```

                     DATA SOURCES                                
   Core Banking DB        CRM System       Account Management  
  (Transactions CSV)    (Clients CSV)       (Accounts CSV)     

                                                    
                                                    

              AZURE DATA FACTORY (Orchestration)                 
         pl_banking_ingestion — Copy Activities (On Success)     

                               
                               

           ADLS Gen2 — BRONZE LAYER (Raw Data)                   
   bronze/transactions/  bronze/clients/  bronze/accounts/     

                               
                               

         AZURE DATABRICKS — SILVER LAYER (Transformation)        
  • Data Cleaning & Standardization                              
  • Join Transactions + Clients + Accounts                       
  • Fraud Detection Rules & Scoring                              
  • PySpark Transformations                                       

                               
                               

           ADLS Gen2 — GOLD LAYER (Analytics-Ready)              
              gold/banking_enriched/                             

                               
                               

         DATABRICKS SQL + POWER BI (Reporting Layer)             
  • Transaction Analytics  • Fraud Monitoring  • KPI Dashboards  

```

---

## Azure Services Used

| Service | Purpose | Configuration |
|---|---|---|
| **Azure Resource Group** | Container for all project resources | `rg-banking-pipeline` — East US |
| **Azure Data Lake Storage Gen2** | Medallion Architecture Data Lake | `bankingdldaya` — Bronze/Silver/Gold |
| **Azure Data Factory** | Pipeline orchestration & ingestion | `adf-banking-daya` — V2 |
| **Azure Databricks** | PySpark transformations & SQL | `databricks-banking-daya` — Runtime 13.3 LTS |
| **Power BI** | Interactive dashboards & reporting | `banking_enriched_model` |

---

## Project Structure

```
azure-banking-data-pipeline/

 data/
    bronze/                         # Raw source data
       core_banking_transactions.csv  # 30 banking transactions
       client_master.csv              # 15 client records
       account_details.csv            # 15 account records
    silver/                         # Cleaned & processed data
    gold/                           # Analytics-ready data

 notebooks/
    banking_transformation.py          # PySpark transformation notebook

 adf-pipelines/
    pl_banking_ingestion.json          # ADF pipeline definition

 sql-queries/
    banking_queries.sql                # Fraud detection SQL queries

 powerbi/
    banking.pbix                       # Power BI dashboard file

 docs/
    architecture_diagram.png           # Architecture diagram

 README.md
```

---

## Data Sources

### 1. Core Banking Transactions (`core_banking_transactions.csv`)
- **Source System:** Core Banking System (Temenos T24 / FIS)
- **Ingestion:** ADF Copy Activity — Incremental load via watermark
- **Records:** 30 transactions
- **Key Columns:** `transaction_id`, `client_id`, `account_number`, `transaction_date`, `amount`, `currency`, `channel`, `status`, `is_flagged`, `flag_reason`

### 2. Client Master (`client_master.csv`)
- **Source System:** CRM System — Flat file export
- **Ingestion:** ADF Copy Activity — Direct CSV load
- **Records:** 15 clients
- **Key Columns:** `client_id`, `first_name`, `last_name`, `kyc_status`, `risk_rating`, `credit_score`, `annual_income`

### 3. Account Details (`account_details.csv`)
- **Source System:** Account Management System — Flat file export
- **Ingestion:** ADF Copy Activity — Direct CSV load
- **Records:** 15 accounts
- **Key Columns:** `account_number`, `account_type`, `current_balance`, `daily_transaction_limit`, `branch_name`

---

## Pipeline Steps

### Step 1 — Infrastructure Setup
- Created Resource Group: `rg-banking-pipeline`
- Created ADLS Gen2: `bankingdldaya` with Bronze/Silver/Gold containers
- Enabled Hierarchical Namespace (Gen2)
- Configured Private Access on all containers

### Step 2 — Azure Data Factory
- Created ADF: `adf-banking-daya` (V2)
- Configured Linked Service: `ls_adls_banking`
- Created 4 Datasets: `ds_bronze_transactions`, `ds_bronze_clients`, `ds_bronze_accounts`, `ds_silver_output`
- Built Pipeline: `pl_banking_ingestion` with 3 Copy Activities connected via **On Success**
- Validated and ran pipeline — all 3 activities succeeded

### Step 3 — Azure Databricks Transformation
- Created Databricks Workspace: `databricks-banking-daya`
- Created Cluster: `banking-cluster` (Runtime 13.3 LTS)
- Connected to ADLS Gen2 via Account Key
- Loaded 3 CSV files from Silver layer
- Applied data cleaning & standardization (ISO 8601 dates, uppercase formatting)
- Joined transactions + clients + accounts into unified dataset
- Applied fraud detection logic & scoring
- Written enriched data to Gold layer

### Step 4 — SQL Analytics
- Created Database: `banking_db`
- Created Table: `banking_enriched` (30 rows, 27 columns)
- Ran 5 SQL queries for fraud analysis

### Step 5 — Power BI Dashboards
- Connected Power BI to Databricks via Personal Access Token
- Loaded `banking_enriched` table (30 rows, 27 columns)
- Built 5 interactive dashboards

---

## Fraud Detection Rules

| Rule | Description | Risk Score |
|---|---|---|
| `HIGH_VALUE_FOREIGN` | Large transactions from foreign locations | 90 |
| `MICRO_TRANSACTION` | Rapid $0.01 transactions (card testing attack) | 90 |
| `LARGE_WIRE_TRANSFER` | Suspicious large international wire transfers | 90 |
| `UNUSUALLY_LARGE_CREDIT` | Unusually large credit from unknown source | 90 |
| `EXCEEDS_DAILY_LIMIT` | Transaction exceeds account daily limit | 60 |
| `HIGH_RISK_CLIENT` | Transaction from HIGH risk rated client | 70 |
| `NONE` | Normal transaction | 10 |

---

## Dashboard Insights

| KPI | Value |
|---|---|
| Total Transactions | 30 |
| Total Transaction Amount | $115,103.98 |
| Flagged Transactions | 9 (30%) |
| High Risk Clients | 3 |
| Normal Transactions | 21 (70%) |

### Dashboards Built:
1. **Transaction Volume by Channel** — Bar chart showing ONLINE, POS, BANK_TRANSFER, WIRE
2. **Fraud vs Normal Transactions** — Pie chart with fraud rule breakdown
3. **Total Amount by Transaction Type** — Donut chart showing DEBIT vs CREDIT
4. **Fraud Score by Client** — Column chart with risk rating color coding
5. **Top Clients by Amount** — Table with fraud scores and risk ratings

---

## Tech Stack

```
Language:     Python (PySpark), SQL
Runtime:      Databricks Runtime 13.3 LTS (Apache Spark 3.4.1)
Storage:      Azure Data Lake Storage Gen2
Orchestration: Azure Data Factory V2
Compute:      Azure Databricks (Single Node Cluster)
Reporting:    Power BI Service
Architecture: Medallion Architecture (Bronze → Silver → Gold)
```

---

## Key Concepts Demonstrated

- **Medallion Architecture** — Bronze/Silver/Gold data zones
- **Incremental Load Pattern** — Watermark-based extraction
- **On Success Pipeline** — Production-grade error handling
- **PySpark Transformations** — Data cleaning, joins, enrichment
- **Fraud Detection Logic** — Rule-based anomaly detection
- **Data Enrichment** — Joining multiple data sources
- **SQL Analytics** — Complex fraud detection queries
- **Power BI Integration** — Interactive dashboards via Databricks connector

---

## How to Run This Project

### Prerequisites:
- Active Azure Subscription
- Azure Databricks Workspace
- Power BI Account
- Python 3.x

### Steps:
1. Clone this repository:
```bash
git clone https://github.com/YOUR_USERNAME/azure-banking-data-pipeline.git
cd azure-banking-data-pipeline
```

2. Upload CSV files from `data/bronze/` to your ADLS Gen2 Bronze container

3. Create ADF pipeline using the definition in `adf-pipelines/`

4. Run the Databricks notebook from `notebooks/banking_transformation.py`

5. Open `powerbi/banking.pbix` in Power BI Desktop

---

## Learnings & Challenges

| Challenge | Solution |
|---|---|
| Storage account name conflicts | Used unique naming convention with personal identifier |
| Databricks serverless JVM limitations | Switched to Single User cluster with Runtime 13.3 LTS |
| Ambiguous column reference in PySpark join | Explicitly referenced DataFrame name for each column |
| Silver layer file path mismatch | Used `dbutils.fs.ls()` to verify actual file paths |
| Power BI authentication | Used Personal Access Token instead of Client Credentials |

---

## Author

**Daya** — Azure Data Engineering Project 2
- Project: Hands-on Azure Data Engineering — Banking Use Case
- Based on: NCPL Azure Data Engineering Projects Guide

---

## License

This project is for educational purposes as part of the Azure Data Engineering learning curriculum.

---

> If you found this project helpful, please give it a star!
