# Load required libraries
library(prophet)
library(ggplot2)
library(scales)
library(openxlsx)

# Function to process data, fit model, predict
process_forecast <- function(data, column_name, output_file) {
  # Prepare data for Prophet
  data_prophet <- data[, c("event_date", column_name)]
  colnames(data_prophet) <- c("ds", "y")
  data_prophet$ds <- as.Date(data_prophet$ds)
  
  # Create and fit Prophet model
  model <- prophet(
    data_prophet,
    yearly.seasonality = TRUE,
    daily.seasonality = FALSE
  )
  
  # Create future dataframe for 365 days
  future <- make_future_dataframe(model, periods = 365)
  
  # Make predictions
  forecast <- predict(model, future)
  
  # Combine original data with predictions
  combined_data <- merge(data_prophet, forecast, by = "ds", all = TRUE)
  
  # Export to Excel
  write.xlsx(combined_data, output_file, row.names = FALSE)
  
  return(combined_data)
}

# Function to create and display plot
create_plot <- function(combined_data, column_name, platform_name) {
  # Create subset for visualization (forecast period only)
  forecast_subset <- combined_data[
    combined_data$ds >= as.Date("2022-02-06") & 
      combined_data$ds <= as.Date("2023-02-05"), 
  ]
  
  # Set colors based on platform
  if (platform_name == "Apple") {
    line_color <- "red"
    ribbon_color <- "pink"
  } else {
    line_color <- "blue"
    ribbon_color <- "lightblue"
  }
  
  # Create and display visualization
  p <- ggplot(forecast_subset, aes(x = ds)) +
    geom_ribbon(aes(ymin = yhat_lower, ymax = yhat_upper), 
                fill = ribbon_color, alpha = 0.3) +
    geom_line(aes(y = yhat), color = line_color, size = 1) +
    scale_y_continuous(labels = scales::comma) +
    labs(y = column_name, x = "Date", 
         title = paste(platform_name, column_name, "Forecast")) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))
  
  print(p)
  return(p)
}

# Read data files
data_android <- read.csv("Android_365.csv", header = TRUE)
data_apple <- read.csv("Apple_365.csv", header = TRUE)

# Process Android data
cat("Processing Android DAU...\n")
android_dau <- process_forecast(data_android, "DAU", "Android_prophet_forecast_dau.xlsx")

cat("Processing Android Installs...\n") 
android_installs <- process_forecast(data_android, "installs", "Android_prophet_forecast_installs.xlsx")

cat("Processing Android IAP...\n")
android_iap <- process_forecast(data_android, "IAP", "Android_prophet_forecast_iap.xlsx")

# Process Apple data
cat("Processing Apple DAU...\n")
apple_dau <- process_forecast(data_apple, "DAU", "Apple_prophet_forecast_dau.xlsx")

cat("Processing Apple Installs...\n")
apple_installs <- process_forecast(data_apple, "installs", "Apple_prophet_forecast_installs.xlsx")

cat("Processing Apple IAP...\n")
apple_iap <- process_forecast(data_apple, "IAP", "Apple_prophet_forecast_iap.xlsx")

# Create and display plots for Android
cat("Creating Android plots...\n")
create_plot(android_dau, "DAU", "Android")
create_plot(android_installs, "Installs", "Android") 
create_plot(android_iap, "IAP", "Android")

# Create and display plots for Apple
cat("Creating Apple plots...\n")
create_plot(apple_dau, "DAU", "Apple")
create_plot(apple_installs, "Installs", "Apple")
create_plot(apple_iap, "IAP", "Apple")

cat("All processing complete!\n")
