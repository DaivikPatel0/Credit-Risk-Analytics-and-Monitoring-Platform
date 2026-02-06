# 📊 Credit Risk Analytics & Monitoring Platform

An end-to-end **Credit Risk Analytics and Monitoring Platform** built using **PostgreSQL, Python (Machine Learning), and Power BI**, with a strong focus on **real-world risk analysis, loss monitoring, and decision support** rather than inflated accuracy claims.

This project mirrors how credit risk is approached in financial institutions:  
**data → modeling → evaluation → risk interpretation → business dashboards**.

---

## 🎯 Project Objective

The objective of this project is to:
- Analyze loan-level credit risk
- Build a realistic machine learning model for default risk
- Convert model outputs into **risk rankings**, not just predictions
- Support **portfolio monitoring and loss analysis**
- Visualize insights using **Power BI**

Rather than optimizing for unrealistic accuracy, this project emphasizes **data quality, transparency, and business relevance**.

---

## 🗂️ Dataset Overview

- Source: Kaggle (Loan Default Dataset) - https://www.kaggle.com/datasets/hemanthsai7/loandefault/data
- Only the **training dataset** was used
- The provided test dataset was intentionally excluded due to:
  - Poor data quality
  - Missing target information
  - Inability to validate real performance

Working exclusively with high-quality labeled data ensures **trustworthy evaluation**.

---

## 🧭 Project Workflow

### **01. Data Loading**
- Loaded raw loan data into Python (`01_load_train_data`)
- Performed initial inspection and sanity checks
- Created clear **column descriptions** to understand each feature

---

### **02. Column Standardization**
- Standardized all column names (`02_standardize_columns`)
- Converted names to:
  - lowercase
  - snake_case
- This improved usability across SQL, Python, and Power BI

---

### **03. PostgreSQL Integration**
- Created PostgreSQL database manually: `loan_risk_db`
- Loaded cleaned data into PostgreSQL (`03_load_to_postgres`)
- Enabled a **professional data pipeline** instead of file-based workflows

---

### **04. SQL Analysis & Views**
Executed **15 SQL queries** to analyze the portfolio and created **3 business-ready views** for Power BI:

#### SQL Views:
- `v_kpi_overview`  
  Portfolio-level KPIs (loans, defaults, default rate, averages)

- `v_risk_by_grade_term`  
  Risk analysis by credit grade and loan term

- `v_loss_recovery_by_grade`  
  Defaulted loans, recoveries, and estimated net loss

These views decouple **business logic** from dashboards.

---

### **05. Data Reload for Machine Learning**
- Reloaded data from PostgreSQL (`04_prep_split`)
- Followed a **production-style workflow**
- Removed post-loan and leakage-prone columns (e.g. recoveries, collections)

---

### **06. Feature Engineering & Encoding**

Encoding was selected **based on cardinality and semantics**:

| Feature Type | Encoding |
|-------------|----------|
| Low-cardinality categorical | One-Hot Encoding |
| Ordinal (Grade, Sub-grade) | Ordinal Encoding |
| High-cardinality (Loan Title, Batch) | Leave-One-Out Encoding |

This avoided:
- dimensional explosion
- target leakage
- incorrect numeric assumptions

---

### **07. Model Training (LightGBM)**

- Model: **LightGBM Classifier**
- Target: `loan_status` (0 = non-default, 1 = default)
- Strategy:
  - Stratified train/test split
  - Class imbalance handling
  - Early stopping
- Metrics used:
  - Log Loss
  - PR-AUC

#### Final Model Performance:
Log Loss : 0.3084
PR-AUC : 0.0924


Multiple tree-based models were tested, all converging to similar results — indicating **data signal limitation rather than model weakness**.

---

### **08. Risk Ranking & Interpretation**

Instead of relying on raw probability thresholds (which failed due to probability compression), the final solution uses:

✅ **Percentile-based risk ranking**

- Customers ranked by predicted default probability
- Risk groups assigned by percentile:
  - Low Risk
  - Medium Risk
  - High Risk

This approach reflects **industry-standard portfolio monitoring**, even when absolute probabilities are weak.

---

### **09. Power BI Output Table**

A clean, analytics-ready table was created and loaded to PostgreSQL:

**`loan_risk_scoring_output`**

Includes:
- Loan ID
- Predicted probability of default
- Risk percentile
- Risk bucket
- Actual default
- Business attributes (grade, interest rate, loan amount)

This table acts as the **contract between ML and BI**.

---

## 📊 Power BI Dashboard

The Power BI dashboard focuses on **clarity and decision support**.

### Key Sections:
- Portfolio KPIs (Loans, Defaults, Default Rate)
- Default Rate by Credit Grade
- Loan Volume by Grade
- Estimated Net Loss by Grade
- Risk Bucket Distribution
- ML Risk Monitoring

The dashboard intentionally shows **both strengths and limitations** of the model.

---

## 🧠 Key Insights

- Machine learning performance is constrained by **feature signal**, not algorithms
- Default risk is better monitored through **ranking and segmentation**
- Loss concentration analysis provides more value than prediction accuracy alone
- Transparent evaluation builds credibility

---

## 🛠️ Tools & Technologies

- **Python**: Pandas, Scikit-learn, LightGBM
- **Database**: PostgreSQL
- **Visualization**: Power BI
- **Environment**: Jupyter Notebook

---

## 🚀 Future Enhancements

- Add behavioral & time-series features
- Monitor score drift over time
- Combine ML outputs with rule-based credit policies
- Expand loss optimization strategies

---

## 📌 Final Note

This project emphasizes **real-world credit risk practice**:
- Honest evaluation
- Practical modeling
- Business-first analytics

It is designed as a **monitoring and decision-support platform**, not a Kaggle-style leaderboard solution.

