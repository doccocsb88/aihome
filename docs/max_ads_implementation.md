# MAX Ads Implementation - Technical Notes

> Branch: `feature/ads`
>
> Scope: setup AppLovin MAX for AI Home and wire all ad triggers requested in the screenshot.
>
> Audience: engineers maintaining the iOS app.

## 1. Mục tiêu

Tài liệu này mô tả cách tích hợp AppLovin MAX vào ứng dụng iOS hiện tại và cách gắn các điểm trigger ads theo yêu cầu:

- App Open cho splash lần đầu và khi app resume từ background
- Rewarded cho `Generate` và `Re-generate`
- Interstitial cho các luồng đóng màn hình:
  - đóng luồng edit để về Home
  - đóng màn IAP / Sub
  - đóng màn Result để về Home

Mục tiêu của implementation:

- khởi tạo MAX sớm khi app launch
- preload từng ad slot riêng biệt
- bật / tắt theo remote config
- chỉ show ads với free user
- hạn chế spam bằng state guard cho app open / fullscreen ads

---

## 2. Nguồn cấu hình

Các cấu hình ad được lấy từ screenshot người dùng cung cấp.

### 2.1 SDK Key

```text
J2ks4TF6rLetzM0TgPvggyqLiCRTUJ1afPHWi0la24rZnZOul9gyfkD4JtAmbcua43fHqHHBzV20zrbR6Ilz5G
```

### 2.2 Ad Unit Mapping

| Ad unit | Format | MAX Ad Unit ID | Mô tả |
|---|---|---|---|
| `open_splash` | App open | `05a37b30d8cee5ff` | Show splash khi user mở app lần đầu hoặc session mới |
| `open_resume` | App open | `ccb2f614ccdfd440` | Show splash khi user mở app từ background |
| `rewarded_generate` | Rewarded | `d4c21fc7205f62a0` | Show khi user bấm Generate |
| `rewarded_regenerate` | Rewarded | `a3a09e4d782ed80b` | Show khi user bấm Re-generate |
| `inter_close_edit` | Interstitial | `2024866b95177a63` | Show khi user close/back về Home ở luồng edit/choose |
| `inter_close_iap` | Interstitial | `cc3c5cb6f6a84a14` | Show khi user close màn IAP/Sub |
| `inter_close_result` | Interstitial | `34a8c80d44b9af2d` | Show khi user close màn Result về Home |

---

## 3. Kiến trúc tổng quan

Tích hợp MAX được gom vào một singleton:

- `AdsManager.shared`

Vai trò của `AdsManager`:

- initialize MAX SDK
- giữ cache cho từng ad instance
- preload ads
- show ads theo từng slot
- nhận delegate callback của MAX
- xử lý retry load khi fail
- bảo vệ state để tránh show chồng fullscreen ads

### 3.1 Các loại ad object dùng trong code

- `MAAppOpenAd`
- `MARewardedAd`
- `MAInterstitialAd`

### 3.2 Quy tắc gating

Ad chỉ được chạy khi đồng thời thỏa:

- remote config global `max_enable = true`
- remote config cho slot đó = `true`
- user là free user

Nếu bất kỳ điều kiện nào fail, action tiếp tục ngay mà không show ad.

---

## 4. Luồng khởi tạo MAX

### 4.1 App launch

MAX được initialize sớm trong app lifecycle:

- file: [`AIHomeApp.swift`](../AIHome/AIHome/AIHomeApp.swift)
- vị trí: `AppDelegate.application(_:didFinishLaunchingWithOptions:)`

Luồng:

1. `AdsManager.shared.configureIfNeeded()`
2. MAX SDK initialize bằng SDK key
3. Sau khi initialize xong, manager preload toàn bộ ad slots
4. Remote config điều khiển việc load/show ở runtime

### 4.2 Cấu hình SDK

Trong `AdsManager`:

- `ALSdkInitializationConfiguration.configuration(withSdkKey: ...)`
- `builder.mediationProvider = ALMediationProviderMAX`

Sau khi initialize thành công:

- gọi `prepareAds()`
- tạo các ad object
- gọi `loadAllAds()`

---

## 5. Remote Config

Để kiểm soát từng slot, `RemoteConfigManager` được mở rộng thêm các key sau:

### 5.1 Global key

- `max_enable`

### 5.2 Slot keys

- `max_open_splash_enable`
- `max_open_resume_enable`
- `max_rewarded_generate_enable`
- `max_rewarded_regenerate_enable`
- `max_inter_close_edit_enable`
- `max_inter_close_iap_enable`
- `max_inter_close_result_enable`
- `max_ads_interval_seconds`

### 5.3 Default value

Tất cả mặc định là `true`.

Riêng khoảng cách giữa các lần show ad:

- `max_ads_interval_seconds` mặc định là `30`

Ý nghĩa:

- nếu chưa fetch remote config, app vẫn có thể chạy ads theo default
- backend có thể tắt nhanh từng slot mà không cần update app

### 5.4 Analytics sync

Các giá trị remote config được sync sang analytics property:

- `rc_max_enable`
- `rc_max_open_splash_enable`
- `rc_max_open_resume_enable`
- `rc_max_rewarded_generate_enable`
- `rc_max_rewarded_regenerate_enable`
- `rc_max_inter_close_edit_enable`
- `rc_max_inter_close_iap_enable`
- `rc_max_inter_close_result_enable`
- `rc_max_ads_interval_seconds`

---

## 6. Trigger points đã gắn

### 6.1 App Open: Splash

File:

- [`SplashView.swift`](../AIHome/AIHome/Features/Splash/SplashView.swift)

Behavior:

- sau khi remote config load xong
- trước khi push route tiếp theo
- gọi `AdsManager.shared.showAppOpenSplashIfReady { ... }`

Mục đích:

- show app open cho session mới / cold start
- chỉ tiếp tục navigation sau khi ad đóng hoặc không có ad sẵn

### 6.2 App Open: Resume

File:

- [`AppCoordinatorView.swift`](../AIHome/AIHome/App/AppCoordinatorView.swift)

Behavior:

- observe `scenePhase`
- khi app chuyển sang `.active`, gọi `AdsManager.shared.handleScenePhaseChange(phase)`

Trong `AdsManager`:

- bỏ qua lần active đầu tiên nếu đó là cold start
- chỉ show resume ad từ background sau khi cold start đã hoàn tất
- state `hasShownResumeThisForeground` ngăn show nhiều lần trong cùng foreground session

### 6.3 Rewarded: Generate

Các container flow được bọc quanh action generate:

- `InteriorFlowContainerView.swift`
- `ExteriorFlowContainerView.swift`
- `GardenFlowContainerView.swift`
- `ReferenceStyleFlowContainerView.swift`
- `RemoveObjectsFlowContainerView.swift`
- `ReplaceObjectsFlowContainerView.swift`
- `NewFlooringFlowContainerView.swift`
- `NewWallsFlowContainerView.swift`

Behavior:

- trước khi start generation thật
- gọi `AdsManager.shared.showRewardedGenerateIfNeeded { startGeneration(...) }`

### 6.4 Rewarded: Re-generate

Cùng các flow container bên trên và `HistoryView.swift`.

Behavior:

- khi user bấm re-generate trên result screen hoặc history result presentation
- gọi `AdsManager.shared.showRewardedRegenerateIfNeeded { ... }`

### 6.5 Interstitial: Close Edit

Files:

- [`InteriorFlowView.swift`](../AIHome/AIHome/Features/InteriorFlow/InteriorFlowView.swift)
- [`ExteriorFlowView.swift`](../AIHome/AIHome/Features/ExteriorFlow/ExteriorFlowView.swift)
- [`GardenFlowView.swift`](../AIHome/AIHome/Features/GardenFlow/GardenFlowView.swift)
- [`ReferenceStyleFlowView.swift`](../AIHome/AIHome/Features/ReferenceStyleFlow/ReferenceStyleFlowView.swift)
- [`RemoveObjectsFlowView.swift`](../AIHome/AIHome/Features/RemoveObjectsFlow/RemoveObjectsFlowView.swift)
- [`ReplaceObjectsFlowView.swift`](../AIHome/AIHome/Features/ReplaceObjectsFlow/ReplaceObjectsFlowView.swift)
- [`NewFlooringFlowView.swift`](../AIHome/AIHome/Features/NewFlooringFlow/NewFlooringFlowView.swift)
- [`NewWallsFlowView.swift`](../AIHome/AIHome/Features/NewWallsFlow/NewWallsFlowView.swift)

Behavior:

- khi user bấm back / dismiss để về Home
- gọi `AdsManager.shared.showInterstitialCloseEdit { dismiss() }`

### 6.6 Interstitial: Close IAP / Sub

Files:

- [`MainTabHeaderView.swift`](../AIHome/AIHome/Features/Common/MainTabHeaderView.swift)
- [`ResultView.swift`](../AIHome/AIHome/Features/Result/ResultView.swift)
- [`OnboardingIntroPagerView.swift`](../AIHome/AIHome/Features/Onboarding/OnboardingIntroPagerView.swift)

Behavior:

- khi user đóng paywall/subscription flow
- gọi `AdsManager.shared.showInterstitialCloseIap { ... }`

### 6.7 Interstitial: Close Result

Files:

- [`ResultView.swift`](../AIHome/AIHome/Features/Result/ResultView.swift)
- [`HistoryView.swift`](../AIHome/AIHome/Features/History/HistoryView.swift)
- các `*FlowContainerView.swift` ở result screen

Behavior:

- khi user đóng result để quay về Home
- gọi `AdsManager.shared.showInterstitialCloseResult { ... }`

---

## 7. Luồng chạy chi tiết

### 7.1 Cold start

1. App launch
2. `AdsManager.configureIfNeeded()`
3. MAX initialize
4. load remote config
5. splash request next route
6. show app open splash nếu slot sẵn sàng
7. ad đóng xong thì push route tiếp theo

### 7.2 Resume từ background

1. app trở lại `.active`
2. coordinator báo scene phase cho `AdsManager`
3. nếu không phải cold start và chưa show app open trong foreground này
4. show `open_resume`

### 7.3 Generate flow

1. user bấm `Generate`
2. app gọi rewarded `rewarded_generate`
3. nếu ad show thành công hoặc không có ad sẵn, action generate chạy tiếp
4. generation logic gốc không bị thay đổi

### 7.4 Re-generate flow

1. user bấm `Re-generate`
2. app gọi rewarded `rewarded_regenerate`
3. sau ad đóng thì quay lại input / generate lại

### 7.5 Close edit / result / iap

1. user bấm close/back
2. app gọi interstitial tương ứng
3. sau ad đóng thì thực hiện dismiss / pop / completion

---

## 8. Ad Manager internals

### 8.1 Slot abstraction

`AdsManager` dùng enum `Slot` để map:

- ad unit id
- placement string
- remote config flag
- cached ad instance

Lợi ích:

- một slot chỉ có một nguồn truth
- dễ thêm slot mới sau này
- tránh hardcode rải rác trong UI

### 8.2 Pending action

Khi show fullscreen ad:

- action gốc được lưu vào `pendingActions[slot]`
- sau khi ad hide / fail display, callback mới được chạy

Mục đích:

- preserve flow logic
- không làm mất navigation / completion của UI caller

### 8.3 Guard chống show chồng

`isPresentingFullscreenAd` dùng để:

- ngăn app open, rewarded, interstitial show cùng lúc
- tránh race condition khi user tap nhiều lần

### 8.4 Ads interval / cooldown

Hệ thống có thêm một cooldown chung cho mọi fullscreen ad:

- app open splash
- app open resume
- rewarded generate
- rewarded regenerate
- interstitial close edit
- interstitial close iap
- interstitial close result

Remote config key:

- `max_ads_interval_seconds`

Default:

- `30` giây

Hành vi:

- khi một fullscreen ad đã được display thành công
- các request show ad tiếp theo sẽ bị chặn cho tới khi đủ khoảng cách thời gian
- nếu interval bằng `0`, cooldown bị coi như tắt

Mục tiêu:

- tránh user bị dội ads liên tục trong thời gian ngắn
- giữ trải nghiệm flow tự nhiên hơn
- vẫn cho phép backend điều chỉnh nhanh nếu muốn giảm/tăng tần suất

### 8.5 Retry khi load fail

Nếu load ad fail:

- log error
- schedule retry với exponential backoff

Hiện tại retry delay tăng theo:

- `2^n` giây, capped ở mức 64 giây

---

## 9. File đã thay đổi

### 9.1 File mới

- [`AIHome/AIHome/Core/Utilities/AdsManager.swift`](../AIHome/AIHome/Core/Utilities/AdsManager.swift)

### 9.2 File cập nhật

- [`AIHome/AIHome/AIHomeApp.swift`](../AIHome/AIHome/AIHomeApp.swift)
- [`AIHome/AIHome/App/AppCoordinatorView.swift`](../AIHome/AIHome/App/AppCoordinatorView.swift)
- [`AIHome/AIHome/Core/Utilities/RemoteConfigManager.swift`](../AIHome/AIHome/Core/Utilities/RemoteConfigManager.swift)
- [`AIHome/AIHome/Features/Common/MainTabHeaderView.swift`](../AIHome/AIHome/Features/Common/MainTabHeaderView.swift)
- [`AIHome/AIHome/Features/ExteriorFlow/ExteriorFlowContainerView.swift`](../AIHome/AIHome/Features/ExteriorFlow/ExteriorFlowContainerView.swift)
- [`AIHome/AIHome/Features/ExteriorFlow/ExteriorFlowView.swift`](../AIHome/AIHome/Features/ExteriorFlow/ExteriorFlowView.swift)
- [`AIHome/AIHome/Features/GardenFlow/GardenFlowContainerView.swift`](../AIHome/AIHome/Features/GardenFlow/GardenFlowContainerView.swift)
- [`AIHome/AIHome/Features/GardenFlow/GardenFlowView.swift`](../AIHome/AIHome/Features/GardenFlow/GardenFlowView.swift)
- [`AIHome/AIHome/Features/History/HistoryView.swift`](../AIHome/AIHome/Features/History/HistoryView.swift)
- [`AIHome/AIHome/Features/InteriorFlow/InteriorFlowContainerView.swift`](../AIHome/AIHome/Features/InteriorFlow/InteriorFlowContainerView.swift)
- [`AIHome/AIHome/Features/InteriorFlow/InteriorFlowView.swift`](../AIHome/AIHome/Features/InteriorFlow/InteriorFlowView.swift)
- [`AIHome/AIHome/Features/NewFlooringFlow/NewFlooringFlowContainerView.swift`](../AIHome/AIHome/Features/NewFlooringFlow/NewFlooringFlowContainerView.swift)
- [`AIHome/AIHome/Features/NewFlooringFlow/NewFlooringFlowView.swift`](../AIHome/AIHome/Features/NewFlooringFlow/NewFlooringFlowView.swift)
- [`AIHome/AIHome/Features/NewWallsFlow/NewWallsFlowContainerView.swift`](../AIHome/AIHome/Features/NewWallsFlow/NewWallsFlowContainerView.swift)
- [`AIHome/AIHome/Features/NewWallsFlow/NewWallsFlowView.swift`](../AIHome/AIHome/Features/NewWallsFlow/NewWallsFlowView.swift)
- [`AIHome/AIHome/Features/Onboarding/OnboardingIntroPagerView.swift`](../AIHome/AIHome/Features/Onboarding/OnboardingIntroPagerView.swift)
- [`AIHome/AIHome/Features/ReferenceStyleFlow/ReferenceStyleFlowContainerView.swift`](../AIHome/AIHome/Features/ReferenceStyleFlow/ReferenceStyleFlowContainerView.swift)
- [`AIHome/AIHome/Features/ReferenceStyleFlow/ReferenceStyleFlowView.swift`](../AIHome/AIHome/Features/ReferenceStyleFlow/ReferenceStyleFlowView.swift)
- [`AIHome/AIHome/Features/RemoveObjectsFlow/RemoveObjectsFlowContainerView.swift`](../AIHome/AIHome/Features/RemoveObjectsFlow/RemoveObjectsFlowContainerView.swift)
- [`AIHome/AIHome/Features/RemoveObjectsFlow/RemoveObjectsFlowView.swift`](../AIHome/AIHome/Features/RemoveObjectsFlow/RemoveObjectsFlowView.swift)
- [`AIHome/AIHome/Features/ReplaceObjectsFlow/ReplaceObjectsFlowContainerView.swift`](../AIHome/AIHome/Features/ReplaceObjectsFlow/ReplaceObjectsFlowContainerView.swift)
- [`AIHome/AIHome/Features/ReplaceObjectsFlow/ReplaceObjectsFlowView.swift`](../AIHome/AIHome/Features/ReplaceObjectsFlow/ReplaceObjectsFlowView.swift)
- [`AIHome/AIHome/Features/Result/ResultView.swift`](../AIHome/AIHome/Features/Result/ResultView.swift)
- [`AIHome/AIHome/Features/Splash/SplashView.swift`](../AIHome/AIHome/Features/Splash/SplashView.swift)

### 9.3 Project file

- [`AIHome/AIHome.xcodeproj/project.pbxproj`](../AIHome/AIHome.xcodeproj/project.pbxproj)

Thay đổi chính:

- thêm AppLovin MAX Swift Package
- link `AppLovinSDK`
- thêm linker flag `-ObjC`

---

## 10. Build / verification note

Mình đã verify được đến mức:

- AppLovin package resolve thành công
- source compile đi khá sâu trước khi dừng ở provisioning/signing

Blocker hiện tại trên máy này:

- thiếu provisioning profile cho bundle id `com.homegpt.ai.interior.redesign`

Điều này có nghĩa là:

- luồng code / package integration đã được wire
- nhưng chưa thể xác nhận end-to-end build signed trên môi trường hiện tại

---

## 11. Hành vi runtime kỳ vọng

Sau khi merge, app nên hoạt động như sau:

- mở app mới hoặc cold start -> show app open splash nếu có sẵn ad
- quay lại từ background -> show app open resume nếu đã qua cold start
- bấm Generate -> rewarded generate trước khi chạy generation
- bấm Re-generate -> rewarded regenerate trước khi generate lại
- đóng edit flow -> interstitial close edit
- đóng paywall / IAP -> interstitial close iap
- đóng result -> interstitial close result

---

## 12. Ghi chú kỹ thuật cho người maintain

- Nếu muốn tắt toàn bộ ads, set `max_enable = false`
- Nếu muốn tắt từng slot, chỉ cần toggle key tương ứng trên remote config
- Nếu muốn chỉnh tần suất show ads, set `max_ads_interval_seconds`
- Các flow hiện tại đang gọi ads ở layer UI / coordinator để giữ logic gốc ít bị ảnh hưởng
- Nếu bổ sung slot mới, nên đi theo pattern:
  1. thêm case trong `Slot`
  2. thêm ad unit id
  3. thêm remote config flag
  4. preload trong `prepareAds()`
  5. expose method public tương ứng
  6. gắn trigger ở view / coordinator

---

## 13. Kết luận

Implementation hiện tại đã chuẩn hóa thành một hệ thống ads tương đối rõ ràng:

- init một lần
- preload theo slot
- trigger theo ngữ cảnh sản phẩm
- remote config điều khiển linh hoạt
- giữ code UI và logic flow tương đối tách biệt

File này nên được dùng như tài liệu kỹ thuật chuẩn để:

- onboarding người mới
- review logic ads
- mở rộng thêm slot sau này
- debug khi remote config hoặc MAX không hoạt động như kỳ vọng
