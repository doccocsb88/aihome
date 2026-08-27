# Remote Config Quick Guide

Tài liệu này ghi nhanh các biến Remote Config đang dùng cho:

- ads
- API provider

Mục tiêu là để team có thể mở Firebase Remote Config và set giá trị đúng ngay, không phải lần lại code.

## 1. Ads Keys

### 1.1 Hai config chính

| Key | Type | Default trong app | Ý nghĩa |
|---|---|---:|---|
| `ads_info` | `String` | JSON mặc định | Bật/tắt từng nhóm ads và set `ads_id` cho từng nhóm |
| `ads_gate` | `String` | JSON mặc định | Điều khiển interval, paywall gate và placements |

### 1.2 `ads_info` JSON mẫu

```json
{
  "enabled": true,
  "placements": {
    "open_splash": {
      "enabled": true,
      "ads_id": "05a37b30d8cee5ff"
    },
    "open_resume": {
      "enabled": true,
      "ads_id": "ccb2f614ccdfd440"
    },
    "rewarded_generate": {
      "enabled": true,
      "ads_id": "d4c21fc7205f62a0"
    },
    "rewarded_regenerate": {
      "enabled": true,
      "ads_id": "a3a09e4d782ed80b"
    },
    "inter_close_edit": {
      "enabled": true,
      "ads_id": "2024866b95177a63"
    },
    "inter_close_iap": {
      "enabled": true,
      "ads_id": "cc3c5cb6f6a84a14"
    },
    "inter_close_result": {
      "enabled": true,
      "ads_id": "34a8c80d44b9af2d"
    },
    "banner_home": {
      "enabled": false,
      "ads_id": ""
    },
    "banner_result": {
      "enabled": false,
      "ads_id": ""
    }
  }
}
```

### 1.3 `ads_gate` JSON mẫu

```json
{
  "interval_seconds": 30,
  "paywall_dismiss_count_before_ads": 0,
  "placements": [
    "open_splash",
    "open_resume",
    "rewarded_generate",
    "rewarded_regenerate",
    "inter_close_edit",
    "inter_close_iap",
    "inter_close_result"
  ]
}
```

### Ghi chú nhanh

- `ads_info.enabled = false` thì toàn bộ ads dừng.
- Mỗi placement có `enabled` và `ads_id` riêng.
- Thiếu placement trong JSON thì app coi như placement đó tắt.
- `ads_gate.placements` là enum string, dùng để bật/tắt trigger theo placement.
- `paywall_dismiss_count_before_ads = 0` nghĩa là gate paywall coi như tắt.
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
   - `String` cho `ads_info` JSON
   - `String` cho `ads_gate` JSON
   - `String` cho provider kind
4. Publish cấu hình.
5. Không cần tạo từng key ads rời rạc nữa.

## 5. Khuyến nghị giá trị khởi đầu

- `ads_info = { ... JSON mẫu ở trên ... }`
- `ads_gate = { ... JSON mẫu ở trên ... }`
- `home_gpt_provider_kind = home_ai_backend`

## 6. Chỗ đọc trong code

- Ads config: [`/Users/haivu/Documents/hai/ai_home/AIHome/AIHome/Core/Utilities/RemoteConfigManager.swift`](../AIHome/AIHome/Core/Utilities/RemoteConfigManager.swift)
- Provider config: [`/Users/haivu/Documents/hai/ai_home/AIHome/AIHome/API/Services/HomeGPTProviderSupport.swift`](../AIHome/AIHome/API/Services/HomeGPTProviderSupport.swift)
- Backend constants: [`/Users/haivu/Documents/hai/ai_home/AIHome/AIHome/API/Core/APIConstants.swift`](../AIHome/AIHome/API/Core/APIConstants.swift)
