# Prophet Mobile Forecasting

Use Facebook Prophet to forecast mobile app metrics (DAU, Installs, IAP) for iOS and Android platforms.

## Requirements

```r
install.packages(c("prophet", "ggplot2", "scales", "openxlsx"))
```

## Usage

1. Put your data files: `Android_365.csv` and `Apple_365.csv`
2. Run the script:
   ```r
   source("prophet_forecast.R")
   ```

## Data Format

Your CSV should have these columns:
- `event_date`: Date (YYYY-MM-DD)
- `DAU`: Daily Active Users
- `installs`: Daily installs
- `IAP`: In-App Purchases

## Output

- 6 Excel files with forecasts
- 6 visualization plots (Android=Blue, Apple=Red)
- 365-day predictions

That's it! 🚀
