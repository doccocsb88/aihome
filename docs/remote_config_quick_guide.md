# Remote Config Quick Guide

Tài liệu này ghi nhanh các biến Remote Config đang dùng cho:

- ads
- API provider

Mục tiêu là để team có thể mở Firebase Remote Config và set giá trị đúng ngay, không phải lần lại code.

## 1. Ads Keys

### 1.1 Một key duy nhất

| Key | Type | Default trong app | Ý nghĩa |
|---|---|---:|---|
| `ads_placements` | `String` | JSON mặc định | Gom toàn bộ cấu hình ads vào một JSON |

### 1.2 JSON mẫu

```json
{
  "enabled": true,
  "open_splash_enabled": true,
  "open_resume_enabled": true,
  "rewarded_generate_enabled": true,
  "rewarded_regenerate_enabled": true,
  "inter_close_edit_enabled": true,
  "inter_close_iap_enabled": true,
  "inter_close_result_enabled": true,
  "ads_interval_seconds": 30,
  "paywall_dismiss_count_before_ads": 0
}
```

### Ghi chú nhanh

- Nếu `enabled = false`, toàn bộ ads sẽ dừng.
- Nếu `open_splash_enabled = false`, splash ad sẽ không load và không show.
- Nếu `paywall_dismiss_count_before_ads = 0`, gate paywall coi như tắt.
- Ads chỉ hiện cho free user theo logic hiện tại.

## 2. API Provider Keys

| Key | Type | Default trong app | Ý nghĩa |
|---|---|---:|---|
| `home_gpt_provider_kind` | `String` | `home_ai_backend` | Chọn provider mặc định cho app |

### Giá trị hợp lệ

- `home_ai_backend`
- `legacy_home_designs`

### Ghi chú nhanh

- Provider mặc định trong app hiện là `home_ai_backend`.
- Nếu Remote Config trả giá trị không hợp lệ, app sẽ fallback về giá trị đang dùng trong code.
- Nếu có local override bằng `UserDefaults`, local override sẽ được ưu tiên hơn Remote Config.

## 3. API Backend Config

Thông tin backend mới đã được đưa vào code iOS để dùng chung:

| Item | Value |
|---|---|
| Base URL | `https://aiart.billionx.co` |
| Auth header | `Authorization: Api-Key <key>` |
| Dev key | `mhj9xxGV.Thk4JCaeUriamUBn2iDSq184sCJrEIYM` |
| Env / Info.plist / UserDefaults key | `HOME_AI_BACKEND_API_KEY` |

## 4. Cách set trong Firebase

1. Vào Firebase Remote Config.
2. Tạo key theo đúng tên ở trên.
3. Chọn đúng type:
   - `String` cho `ads_placements` JSON
   - `String` cho provider kind
4. Publish cấu hình.
5. Không cần tạo từng key ads rời rạc nữa.

## 5. Khuyến nghị giá trị khởi đầu

- `ads_placements = { ... JSON mẫu ở trên ... }`
- `home_gpt_provider_kind = home_ai_backend`

## 6. Chỗ đọc trong code

- Ads config: [`/Users/haivu/Documents/hai/ai_home/AIHome/AIHome/Core/Utilities/RemoteConfigManager.swift`](../AIHome/AIHome/Core/Utilities/RemoteConfigManager.swift)
- Provider config: [`/Users/haivu/Documents/hai/ai_home/AIHome/AIHome/API/Services/HomeGPTProviderSupport.swift`](../AIHome/AIHome/API/Services/HomeGPTProviderSupport.swift)
- Backend constants: [`/Users/haivu/Documents/hai/ai_home/AIHome/AIHome/API/Core/APIConstants.swift`](../AIHome/AIHome/API/Core/APIConstants.swift)
