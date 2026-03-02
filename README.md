# 🏦 Aurora Bank: Credit Risk Early Warning & Customer Segmentation System

**Author:** Trần Lê Thanh Tùng  
**Domain:** Retail Banking, Credit Risk Management, Debt Collection Analytics  
**Tools Used:** SQL, R (Machine Learning), Power BI, Excel  

---

## 📌 1. Project Overview (Tổng quan Dự án)
Trong bối cảnh kinh tế vĩ mô biến động, tỷ lệ nợ xấu (NPL - Non-Performing Loans) tại các ngân hàng bán lẻ đang có xu hướng gia tăng. Việc nhận diện sớm các khách hàng mất khả năng thanh toán không chỉ giúp giảm thiểu rủi ro tài chính mà còn tối ưu hóa chi phí cho bộ phận Thu hồi nợ (Debt Collection).

Dự án này sử dụng tập dữ liệu giao dịch thẻ tín dụng giả định của **Aurora Bank** để xây dựng một luồng dữ liệu (Data Pipeline) hoàn chỉnh từ khâu trích xuất, phân cụm hành vi bằng Machine Learning (Thuật toán K-Means), cho đến việc thiết kế một **Interactive Dashboard** cảnh báo rủi ro tự động.

**Mục tiêu cốt lõi:**
- Phân tích và đo lường **Tỷ lệ Nợ trên Thu nhập (DTI - Debt-to-Income Ratio)** của từng tệp khách hàng.
- Xây dựng hệ thống cảnh báo sớm (Early Warning System) nhận diện nhóm "Risky Borrowers" có nguy cơ vỡ nợ cao.
- Cung cấp Insights trực quan hỗ trợ Hội đồng tín dụng ra quyết định cấp/ngừng cấp hạn mức và định hướng chiến lược thu hồi nợ.

---

## 🛠️ 2. Methodology & Workflow (Quy trình Thực hiện)

### Bước 1: Data Processing & Feature Engineering (Xử lý dữ liệu)
- **Công cụ:** SQL & Excel.
- **Thao tác:** Làm sạch dữ liệu giao dịch thô (Raw transactions), xử lý giá trị null/outliers. Tổng hợp dữ liệu từ mức độ giao dịch (transaction-level) lên mức độ khách hàng (customer-level).
- **Chỉ số trọng tâm:** Tính toán độ tuổi (`current_age`), tổng doanh số chi tiêu (`total_spent`), tần suất giao dịch, và quan trọng nhất là `debt_to_income_ratio` (DTI).

### Bước 2: Customer Segmentation (Phân cụm Khách hàng)
- **Công cụ:** Ngôn ngữ R (Thư viện `dplyr`, `stats`, `ggplot2`).
- **Thao tác:** Chuẩn hóa dữ liệu (Z-score scaling) và ứng dụng thuật toán học máy không giám sát **K-Means Clustering**.
- **Kết quả:** Phân tách thành công toàn bộ tập khách hàng thành 3 cụm (clusters) mang đặc tính rủi ro riêng biệt.

### Bước 3: Data Visualization & Dashboarding (Trực quan hóa)
- **Công cụ:** Power BI.
- **Thao tác:** - Thiết kế bố cục UI/UX chuẩn báo cáo tài chính (Z-Pattern Layout).
  - Sử dụng hệ màu cảnh báo (Đỏ: Rủi ro cao, Xanh Navy: An toàn).
  - Tích hợp các KPIs, biểu đồ tương tác (Clustered Bar Chart, Donut Chart) và Ma trận dữ liệu (Matrix) để theo dõi luồng rủi ro.

---

## 💡 3. Key Business Insights & Strategic Recommendations (Phân tích & Đề xuất)

Hệ thống phân loại khách hàng thành 3 nhóm chính. Dưới đây là chân dung và chiến lược đề xuất cho từng nhóm:

### 🔴 Cluster 1: Risky Borrowers (Nhóm Báo động đỏ - Nguy cơ vỡ nợ cao)
* **Chân dung:** Chiếm số lượng đông đảo nhất (162 khách hàng). Điểm đáng lo ngại nhất là mức **DTI trung bình lên tới 1.88** (khoản nợ hiện tại cao gần gấp đôi thu nhập bình quân), trong khi độ tuổi còn khá trẻ (~45 tuổi).
* **Đề xuất chiến lược (Risk & Collection):** - Đưa ngay vào **Watchlist** (Danh sách theo dõi đặc biệt).
  - Thiết lập cơ chế phong tỏa/khóa thẻ tự động (Auto-block) nếu phát sinh chi tiêu vượt quá 80% hạn mức.
  - Tuyệt đối không chào bán (cross-sell) thêm các sản phẩm vay tiêu dùng.
  - Bộ phận Thu hồi nợ cần ưu tiên tiếp cận sớm (Early Collection) với nhóm này để cơ cấu lại thời hạn trả nợ.

### 🟠 Cluster 2: VIP Spenders 
* **Chân dung:** Chỉ gồm 47 khách hàng (nhóm thiểu số) nhưng mang lại tỷ trọng doanh thu quẹt thẻ lớn nhất. Tỷ lệ DTI ở mức cực kỳ an toàn (~0.93).
* **Đề xuất chiến lược (Growth & Retention):**
  - Cấp thẻ tín dụng phân hạng cao cấp (Signature/Black Card) với hạn mức tối đa.
  - Tích hợp các đặc quyền VIP (Phòng chờ sân bay, hoàn tiền % cao) để tăng lòng trung thành và kích thích họ duy trì Aurora Bank làm ngân hàng giao dịch chính (Main Bank).

### 🟢 Cluster 3: Low Activity 
* **Chân dung:** Khách hàng lớn tuổi (trung bình ~66 tuổi), chỉ số an toàn tài chính cực cao (DTI rất thấp, chỉ 0.41) nhưng lại ít phát sinh giao dịch.
* **Đề xuất chiến lược (Marketing):**
  - Chạy các chiến dịch Targeted Marketing đánh vào nhu cầu thiết yếu của người lớn tuổi (Hoàn tiền khi thanh toán bảo hiểm y tế, mua sắm siêu thị, nhà thuốc).
  - Đơn giản hóa quy trình thanh toán qua App để khuyến khích nhóm này sử dụng thẻ thay vì tiền mặt.

---

## 🖥️ 4. Dashboard Showcase
<img width="1210" height="680" alt="image" src="https://github.com/user-attachments/assets/f647f5e5-0269-4ba4-8ac8-b8dca23b6ee0" />




---

## 🚀 5. Repository Structure (Cấu trúc Thư mục)
- `data/` : Chứa file CSV dữ liệu thô và dữ liệu đã qua xử lý (`master_transactions_mart.csv`).
- `scripts/` : Chứa mã nguồn R (`clustering_kmeans.R`) dùng để phân cụm khách hàng.
- `dashboard/` : Chứa file báo cáo Power BI (`Aurora_Risk_Dashboard.pbix`) và file PDF xuất ra.

---
