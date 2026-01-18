# Sales Forecasting

Regression models for revenue prediction and business planning.

## Summary

Machine learning models predicting transaction values with 92% accuracy.

## Model Performance

| Model | R² Score | MAE |
|-------|----------|-----|
| Linear Regression | 0.92 | $224 |
| Random Forest | 0.99 | ~$0 |

## Key Drivers

| Feature | Correlation |
|---------|-------------|
| Unit Price | 0.80 |
| Quantity | 0.51 |
| Service Type | 0.22 |

## Findings

- Pricing is primary revenue lever
- Minimal seasonality - consistent year-round demand
- Order size directly impacts transaction value

## Files

- `Sales_Forecasting.ipynb` - Full analysis notebook
- `visualisations/` - Model outputs and charts
