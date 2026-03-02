/* =========================================================================================
PROJECT: RETAIL BANKING PORTFOLIO - CREDIT RISK & TRANSACTION ANALYSIS
AUTHOR: Trần Lê Thanh Tùng
OBJECTIVE: 
Thiết kế Data Mart (master_transactions_mart) bằng cách tổng hợp và làm sạch dữ liệu 
từ 4 bảng (Users, Cards, Transactions, MCC Codes). 
Bảng kết quả này sẽ đóng vai trò là SSOT (Single Source of Truth) để phục vụ cho:
1. Trực quan hóa báo cáo rủi ro trên Power BI.
2. Chạy thuật toán phân cụm khách hàng (Clustering) trên R.
========================================================================================= */

CREATE OR REPLACE TABLE `portfolio-488509.aurora_bank_project1.master_transactions_mart` AS

-- =========================================================================================
-- CTE 1: CLEAN USERS (Làm sạch và tạo biến Rủi ro Khách hàng)
-- Nghiệp vụ: Tính toán DTI và Phân loại rủi ro dựa trên điểm tín dụng.
-- =========================================================================================
WITH Cleaned_Users AS (
    SELECT 
        id AS client_id,
        current_age,
        gender,
        credit_score,
        num_credit_cards,
        
        -- Tính toán DTI (Debt-to-Income Ratio)
        -- FIXED: Ép kiểu an toàn (Safe Cast) sang STRING trước khi REPLACE để chống lỗi Auto-detect của hệ thống
        ROUND(
            CAST(REPLACE(CAST(total_debt AS STRING), '$', '') AS FLOAT64) / 
            NULLIF(CAST(REPLACE(CAST(yearly_income AS STRING), '$', '') AS FLOAT64), 0), 
        4) AS debt_to_income_ratio,

        -- Gắn nhãn phân loại rủi ro dựa trên Credit Score
        CASE 
            WHEN credit_score < 580 THEN 'High Risk (Poor)'
            WHEN credit_score BETWEEN 580 AND 669 THEN 'Medium Risk (Fair)'
            WHEN credit_score BETWEEN 670 AND 739 THEN 'Low Risk (Good)'
            WHEN credit_score >= 740 THEN 'Very Low Risk (Excellent)'
            ELSE 'Unknown'
        END AS risk_tier
    FROM `portfolio-488509.aurora_bank_project1.users`
),

-- =========================================================================================
-- CTE 2: CLEAN TRANSACTIONS (Chuẩn hóa dữ liệu thô của giao dịch)
-- Nghiệp vụ: Đảm bảo tính toàn vẹn của dữ liệu tài chính trước khi tính toán.
-- =========================================================================================
Cleaned_Transactions AS (
    SELECT 
        id AS transaction_id,
        client_id,
        card_id,
        
        -- Chuyển đổi chuỗi ngày tháng sang chuẩn TIMESTAMP 
        CAST(date AS TIMESTAMP) AS transaction_timestamp,
        
        -- SAFE CAST: Loại bỏ ký tự '$' và ép kiểu về FLOAT64 để tính toán doanh số
        CAST(REPLACE(CAST(amount AS STRING), '$', '') AS FLOAT64) AS amount_clean,
        
        use_chip,
        mcc,
        errors
    FROM `portfolio-488509.aurora_bank_project1.transactions` 
),

-- =========================================================================================
-- CTE 3: FEATURE ENGINEERING & WINDOW FUNCTIONS (Tạo biến mới & Phân tích hành vi)
-- Nghiệp vụ: Tính toán thói quen chi tiêu của khách hàng mà không làm mất chi tiết từng giao dịch.
-- =========================================================================================
Transaction_Metrics AS (
    SELECT 
        *,
        -- 1. Tính tổng chi tiêu lũy kế của từng khách hàng (Total Spend)
        SUM(amount_clean) OVER(PARTITION BY client_id) AS total_spent_by_client,
        
        -- 2. Xếp hạng giao dịch theo giá trị (Transaction Rank)
        RANK() OVER(PARTITION BY client_id ORDER BY amount_clean DESC) AS transaction_rank_amount
        
    FROM Cleaned_Transactions
    -- Chỉ ghi nhận các giao dịch thành công vào doanh số thẻ 
    WHERE errors IS NULL OR errors = '' 
)

-- =========================================================================================
-- MAIN QUERY: COMPLEX JOINS (Kết nối Data Model)
-- Nghiệp vụ: Ghép nối lịch sử giao dịch với thông tin thẻ, định danh khách hàng và loại hình chi tiêu.
-- =========================================================================================
SELECT 
    -- Chi tiết giao dịch
    t.transaction_id,
    t.transaction_timestamp,
    t.amount_clean,
    t.use_chip,
    t.total_spent_by_client,
    t.transaction_rank_amount,
    
    -- Chi tiết rủi ro khách hàng 
    u.current_age,
    u.gender,
    u.risk_tier,
    u.debt_to_income_ratio,
    
    -- Chi tiết thẻ
    c.card_brand,
    c.card_type,
    
    -- Danh mục chi tiêu (Merchant Category)
    m.Description AS merchant_category

FROM Transaction_Metrics t

-- SỬ DỤNG BẢNG CLEANED_USERS VỪA TẠO
JOIN Cleaned_Users u 
    ON t.client_id = u.client_id

JOIN `portfolio-488509.aurora_bank_project1.cards` c 
    ON t.card_id = c.id
    
-- Sử dụng LEFT JOIN cho MCC Code
LEFT JOIN `portfolio-488509.aurora_bank_project1.mcc_codes` m 
    ON t.mcc = m.mcc_id;