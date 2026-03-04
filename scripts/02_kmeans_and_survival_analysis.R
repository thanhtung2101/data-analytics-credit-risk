# Load required packages
library(dplyr)
library(ggplot2)
library(cluster)
library(survival)

# =========================================================
# 1. DATA PREPARATION
# =========================================================
df <- read.csv("C:/Users/LENOVO/Downloads/Project_Aurora/data_clean/master_transactions_mart.csv")

customer_profile <- df %>%
  select(current_age, debt_to_income_ratio, total_spent_by_client) %>%
  distinct() %>%
  filter(is.finite(debt_to_income_ratio)) %>%
  na.omit()

# =========================================================
# 2. K-MEANS CLUSTERING (RISK SEGMENTATION)
# =========================================================
features <- customer_profile %>% scale()

set.seed(123) 
kmeans_result <- kmeans(features, centers = 3, nstart = 25)
customer_profile$Risk_Cluster <- as.factor(kmeans_result$cluster)

# Risk Segmentation Visualization
ggplot(customer_profile, aes(x = debt_to_income_ratio, y = total_spent_by_client, color = Risk_Cluster)) +
  geom_point(alpha = 0.7, size = 3) +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Phân khúc Khách hàng Aurora Bank theo Mức độ Rủi ro",
       subtitle = "Đánh giá dựa trên Tỷ lệ Nợ/Thu nhập (DTI) và Tổng chi tiêu thẻ",
       x = "Tỷ lệ Nợ / Thu nhập (DTI)",
       y = "Tổng chi tiêu lũy kế ($)") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

# Export segment results
write.csv(customer_profile, "C:/Users/LENOVO/Downloads/customer_segments_export.csv", row.names = FALSE)

# =========================================================
# 3. SURVIVAL ANALYSIS (DEFAULT TIME PREDICTION)
# =========================================================

# Identify the highest risk cluster based on Mean DTI
cluster_summary <- customer_profile %>%
  group_by(Risk_Cluster) %>%
  summarise(Mean_DTI = mean(debt_to_income_ratio, na.rm = TRUE))

risky_cluster_id <- cluster_summary$Risk_Cluster[which.max(cluster_summary$Mean_DTI)]
risky_customers <- customer_profile %>% filter(Risk_Cluster == risky_cluster_id)

# Simulate Survival Event & Time based on actual DTI metrics
set.seed(42)
risky_customers <- risky_customers %>%
  mutate(
    DTI_Level = ifelse(debt_to_income_ratio > 1.8, "Cực kỳ rủi ro (> 1.8)", "Rủi ro cao (<= 1.8)"),
    Prob_Default = pmin(debt_to_income_ratio / 3, 0.9), 
    Event = rbinom(n(), 1, Prob_Default),
    Time = ifelse(Event == 1, 
                  round(rexp(n(), rate = debt_to_income_ratio/2) + 1), 
                  sample(10:12, n(), replace = TRUE)) 
  )

# Kaplan-Meier Estimation
surv_object <- Surv(time = risky_customers$Time, event = risky_customers$Event)
km_fit <- survfit(surv_object ~ DTI_Level, data = risky_customers)

# Export Survival Plot
png("Survival_Analysis_BaseR.png", width = 850, height = 600, res = 120)

plot(km_fit, 
     col = c("#800000", "#E74C3C"), 
     lty = 1:2,                     
     lwd = 3,                       
     main = "Dự báo Thời điểm Vỡ nợ (Survival Analysis)",
     xlab = "Thời gian theo dõi (Tháng)", 
     ylab = "Xác suất chưa vỡ nợ (Survival Probability)")

legend("topright", 
       title = "Mức độ DTI:",
       legend = c("Cực kỳ rủi ro (> 1.8)", "Rủi ro cao (<= 1.8)"), 
       col = c("#800000", "#E74C3C"), 
       lty = 1:2, 
       lwd = 3,
       bty = "n")

abline(v = 3, col = "purple", lty = 3, lwd = 2)
text(x = 3.2, y = 0.5, labels = "Tháng thứ 3:\nCần gọi nhắc nợ sớm!", col = "purple", pos = 4, font = 2)

dev.off()