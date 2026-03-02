library(dplyr)
library(ggplot2)
library(cluster)

# 1. Đọc dữ liệu
df <- read.csv("C:/Users/LENOVO/Downloads/master_transactions_mart.csv")

# 2. Làm sạch và trích xuất dữ liệu khách hàng duy nhất
customer_profile <- df %>%
  select(current_age, debt_to_income_ratio, total_spent_by_client) %>%
  distinct() %>%
  filter(is.finite(debt_to_income_ratio)) %>%
  na.omit()

# 3. Chuẩn hóa dữ liệu (Scaling)
features <- customer_profile %>% 
  scale()

# 4. Phân cụm bằng thuật toán K-Means (k=3)
set.seed(123) 
kmeans_result <- kmeans(features, centers = 3, nstart = 25)

# 5. Gán nhãn phân cụm vào tập dữ liệu gốc
customer_profile$Risk_Cluster <- as.factor(kmeans_result$cluster)

# 6. Trực quan hóa kết quả phân cụm (Scatter Plot)
ggplot(customer_profile, aes(x = debt_to_income_ratio, y = total_spent_by_client, color = Risk_Cluster)) +
  geom_point(alpha = 0.7, size = 3) +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Phân khúc Khách hàng Aurora Bank theo Mức độ Rủi ro",
       subtitle = "Đánh giá dựa trên Tỷ lệ Nợ/Thu nhập (DTI) và Tổng chi tiêu thẻ",
       x = "Tỷ lệ Nợ / Thu nhập (DTI)",
       y = "Tổng chi tiêu lũy kế ($)") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

# 7. Xuất file kết quả
write.csv(customer_profile, "C:/Users/LENOVO/Downloads/customer_segments_export.csv", row.names = FALSE)