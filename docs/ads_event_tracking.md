# Huong Dan Ads Event Tracking

> Scope: Firebase Analytics events cho AppLovin MAX ads trong app iOS.
>
> Audience: engineering, data, UA va marketing.
>
> Source code:
> - `AIHome/AIHome/Core/Utilities/AdsManager.swift`
> - `AIHome/AIHome/Core/Utilities/TrackingManager.swift`

## 1. Muc Tieu

Bo tracking nay giup tra loi bon cau hoi thuc te:

- App co yeu cau show ad khong?
- Neu ad khong hien, bi chan o gate nao?
- Neu app da request inventory, MAX load duoc, fail, display, hay co revenue khong?
- Ket qua den tu placement, format, network, creative va waterfall nao?

Revenue event cua purchase, trial va subscription khong duoc track tu client ads flow. Cac signal in-app purchase nay van nen di theo Adapty, bao gom integration Adapty to Meta.

## 2. Mo Hinh Funnel

Ads funnel duoc tach thanh hai lop: intent cua app va callback that tu MAX.

| Layer | Y nghia | Event chinh |
|---|---|---|
| App intent | Product flow muon show ad | `ad_show_requested`, `ad_show_skipped` |
| MAX loading | App request inventory tu mediation | `ad_load_requested`, `ad_load_skipped`, `ad_loaded`, `ad_load_failed` |
| MAX display | SDK that su present ad | `ad_impression`, `ad_display_failed`, `ad_clicked`, `ad_hidden` |
| Reward | Lifecycle rewarded video va grant quota | `ad_reward_started`, `ad_reward_completed`, `ad_reward_granted`, `ad_reward_skipped` |
| Revenue | Impression-level ads revenue tu MAX | `ad_revenue_paid` |

Luu y quan trong: `ad_impression` chi duoc log tu MAX display callback. Day la signal client-side gan nhat voi viec ad that su hien. `ad_show_requested` khong phai impression.

## 3. Placements

| Placement | Ad kind | Trigger |
|---|---|---|
| `open_splash` | `app_open` | Splash app open ad sau khi user da qua onboarding |
| `open_resume` | `app_open` | App resume tu background sau cold start |
| `rewarded_generate` | `rewarded` | User bam Generate khi usage dang bi lock |
| `rewarded_regenerate` | `rewarded` | User bam Re-generate khi usage dang bi lock |
| `inter_close_edit` | `interstitial` | User dong edit flow de ve Home |
| `inter_close_iap` | `interstitial` | User dong IAP/subscription entry point |
| `inter_close_result` | `interstitial` | User dong Result de ve Home |
| `banner_home` | `banner` | Slot banner Home, bat/tat bang Remote Config |
| `banner_result` | `banner` | Slot banner Result, bat/tat bang Remote Config |

## 4. Event Dictionary

| Event | Khi nao fire | Ghi chu |
|---|---|---|
| `ad_show_requested` | Product flow goi `AdsManager` de show/render ad slot | Top funnel cua user-facing ads |
| `ad_show_skipped` | App quyet dinh khong show sau mot show request | Co `skip_reason` neu xac dinh duoc |
| `ad_load_requested` | `AdsManager` thu load placement tu MAX | Co the lap lai do preload/retry |
| `ad_load_skipped` | App khong gui load request xuong MAX | Thuong do gate, config, paid user, hoac missing ad unit |
| `ad_loaded` | MAX bao ad da load xong | Inventory san sang cho placement |
| `ad_load_failed` | MAX bao load fail | Co MAX error code/message va waterfall metadata neu co |
| `ad_impression` | MAX display callback | Dung lam client impression event |
| `ad_display_failed` | MAX fail khi display ad da load | Co display error details |
| `ad_clicked` | User click ad | Callback tu MAX |
| `ad_hidden` | Fullscreen ad bi dismiss/hidden | Dung de complete pending action va preload tiep |
| `ad_reward_started` | Rewarded video bat dau | Chi cho rewarded placement |
| `ad_reward_completed` | Rewarded video hoan tat | Chua dong nghia quota da grant |
| `ad_reward_granted` | App grant free usage sau reward callback | Event moi cho ads schema |
| `ad_reward_skipped` | Reward callback co nhung quota khong doi | Co `skip_reason` |
| `ad_revenue_paid` | MAX bao impression-level revenue | Co `revenue_usd`, `value`, `currency=USD` |
| `ad_banner_expanded` | Banner expand | Chi cho banner placement |
| `ad_banner_collapsed` | Banner collapse | Chi cho banner placement |

Legacy note: `reward_earned` van duoc emit khi quota grant de dashboard cu khong gay. Bao cao moi nen dung `ad_reward_granted`.

## 5. Params Chung

Moi ads event deu co:

| Parameter | Vi du | Y nghia |
|---|---|---|
| `ad_platform` | `applovin_max` | Mediation platform |
| `placement` | `rewarded_generate` | Product placement |
| `ad_kind` | `rewarded` | Mot trong `app_open`, `interstitial`, `rewarded`, `banner` |

State/gating params co the xuat hien trong requested/skipped/load events:

| Parameter | Y nghia |
|---|---|
| `ad_unit_name` | MAX ad unit id dang cau hinh cho placement |
| `is_free_user` | User hien tai co eligible ads khong |
| `is_usage_locked` | Rewarded ad co can de unlock usage khong |
| `ads_global_enabled` | Global ads switch trong Remote Config |
| `placement_enabled` | Placement switch trong Remote Config |
| `gate_allowed` | `ads_gate.placements` co allow placement khong |
| `ad_unit_configured` | Placement co ad unit id hop le khong |
| `paywall_dismiss_count` | So lan dismiss paywall hien tai |
| `paywall_threshold` | Nguong dismiss paywall truoc khi unlock ads |
| `met_paywall_gate` | Da dat paywall gate chua |
| `cooldown_ready` | Fullscreen interval gate da san sang chua |
| `presenting_fullscreen` | Dang co fullscreen ad nao active khong |
| `cold_start_done` | Cold start flow da xong chua |
| `resume_shown` | Resume ad da show trong foreground session nay chua |
| `ad_ready` | Local ad object da ready/available chua |
| `skip_reason` | Ly do skip cu the |

MAX callback params co the xuat hien sau load/display:

| Parameter | Y nghia |
|---|---|
| `ad_format` | MAX format label, lowercased |
| `ad_source` | Ten mediated ad network |
| `network_placement` | Network placement do MAX tra ve |
| `creative_id` | Creative identifier neu co |
| `dsp_name` | DSP name cho AppLovin Exchange ads neu co |
| `dsp_id` | DSP identifier neu co |
| `request_latency_ms` | MAX request latency tinh bang milliseconds |
| `waterfall_name` | MAX waterfall name |
| `waterfall_test` | MAX waterfall test name |
| `waterfall_latency_ms` | MAX waterfall latency tinh bang milliseconds |
| `error_code` | MAX error code |
| `error_message` | MAX error message, da truncate de Firebase params gon hon |
| `mediated_error_code` | Display error code tu mediated network neu co |
| `mediated_error_message` | Display error message tu mediated network neu co |
| `next_retry_attempt` | So thu tu retry sau load failure |

Revenue params:

| Parameter | Y nghia |
|---|---|
| `revenue_usd` | Impression-level ad revenue do MAX tra ve |
| `revenue_precision` | MAX revenue precision, vi du `exact`, `estimated`, `publisher_defined`, `undefined` |
| `value` | Cung gia tri revenue, them de Firebase de aggregate kieu revenue |
| `currency` | Luon la `USD` voi MAX revenue callback |

Reward params:

| Parameter | Y nghia |
|---|---|
| `reward_amount` | MAX reward amount |
| `reward_label` | MAX reward label |
| `limit_before` | Free usage limit truoc khi grant |
| `limit_after` | Free usage limit sau khi grant |
| `remaining_before` | Free usage remaining truoc khi grant |
| `remaining_after` | Free usage remaining sau khi grant |
| `bonus_before` | Bonus usage count truoc khi grant |
| `bonus_after` | Bonus usage count sau khi grant |

## 6. Skip Reasons

| Skip reason | Y nghia |
|---|---|
| `first_app_launch` | Skip splash app-open ad vi user chua qua onboarding |
| `cold_start_not_finished` | Skip resume ad trong cold start |
| `already_shown_this_foreground` | Resume ad da show trong foreground session nay |
| `not_usage_locked_or_ineligible` | Rewarded ad chua can thiet hoac user khong eligible |
| `user_or_gate_not_eligible` | Paid user, global disabled, hoac paywall gate chua dat |
| `placement_not_allowed_by_gate` | Placement khong co trong `ads_gate.placements` |
| `placement_disabled` | Placement bi tat trong `ads_info` |
| `placement_disabled_or_gated` | Fullscreen placement bi chan boi config/gate |
| `missing_ad_unit` | Placement khong co MAX ad unit id hop le |
| `cooldown_active` | Fullscreen interval gate dang active |
| `another_fullscreen_showing` | Dang co fullscreen ad khac active |
| `ad_not_ready` | Local ad object chua ready tai luc show request |
| `rewarded_not_ready_before_deadline` | Rewarded ad khong ready trong wait window |
| `app_open_not_ready_before_deadline` | Splash app-open ad khong ready truoc deadline |
| `no_quota_change` | Reward callback co nhung app quota khong doi |

## 7. Dashboard De Xuat

### 7.1 Show funnel theo placement

Group by `placement`:

1. `ad_show_requested`
2. `ad_show_skipped`
3. `ad_impression`
4. `ad_display_failed`
5. `ad_revenue_paid`

Metric nen tao:

- Show attempt rate: `ad_show_requested / active users`
- Show skip rate: `ad_show_skipped / ad_show_requested`
- Impression rate: `ad_impression / ad_show_requested`
- Display failure rate: `ad_display_failed / ad_loaded`
- Revenue per impression: `sum(revenue_usd) / ad_impression`

### 7.2 Load health theo placement

Group by `placement`, `ad_kind`, `error_code`, va `ad_source`:

1. `ad_load_requested`
2. `ad_load_skipped`
3. `ad_loaded`
4. `ad_load_failed`

Metric nen tao:

- Load skip rate: `ad_load_skipped / ad_load_requested`
- Load success rate: `ad_loaded / ad_load_requested`
- Load fail rate: `ad_load_failed / ad_load_requested`
- No-fill share: `ad_load_failed where error_code = 204`

### 7.3 Revenue quality

Group `ad_revenue_paid` theo:

- `placement`
- `ad_kind`
- `ad_source`
- `revenue_precision`
- `waterfall_name`
- `waterfall_test`

Khi so sanh revenue, luon xem `revenue_precision` vi `exact`, `estimated`, `publisher_defined`, va `undefined` co do tin cay khac nhau.

## 8. Playbook Debug

### 8.1 Impression thap

Check theo thu tu:

1. `ad_show_requested` co thap khong? Neu co, product flow chua cham toi ad trigger.
2. `ad_show_skipped` co cao khong? Group theo `skip_reason`.
3. `ad_load_requested` co thap khong? Config hoac eligibility dang chan load.
4. `ad_load_failed` co cao khong? Group theo `error_code`, `ad_source`, va waterfall fields.
5. `ad_loaded` tot nhung `ad_impression` thap? App load duoc nhung khong present, hoac cooldown/gating dang chan show.

### 8.2 Rewarded ad khong unlock generation

Check:

1. Co `ad_show_requested` cho `rewarded_generate` hoac `rewarded_regenerate`.
2. Co `ad_impression` cho rewarded placement.
3. Co `ad_reward_started` va `ad_reward_completed`.
4. Co `ad_reward_granted` va quota params thay doi.
5. Neu co `ad_reward_skipped`, xem `skip_reason`.

### 8.3 MAX co revenue nhung Firebase khong co

Check:

1. Co `ad_impression`.
2. Co `ad_revenue_paid` cho cung `placement`.
3. `revenue_precision` khong rong.
4. MAX dashboard da bat impression-level revenue cho mediated network.

## 9. Ghi Chu Implement

- Event duoc emit qua `TrackingManager.shared.trackAdEvent(...)`.
- `AdsManager` so huu AppLovin MAX delegates va map MAX ad unit id ve `AdsPlacement`.
- `MAAdRevenueDelegate` duoc set cho app-open, rewarded, interstitial va banner ad objects.
- String co nguy co high-cardinality duoc truncate truoc khi gui len Firebase.
- Purchase, trial va subscription revenue tiep tuc thuoc ve Adapty signals, khong track bang MAX hoac client Facebook purchase events.

