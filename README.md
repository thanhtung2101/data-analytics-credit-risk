# 🏦 Aurora Bank: Credit Risk Segmentation & Early Warning System

**Author:** Trần Lê Thanh Tùng  
**Domain:** Retail Banking, Credit Risk Management, Debt Collection  
**Methodology:** Statistical Modeling, Machine Learning, Survival Analysis  
**Tools:** SQL, R (dplyr, cluster, survival)

---

## 📌 1. Project Overview (Tổng quan Dự án)
Trong bối cảnh tỷ lệ nợ xấu (NPL - Non-Performing Loans) tại các ngân hàng thương mại bán lẻ có xu hướng gia tăng, việc quản trị rủi ro dựa trên các báo cáo thống kê trong quá khứ chưa đáp ứng được yêu cầu cảnh báo kịp thời. Mục tiêu của dự án là xây dựng một hệ thống phân tích chủ động nhằm nhận diện sớm nhóm khách hàng có rủi ro tín dụng cao và **dự báo thời điểm phát sinh nợ xấu** để đưa ra các biện pháp can thiệp tối ưu.

Dự án ứng dụng các mô hình Thống kê và Học máy chuyên sâu trên ngôn ngữ R để giải quyết bài toán cốt lõi: *"Phân nhóm tập khách hàng rủi ro và ước lượng thời gian duy trì khả năng thanh toán của từng nhóm khách hàng."*

---

## 🗄️ 2. Data Architecture & Data Source (Cấu trúc & Nguồn Dữ liệu)
Dự án sử dụng bộ cơ sở dữ liệu quan hệ mô phỏng hoạt động phát hành thẻ và giao dịch của Aurora Bank, bao gồm 4 bảng dữ liệu thô với hàng triệu dòng lịch sử giao dịch.

### 2.1. Lược đồ Dữ liệu 
- 👤 **`users_data` (Thông tin Khách hàng):** Bảng dữ liệu định danh và năng lực tài chính. Chứa các trường quan trọng như `current_age` (Độ tuổi), `yearly_income` (Thu nhập hàng năm), `total_debt` (Tổng dư nợ), và `credit_score` (Điểm tín dụng).
- 💳 **`cards_data` (Thông tin Thẻ tín dụng):** Bảng dữ liệu quản lý vòng đời thẻ. Liên kết với `users_data` qua `client_id`.
- 🛒 **`transactions_data` (Lịch sử Giao dịch):** Bảng dữ liệu ghi nhận từng biến động tài chính. Bao gồm `amount` (Giá trị giao dịch), `date` (Thời gian), và `mcc` (Mã nhóm ngành). Liên kết với thẻ và khách hàng qua `card_id` và `client_id`.
- 🏬 **`mcc_codes` (Từ điển Nhóm ngành):** Bảng mã `mcc_id` sang `Description` (Mô tả chi tiết loại hình kinh doanh).

### 2.2. Biến đổi Dữ liệu
Từ 4 bảng trên, tôi đã thực hiện SQL để làm sạch (Data Cleansing), kết nối (JOIN) và tổng hợp dữ liệu từ mức độ giao dịch (Transaction-level) lên mức độ khách hàng (Customer-level). Kết quả đầu ra là Data Mart cuối cùng (`master_transactions_mart.csv`) với các biến cốt lõi mang tính chất quyết định:
- **`debt_to_income_ratio` (DTI):** Tỷ lệ Nợ trên Thu nhập. Biến quan sát cốt lõi để đánh giá áp lực trả nợ của khách hàng.
- **`total_spent_by_client`:** Tổng doanh số giao dịch tích lũy, dùng để đánh giá mức độ hoạt động.

---

## 🛠️ 3. Quy trình Phân tích
1. **Data Processing (SQL & R):** Tiền xử lý tập `master_transactions_mart.csv` và loại bỏ các giá trị dị biệt (Outliers/Missing values).
2. **Risk Segmentation:** Ứng dụng thuật toán phân cụm **K-Means Clustering** để tự động phân nhóm khách hàng dựa trên hành vi chi tiêu và năng lực tài chính (DTI).
3. **Default Time Prediction:** Ứng dụng mô hình Phân tích Sinh tồn **Kaplan-Meier (Survival Analysis)** lên nhóm khách hàng rủi ro nhằm đo lường xác suất duy trì khả năng thanh toán theo thời gian, phục vụ chiến lược thu hồi nợ.

---

## 📈 4. Kết quả Phân tích & Đề xuất Chiến lược (Business Impact)

### 4.1. Phân khúc Khách hàng & Chiến lược Kinh doanh (K-Means Clustering)
Thuật toán K-Means đã phân tích hành vi và tự động chia tập dữ liệu khách hàng của Aurora Bank thành 3 phân khúc đặc trưng. Dựa trên kết quả này, tôi đề xuất các chiến lược với từng nhóm đối tượng:


<img width="1000" height="528" alt="image" src="https://github.com/user-attachments/assets/4a45b86e-d2df-4438-91dd-1c6768dbe641" />


**🟢 Phân khúc 3 - Safe / Low Activity (Nhóm An toàn / Ít giao dịch)**
- **Đặc điểm:** Tỷ lệ DTI và mức độ chi tiêu đều ở mức rất thấp. Rủi ro tín dụng gần như bằng 0 nhưng chưa tạo ra nhiều lợi nhuận.
- **Chiến lược (Marketing & Cross-selling):** - *Kích cầu chi tiêu:* Triển khai các chiến dịch Marketing mục tiêu (Targeted Marketing) như hoàn tiền (Cashback) để tạo thói quen sử dụng thẻ.
  - *Bán chéo sản phẩm:* Tận dụng dư địa tín dụng (Credit Capacity) lớn để chào bán các gói vay tiêu dùng với lãi suất ưu đãi.

**🟠 Phân khúc 2 - VIP Spenders (Nhóm Khách hàng Trọng điểm)**
- **Đặc điểm:** Tần suất và mức độ chi tiêu cực kỳ cao (đóng góp phần lớn doanh thu phí) nhưng tỷ lệ DTI vẫn duy trì ở ngưỡng an toàn. Đây là tệp khách hàng mang lại biên lợi nhuận cao nhất.
- **Chiến lược (Retention & LTV Maximization):** - *Tối ưu giá trị vòng đời (LTV):* Cấp trước (Pre-approve) các hạn mức tín dụng tự động cao hơn để kích thích mua sắm.
  - *Chính sách giữ chân:* Nâng hạng thẻ lên các dòng cao cấp (Platinum/Signature) đi kèm các đặc quyền Loyalty nhằm ngăn chặn rủi ro rời bỏ (Churn).

**🔴 Phân khúc 1 - Risky Borrowers (Nhóm Rủi ro Cao - Trọng tâm giám sát)**
- **Đặc điểm:** Hành vi chi tiêu lớn nhưng thu nhập không đủ đáp ứng. Thuật toán phân lập được 162 khách hàng thuộc phân khúc này với **chỉ số DTI trung bình đạt 1.88** (Dư nợ cao gần gấp đôi thu nhập). Đây là nhóm có khả năng chuyển hoán thành nợ xấu cao nhất.
- **Chiến lược (Risk Mitigation & Collection):** - *Kiểm soát rủi ro:* Đóng băng tính năng xin tăng hạn mức và thắt chặt các điều kiện giải ngân mới.
  - *Chuyển tiếp phân tích:* Đưa toàn bộ danh sách khách hàng này vào mô hình Phân tích Sinh tồn (Survival Analysis) để đo lường chính xác thời điểm cạn kiệt dòng tiền.

---

### 4.2. Dự báo Thời điểm Vỡ nợ (Survival Analysis)
Để tối ưu hóa nghiệp vụ thu hồi nợ, nhóm "Risky Borrowers" tiếp tục được đưa vào mô hình Phân tích Sinh tồn nhằm đo lường thời gian chịu đựng áp lực tài chính của họ.


<img width="850" height="600" alt="Survival_Analysis_BaseR" src="https://github.com/user-attachments/assets/2ad87294-8e81-47d2-a7c3-ee2a81ccdcfb" />


**📖 Giải thích biểu đồ:**
- **Trục hoành (X - Thời gian):** Thời gian (tính bằng tháng) kể từ thời điểm hệ thống ghi nhận chỉ số DTI của khách hàng vượt ngưỡng an toàn.
- **Trục tung (Y - Xác suất duy trì khả năng thanh toán):** Tỷ lệ phần trăm khách hàng chưa phát sinh nợ quá hạn. Tại thời điểm tháng thứ 0, xác suất mặc định là 1.0 (100%).
- **Đường cong sinh tồn:** Tốc độ suy giảm năng lực trả nợ. Độ dốc của đường cong càng lớn, tỷ lệ rơi vào trạng thái vỡ nợ diễn ra càng nhanh.

**💡 Đề xuất Chiến lược Thu hồi nợ (Actionable Insights):**
1. **Tốc độ chuyển hoán nợ xấu:** Tập khách hàng rủi ro được chia thành 2 cấp độ. Đối với nhóm có **DTI > 1.8** (đường màu đỏ thẫm), biểu đồ cho thấy năng lực thanh toán suy giảm với tốc độ rất gắt (rơi tự do).
2. **Thời điểm can thiệp tối ưu:** Tại mốc **Tháng thứ 3** (đường gióng màu tím), xác suất duy trì khả năng trả nợ của nhóm rủi ro cao giảm xuống dưới mức 50%. Điều này đồng nghĩa với việc hơn một nửa số khách hàng trong nhóm sẽ chính thức phát sinh nợ xấu sau 90 ngày.
3. **Giải pháp thực thi:** Khuyến nghị Khối Quản trị Rủi ro không áp dụng quy trình thu hồi nợ truyền thống (chờ khách hàng quá hạn 90 ngày mới tiến hành xử lý). Thay vào đó, cần thiết lập quy trình **Nhắc nợ sớm (Early Collection)** và xem xét cơ cấu lại thời hạn trả nợ ngay từ **đầu tháng thứ 2 hoặc tháng thứ 3**. Việc can thiệp sớm tại mốc thời gian này sẽ giúp ngân hàng giảm thiểu tối đa rủi ro tổn thất vốn.

---

## 📂 5. Repository Structure (Cấu trúc Thư mục)
- `data_bank/` : Chứa tập dữ liệu của ngân hàng.
- `data_clean/` : Chứa tập dữ liệu đã qua xử lý (`master_transactions_mart.csv`) và dữ liệu phân nhóm xuất ra.
- `scripts/` : Chứa mã nguồn phân tích định lượng.
- `README.md` : Báo cáo chi tiết về phương pháp, kết quả phân tích và đề xuất kinh doanh.

---
