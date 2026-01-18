/*
================================================================================
FINANCIAL PERFORMANCE ANALYSIS
SQL Queries for Expense Data Analysis
Author: Data Analyst
Date: January 2025
================================================================================
PURPOSE: Extract, aggregate, and analyze financial data to identify trends in 
expenses, budget adherence, and cost optimization opportunities across quarters,
categories, and locations.
================================================================================
*/

-- ============================================================================
-- SETUP: Table Creation (Run once for SQLite/MySQL import)
-- ============================================================================

CREATE TABLE IF NOT EXISTS expenses (
    record_date VARCHAR(10),
    month_name VARCHAR(20),
    city VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    budgeted_expense DECIMAL(10,2),
    actual_expense DECIMAL(10,2)
);

-- Import Financial_Dataset_Expense_Items_.csv into expenses table

-- ============================================================================
-- QUERY 1: ANNUAL SUMMARY - Executive Overview
-- Purpose: High-level KPIs for leadership dashboard
-- ============================================================================

SELECT 
    'FY2024' AS fiscal_year,
    COUNT(DISTINCT category) AS expense_categories,
    COUNT(DISTINCT city) AS operating_locations,
    ROUND(SUM(budgeted_expense), 2) AS total_budget,
    ROUND(SUM(actual_expense), 2) AS total_actual,
    ROUND(SUM(actual_expense) - SUM(budgeted_expense), 2) AS total_variance,
    ROUND((SUM(actual_expense) - SUM(budgeted_expense)) / SUM(budgeted_expense) * 100, 2) AS variance_pct,
    CASE 
        WHEN (SUM(actual_expense) - SUM(budgeted_expense)) / SUM(budgeted_expense) > 0.05 THEN 'OVER BUDGET'
        WHEN (SUM(actual_expense) - SUM(budgeted_expense)) / SUM(budgeted_expense) < -0.05 THEN 'UNDER BUDGET'
        ELSE 'ON TRACK'
    END AS budget_status
FROM expenses;

-- ============================================================================
-- QUERY 2: QUARTERLY PERFORMANCE ANALYSIS
-- Purpose: Identify seasonal spending patterns and quarter-over-quarter trends
-- ============================================================================

SELECT 
    CASE 
        WHEN month_name IN ('January', 'February', 'March') THEN 'Q1'
        WHEN month_name IN ('April', 'May', 'June') THEN 'Q2'
        WHEN month_name IN ('July', 'August', 'September') THEN 'Q3'
        WHEN month_name IN ('October', 'November', 'December') THEN 'Q4'
    END AS quarter,
    ROUND(SUM(budgeted_expense), 2) AS quarterly_budget,
    ROUND(SUM(actual_expense), 2) AS quarterly_actual,
    ROUND(SUM(actual_expense) - SUM(budgeted_expense), 2) AS variance_dollars,
    ROUND((SUM(actual_expense) - SUM(budgeted_expense)) / SUM(budgeted_expense) * 100, 2) AS variance_pct,
    ROUND(SUM(actual_expense) / (SELECT SUM(actual_expense) FROM expenses) * 100, 2) AS pct_of_annual
FROM expenses
GROUP BY 
    CASE 
        WHEN month_name IN ('January', 'February', 'March') THEN 'Q1'
        WHEN month_name IN ('April', 'May', 'June') THEN 'Q2'
        WHEN month_name IN ('July', 'August', 'September') THEN 'Q3'
        WHEN month_name IN ('October', 'November', 'December') THEN 'Q4'
    END
ORDER BY quarter;

-- ============================================================================
-- QUERY 3: EXPENSE CATEGORY BREAKDOWN
-- Purpose: Identify largest cost centers and budget adherence by category
-- ============================================================================

SELECT 
    category,
    ROUND(SUM(budgeted_expense), 2) AS category_budget,
    ROUND(SUM(actual_expense), 2) AS category_actual,
    ROUND(SUM(actual_expense) - SUM(budgeted_expense), 2) AS variance,
    ROUND((SUM(actual_expense) - SUM(budgeted_expense)) / SUM(budgeted_expense) * 100, 2) AS variance_pct,
    ROUND(SUM(actual_expense) / (SELECT SUM(actual_expense) FROM expenses) * 100, 2) AS pct_of_total,
    RANK() OVER (ORDER BY SUM(actual_expense) DESC) AS cost_rank
FROM expenses
GROUP BY category
ORDER BY category_actual DESC;

-- ============================================================================
-- QUERY 4: CITY/LOCATION ANALYSIS
-- Purpose: Compare operational efficiency across geographic locations
-- ============================================================================

SELECT 
    city,
    ROUND(SUM(budgeted_expense), 2) AS location_budget,
    ROUND(SUM(actual_expense), 2) AS location_actual,
    ROUND(SUM(actual_expense) - SUM(budgeted_expense), 2) AS variance,
    ROUND((SUM(actual_expense) - SUM(budgeted_expense)) / SUM(budgeted_expense) * 100, 2) AS variance_pct,
    ROUND(SUM(actual_expense) / (SELECT SUM(actual_expense) FROM expenses) * 100, 2) AS pct_of_total,
    CASE 
        WHEN ABS((SUM(actual_expense) - SUM(budgeted_expense)) / SUM(budgeted_expense)) < 0.01 THEN '★★★ Excellent'
        WHEN ABS((SUM(actual_expense) - SUM(budgeted_expense)) / SUM(budgeted_expense)) < 0.02 THEN '★★ Good'
        ELSE '★ Needs Review'
    END AS budget_discipline
FROM expenses
GROUP BY city
ORDER BY location_actual DESC;

-- ============================================================================
-- QUERY 5: MONTHLY TREND ANALYSIS
-- Purpose: Track month-over-month spending patterns for forecasting
-- ============================================================================

SELECT 
    month_name,
    ROUND(SUM(budgeted_expense), 2) AS monthly_budget,
    ROUND(SUM(actual_expense), 2) AS monthly_actual,
    ROUND(SUM(actual_expense) - SUM(budgeted_expense), 2) AS monthly_variance,
    ROUND(SUM(SUM(actual_expense)) OVER (
        ORDER BY CASE month_name
            WHEN 'January' THEN 1 WHEN 'February' THEN 2 WHEN 'March' THEN 3
            WHEN 'April' THEN 4 WHEN 'May' THEN 5 WHEN 'June' THEN 6
            WHEN 'July' THEN 7 WHEN 'August' THEN 8 WHEN 'September' THEN 9
            WHEN 'October' THEN 10 WHEN 'November' THEN 11 WHEN 'December' THEN 12
        END
    ), 2) AS ytd_actual
FROM expenses
GROUP BY month_name
ORDER BY 
    CASE month_name
        WHEN 'January' THEN 1 WHEN 'February' THEN 2 WHEN 'March' THEN 3
        WHEN 'April' THEN 4 WHEN 'May' THEN 5 WHEN 'June' THEN 6
        WHEN 'July' THEN 7 WHEN 'August' THEN 8 WHEN 'September' THEN 9
        WHEN 'October' THEN 10 WHEN 'November' THEN 11 WHEN 'December' THEN 12
    END;

-- ============================================================================
-- QUERY 6: CATEGORY-CITY MATRIX
-- Purpose: Deep dive into spending patterns across dimensions
-- ============================================================================

SELECT 
    category,
    city,
    ROUND(SUM(budgeted_expense), 2) AS budget,
    ROUND(SUM(actual_expense), 2) AS actual,
    ROUND(SUM(actual_expense) - SUM(budgeted_expense), 2) AS variance
FROM expenses
GROUP BY category, city
ORDER BY category, city;

-- ============================================================================
-- QUERY 7: OVER-BUDGET CATEGORIES BY QUARTER
-- Purpose: Flag specific areas requiring cost control attention
-- ============================================================================

SELECT 
    CASE 
        WHEN month_name IN ('January', 'February', 'March') THEN 'Q1'
        WHEN month_name IN ('April', 'May', 'June') THEN 'Q2'
        WHEN month_name IN ('July', 'August', 'September') THEN 'Q3'
        WHEN month_name IN ('October', 'November', 'December') THEN 'Q4'
    END AS quarter,
    category,
    ROUND(SUM(budgeted_expense), 2) AS budget,
    ROUND(SUM(actual_expense), 2) AS actual,
    ROUND(SUM(actual_expense) - SUM(budgeted_expense), 2) AS overage
FROM expenses
GROUP BY 
    CASE 
        WHEN month_name IN ('January', 'February', 'March') THEN 'Q1'
        WHEN month_name IN ('April', 'May', 'June') THEN 'Q2'
        WHEN month_name IN ('July', 'August', 'September') THEN 'Q3'
        WHEN month_name IN ('October', 'November', 'December') THEN 'Q4'
    END,
    category
HAVING SUM(actual_expense) > SUM(budgeted_expense)
ORDER BY quarter, overage DESC;

-- ============================================================================
-- QUERY 8: SUB-CATEGORY DETAIL (DRILL-DOWN)
-- Purpose: Granular analysis for line-item budget review
-- ============================================================================

SELECT 
    category,
    sub_category,
    ROUND(SUM(budgeted_expense), 2) AS budget,
    ROUND(SUM(actual_expense), 2) AS actual,
    ROUND(SUM(actual_expense) - SUM(budgeted_expense), 2) AS variance,
    ROUND((SUM(actual_expense) - SUM(budgeted_expense)) / SUM(budgeted_expense) * 100, 2) AS variance_pct
FROM expenses
GROUP BY category, sub_category
ORDER BY category, actual DESC;

/*
================================================================================
END OF QUERIES
================================================================================
NOTES FOR ANALYST:
1. Run Query 1 first for executive summary
2. Query 2-4 support dashboard visualizations
3. Query 5 feeds monthly trend line charts
4. Query 7 is critical for identifying cost control priorities
5. Export results to Excel for visualization (see Project2_Financial_Summary.xlsx)
================================================================================
*/
