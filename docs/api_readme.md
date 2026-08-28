# HomeGPT / AI Home Design — HomeDesignsAI API README

> Purpose: This file is written for Codex / AI coding agents to generate the iOS network layer for the HomeGPT AI Home Design app.
>
> Scope: Use HomeDesignsAI APIs directly from the iOS app for MVP. No custom backend for now.
>
> Important production note: Direct API calls from iOS can expose the access token through reverse engineering. This is acceptable only for prototype/MVP validation. For production, route all HomeDesignsAI calls through a backend proxy.

---

## 1. Source Design Mapping

The provided design PDF contains these AI-related app features:

| App Feature | PDF Pages | Description |
|---|---:|---|
| Interior AI | 28–34 | Upload photo, pick room type, pick design style, choose AI intervention, generate result |
| Exterior AI | 35–37 | Upload exterior photo, optional prompt, generate result |
| Garden Redesign | 9–11 | Home feature card for outdoor/garden transformation |
| Reference Style | 43–49 | Upload base photo + reference style image, generate result |
| Replace Objects | 50–54 | Upload photo + prompt/instructions, generate replacement result |
| Remove Objects | 55–59 | Upload photo + prompt/instructions, generate removal result |
| New Flooring | 60–64 | Upload photo + flooring instruction/texture, generate floor result |
| New Walls | 65–69 | Upload photo + wall instruction/color/texture, generate wall result |
| Furniture Finder | 49 | Advanced tool shown on result screen |
| Result Screen Actions | 34, 37, 49, 53, 58, 63, 68 | Regenerate, Download, Share, Save to archive, Remove Watermark, Advanced Tools |
| Inspiration / History / Settings | 18–26 | Local app features; no HomeDesignsAI API needed |

---

## 2. API Base Configuration

### Base URL

```text
https://homedesigns.ai/api/v2
```

### Authentication

HomeDesignsAI uses an access token.

Recommended iOS header:

```http
Authorization: Bearer <ACCESS_TOKEN>
```

If the API plan/docs or Postman collection uses a different token header, keep the network layer flexible:

```swift
enum HomeDesignsAuthMode {
    case bearer(token: String)
    case customHeader(name: String, value: String)
}
```

### Request Encoding

Most HomeDesignsAI endpoints use:

```http
Content-Type: multipart/form-data
```

Image parameters support:
- file `.jpg`, `.jpeg`, `.png`
- or base64 image string

For iOS, prefer uploading compressed image data as multipart file.

### Image Requirements

For most source images:
- format: JPG / JPEG / PNG
- minimum size: `512 x 512`
- recommended: resize long edge to 1024–1536 for cost/performance
- preserve aspect ratio
- avoid HEIC upload directly; convert to JPEG/PNG first

### Home AI Backend Config

For the new backend provider, use:

| | |
|---|---|
| **Base URL** | `https://aiart.billionx.co` |
| **Xác thực** | Header `Authorization: Api-Key <key>` |
| **Key dành cho dev** | `mhj9xxGV.Thk4JCaeUriamUBn2iDSq184sCJrEIYM` |
| **Định dạng** | `multipart/form-data` khi gửi ảnh, JSON khi nhận trạng thái |

Recommended environment variable:

```text
HOME_AI_BACKEND_API_KEY
```

Postman variable:

```text
api_key
```

The collection already maps `api_key` into the `Authorization: Api-Key {{api_key}}` header.

### Firebase App Check

The backend also expects Firebase App Check on every request to `https://aiart.billionx.co`.

App-side behavior:

- keep the existing `Authorization: Api-Key <key>` header
- add `X-Firebase-AppCheck: <token>` when the token is available
- fetch the token through Firebase App Check before sending the request
- if the token is not available yet, the app may still continue while backend is in `log` mode

Recommended request shape:

```http
Authorization: Api-Key <key>
X-Firebase-AppCheck: <firebase_app_check_token>
```

In iOS, the app should bootstrap `AppCheckProviderFactory` before `FirebaseApp.configure()`, then read the token from Firebase App Check in the networking layer.

---

## 3. Endpoint Summary

| Feature | Endpoint | Method | Async? | Notes |
|---|---|---:|---:|---|
| Interior / Exterior / Garden redesign | `/perfect_redesign` | POST | Yes | Returns queue id |
| Check redesign status | `/perfect_redesign/status_check/{queue_id}` | GET | N/A | Poll until `SUCCESS` |
| Reference Style | `/design_transfer` | POST | No/Unknown | Returns generated images |
| Create mask from labels | `/create_maskimage` | POST | No/Unknown | Used before remove/material/paint if mask required |
| Remove Objects | `/furniture_removal` | POST | No/Unknown | Requires `masked_image` |
| Replace object color/texture | `/change_color_textures` | POST | No/Unknown | Requires `masked_image` + prompt/color/material |
| Material Swap | `/material_swap` | POST | No/Unknown | Requires `masked_image` + `texture_image` |
| New Flooring | `/floor_editor` | POST | No/Unknown | Requires `texture_image` |
| New Walls | `/paint_visualizer` | POST | No/Unknown | Requires `masked_image` + `rgb_color` or `color_image` |
| Furniture Finder | `/furniture_finder` | POST | No/Unknown | Returns product recommendations |
| Full HD / Enhance | `/full_hd` | POST | No/Unknown | Upscale/enhance image |

---

## 4. Global Swift Types

Generate these shared model types first.

```swift
import Foundation

public enum HomeDesignsAPIError: Error, Equatable {
    case invalidURL
    case invalidImage
    case invalidResponse
    case unauthorized
    case server(statusCode: Int, message: String?)
    case decodingFailed(String)
    case queueExpired
    case apiMessage(String)
    case underlying(String)
}

public enum HomeDesignsImageSource {
    case jpegData(Data, filename: String = "image.jpg")
    case pngData(Data, filename: String = "image.png")
    case base64(String)
    case remoteURL(String)
}

public enum DesignType: String, Codable, CaseIterable {
    case interior = "Interior"
    case exterior = "Exterior"
    case garden = "Garden"
}

public enum AIIntervention: String, Codable, CaseIterable {
    case veryLow = "Very Low"
    case low = "Low"
    case mid = "Mid"
    case extreme = "Extreme"
}

/// PDF UI mapping:
/// LIGHT  -> .veryLow or .low
/// MEDIUM -> .mid
/// HIGH   -> .extreme
public enum HomeGPTInterventionLevel {
    case light
    case medium
    case high

    var apiValue: AIIntervention {
        switch self {
        case .light: return .low
        case .medium: return .mid
        case .high: return .extreme
        }
    }
}

public struct GeneratedImagesResponse: Codable, Equatable {
    public let inputImage: String?
    public let outputImages: [String]

    enum CodingKeys: String, CodingKey {
        case inputImage = "input_image"
        case outputImages = "output_images"
    }
}

public struct QueueResponse: Codable, Equatable {
    public let id: String?
    public let status: String?
    public let message: String?
    public let queueId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case message
        case queueId = "queue_id"
    }

    public var resolvedQueueId: String? {
        id ?? queueId
    }
}

public enum GenerationStatus: String, Codable {
    case inQueue = "IN_QUEUE"
    case starting = "starting"
    case processing = "processing"
    case success = "SUCCESS"
    case failed = "FAILED"
    case unknown

    public init(apiRawValue: String?) {
        guard let apiRawValue else {
            self = .unknown
            return
        }

        switch apiRawValue.lowercased() {
        case "in_queue": self = .inQueue
        case "starting": self = .starting
        case "processing": self = .processing
        case "success": self = .success
        case "failed", "error": self = .failed
        default: self = .unknown
        }
    }
}

public struct StatusCheckResponse: Codable, Equatable {
    public let status: String?
    public let inputImage: String?
    public let outputImages: [String]?
    public let message: String?

    enum CodingKeys: String, CodingKey {
        case status
        case inputImage = "input_image"
        case outputImages = "output_images"
        case message
    }

    public var resolvedStatus: GenerationStatus {
        GenerationStatus(apiRawValue: status)
    }
}
```

---

## 5. Network Client Interface

Codex should generate a protocol-first network layer.

```swift
public protocol HomeDesignsAPIClientProtocol {
    func perfectRedesign(_ request: PerfectRedesignRequest) async throws -> QueueResponse
    func checkPerfectRedesignStatus(queueId: String) async throws -> StatusCheckResponse

    func designTransfer(_ request: DesignTransferRequest) async throws -> GeneratedImagesResponse

    func createMaskImage(_ request: CreateMaskImageRequest) async throws -> CreateMaskImageResponse
    func furnitureRemoval(_ request: FurnitureRemovalRequest) async throws -> GeneratedImagesResponse

    func changeColorTextures(_ request: ChangeColorTexturesRequest) async throws -> GeneratedImagesResponse
    func materialSwap(_ request: MaterialSwapRequest) async throws -> GeneratedImagesResponse

    func floorEditor(_ request: FloorEditorRequest) async throws -> GeneratedImagesResponse
    func paintVisualizer(_ request: PaintVisualizerRequest) async throws -> GeneratedImagesResponse

    func furnitureFinder(_ request: FurnitureFinderRequest) async throws -> FurnitureFinderResponse
    func fullHD(_ request: FullHDRequest) async throws -> GeneratedImagesResponse
}
```

### Implementation Requirements

- Use `URLSession`.
- Use `async/await`.
- Use `multipart/form-data` builder.
- Inject `baseURL`, `authMode`, `urlSession`, `jsonDecoder`.
- Do not hardcode token in source.
- Read token from secure config / build config / Keychain.
- Add debug logging only under `#if DEBUG`.
- Never log the access token.
- Never log full base64 images.

---

## 6. Multipart Builder Requirements

Codex should generate a reusable multipart builder.

```swift
struct MultipartFormDataBuilder {
    let boundary: String

    mutating func appendField(name: String, value: String)
    mutating func appendFile(name: String, filename: String, mimeType: String, data: Data)
    func build() -> Data
}
```

Rules:
- String fields as UTF-8.
- JPEG: `image/jpeg`.
- PNG: `image/png`.
- For `HomeDesignsImageSource.base64`, append as normal text field.
- For `HomeDesignsImageSource.remoteURL`, append URL string as normal text field only if endpoint accepts image URL. If not documented, download/convert before upload.

---

## 7. API Details

### 7.1 Perfect Redesign

Used by:
- Interior AI
- Exterior AI
- Garden Redesign

Endpoint:

```http
POST /perfect_redesign
```

Request model:

```swift
public struct PerfectRedesignRequest {
    public let image: HomeDesignsImageSource
    public let designType: DesignType
    public let aiIntervention: AIIntervention
    public let noDesign: Int
    public let designStyle: String
    public let roomType: String?
    public let houseAngle: String?
    public let gardenType: String?
    public let customInstruction: String?
    public let keepStructuralElement: Bool?
}
```

Multipart fields:

| Swift property | Form field | Required | Notes |
|---|---|---:|---|
| `image` | `image` | Yes | JPG/PNG/base64 |
| `designType` | `design_type` | Yes | `Interior`, `Exterior`, `Garden` |
| `aiIntervention` | `ai_intervention` | Yes | `Very Low`, `Low`, `Mid`, `Extreme` |
| `noDesign` | `no_design` | Yes | Min 1, max 2 |
| `designStyle` | `design_style` | Yes | Must match API-supported style names |
| `roomType` | `room_type` | Required for Interior | e.g. `Living room` |
| `houseAngle` | `house_angle` | Required for Exterior | e.g. `Front of House` |
| `gardenType` | `garden_type` | Required for Garden | e.g. `Backyard` |
| `customInstruction` | `custom_instruction` | Optional | User prompt |
| `keepStructuralElement` | `keep_structural_element` | Optional | default true |

Status endpoint:

```http
GET /perfect_redesign/status_check/{queue_id}
```

Polling policy:
- max attempts: 60
- interval: 2 seconds
- stop on `SUCCESS` or `FAILED`
- queue id expires after around 30 minutes

---

### 7.2 Design Transfer

Used by Reference Style pages 43–49.

```http
POST /design_transfer
```

```swift
public struct DesignTransferRequest {
    public let image: HomeDesignsImageSource
    public let styleImage: HomeDesignsImageSource
    public let aiIntervention: AIIntervention
}
```

| Swift property | Form field | Required |
|---|---|---:|
| `image` | `image` | Yes |
| `styleImage` | `Style_image` | Yes |
| `aiIntervention` | `ai_intervention` | Yes |

---

### 7.3 Create Mask Image

Used before Remove Objects, Replace Objects, New Walls, Material Swap, and any flow requiring `masked_image`.

```http
POST /create_maskimage
```

```swift
public struct CreateMaskImageRequest {
    public let image: HomeDesignsImageSource
    public let labels: [String]

    public var apiLabels: String {
        labels.joined(separator: "|")
    }
}

public struct CreateMaskImageResponse: Codable, Equatable {
    public let success: MaskSuccess?

    public struct MaskSuccess: Codable, Equatable {
        public let maskedImage: String

        enum CodingKeys: String, CodingKey {
            case maskedImage = "masked_image"
        }
    }

    public var maskedImageURL: String? {
        success?.maskedImage
    }
}
```

| Swift property | Form field | Required | Example |
|---|---|---:|---|
| `image` | `image` | Yes | image file |
| `labels` | `labels` | Yes | `floor|wall`, `sofa`, `television receiver` |

Common labels:

```swift
public enum MaskLabel: String {
    case wall = "wall"
    case floor = "floor"
    case ceiling = "ceiling"
    case sofa = "sofa"
    case chair = "chair"
    case armchair = "armchair"
    case table = "table"
    case coffeeTable = "coffee table"
    case cabinet = "cabinet"
    case bed = "bed"
    case rug = "rug"
    case painting = "painting"
    case mirror = "mirror"
    case lamp = "lamp"
    case televisionReceiver = "television receiver"
    case monitor = "monitor"
    case windowpane = "windowpane"
    case door = "door"
    case sink = "sink"
    case bathtub = "bathtub"
    case toilet = "toilet"
    case refrigerator = "refrigerator"
    case kitchenIsland = "kitchen island"
    case countertop = "countertop"
    case plant = "plant"
    case tree = "tree"
    case grass = "grass"
    case swimmingPool = "swimming pool"
}
```

Prompt-to-label examples:
- `remove TV on the wall` -> `television receiver`
- `remove sofa` -> `sofa`
- `replace dining table` -> `table`
- `change wall color` -> `wall`
- `new wooden floor` -> `floor`

---

### 7.4 Furniture Removal

Used by Remove Objects pages 55–59.

```http
POST /furniture_removal
```

```swift
public struct FurnitureRemovalRequest {
    public let image: HomeDesignsImageSource
    public let maskedImage: HomeDesignsImageSource
}
```

| Swift property | Form field | Required |
|---|---|---:|
| `image` | `image` | Yes |
| `maskedImage` | `masked_image` | Yes |

Recommended MVP flow:

```text
User prompt -> map to labels -> /create_maskimage -> /furniture_removal
```

---

### 7.5 Colors & Textures

Used by Replace Objects pages 50–54 and prompt-based color/material changes.

```http
POST /change_color_textures
```

```swift
public struct ChangeColorTexturesRequest {
    public let designType: DesignType
    public let image: HomeDesignsImageSource
    public let maskedImage: HomeDesignsImageSource
    public let noDesign: Int
    public let prompt: String?
    public let color: String?
    public let materials: String?
}
```

| Swift property | Form field | Required |
|---|---|---:|
| `designType` | `design_type` | Yes |
| `image` | `image` | Yes |
| `maskedImage` | `masked_image` | Yes |
| `noDesign` | `no_design` | Yes, 1–4 |
| `prompt` | `prompt` | Required if no color/material |
| `color` | `color` | Required if no prompt/material |
| `materials` | `materials` | Required if no prompt/color |

Recommended Replace Objects flow:

```text
User prompt -> map object label -> /create_maskimage -> /change_color_textures with prompt
```

---

### 7.6 Material Swap

Used when the app has a selected/uploaded texture image.

```http
POST /material_swap
```

```swift
public struct MaterialSwapRequest {
    public let image: HomeDesignsImageSource
    public let maskedImage: HomeDesignsImageSource
    public let noDesign: Int
    public let textureImage: HomeDesignsImageSource
    public let noOfTexture: String
}
```

| Swift property | Form field | Required |
|---|---|---:|
| `image` | `image` | Yes |
| `maskedImage` | `masked_image` | Yes |
| `noDesign` | `no_design` | Yes, 2–5 |
| `textureImage` | `texture_image` | Yes |
| `noOfTexture` | `no_of_texture` | Yes, `1 X 1` ... `5 X 5` |

---

### 7.7 Floor Editor

Used by New Flooring pages 60–64.

```http
POST /floor_editor
```

```swift
public struct FloorEditorRequest {
    public let image: HomeDesignsImageSource
    public let textureImage: HomeDesignsImageSource
    public let noOfTexture: String
}
```

| Swift property | Form field | Required |
|---|---|---:|
| `image` | `image` | Yes |
| `textureImage` | `texture_image` | Yes |
| `noOfTexture` | `no_of_texture` | Yes, `1 X 1`, `2 X 2`, `3 X 3`, `4 X 4` |

Important: the PDF shows prompt-based flooring, but `/floor_editor` requires texture image. Use built-in texture presets, or fallback to `/create_maskimage labels=floor` + `/change_color_textures` with prompt.

---

### 7.8 Paint Visualizer

Used by New Walls pages 65–69.

```http
POST /paint_visualizer
```

```swift
public struct PaintVisualizerRequest {
    public let image: HomeDesignsImageSource
    public let maskedImage: HomeDesignsImageSource
    public let noDesign: Int
    public let colorImage: HomeDesignsImageSource?
    public let rgbColor: String?
}
```

| Swift property | Form field | Required |
|---|---|---:|
| `image` | `image` | Yes |
| `maskedImage` | `masked_image` | Yes |
| `noDesign` | `no_design` | Yes, 1–4 |
| `colorImage` | `color_image` | Required if `rgb_color` nil |
| `rgbColor` | `rgb_color` | Required if `color_image` nil |

Recommended New Walls flow:

```text
User prompt -> labels=wall -> /create_maskimage -> parse color -> /paint_visualizer
```

Example color parser:
- `white` -> `255,255,255`
- `warm white` -> `245,240,230`
- `beige` -> `221,196,170`
- `light gray` -> `211,211,211`
- `blue` -> `0,0,255`
- `sage green` -> `156,175,136`

---

### 7.9 Furniture Finder

Used by Furniture Finder advanced tool on page 49.

```http
POST /furniture_finder
```

```swift
public struct FurnitureFinderRequest {
    public let image: HomeDesignsImageSource
    public let countryCode: String?
}

public struct FurnitureFinderResponse: Codable, Equatable {
    public let resultArray: [String: [FurnitureProduct]]?
}

public struct FurnitureProduct: Codable, Equatable {
    public let position: Int?
    public let title: String?
    public let link: String?
    public let source: String?
    public let sourceIcon: String?
    public let rating: Double?
    public let reviews: Int?
    public let price: FurniturePrice?
    public let thumbnail: String?

    enum CodingKeys: String, CodingKey {
        case position
        case title
        case link
        case source
        case sourceIcon = "source_icon"
        case rating
        case reviews
        case price
        case thumbnail
    }
}

public struct FurniturePrice: Codable, Equatable {
    public let value: String?
}
```

| Swift property | Form field | Required |
|---|---|---:|
| `image` | `image` | Yes |
| `countryCode` | `countryCode` | Optional |

Recommended default for MVP:

```swift
countryCode = nil
```

---

### 7.10 Full HD

Used by HD export / final result enhancement.

```http
POST /full_hd
```

```swift
public struct FullHDRequest {
    public let image: HomeDesignsImageSource
}
```

| Swift property | Form field | Required |
|---|---|---:|
| `image` | `image` | Yes |

If generated result is a remote URL, download it first if `/full_hd` requires file upload.

---

## 8. App-Level Service Recipes

Codex should generate service methods combining low-level API calls.

```swift
public protocol HomeGPTAIServiceProtocol {
    func generateInterior(request: InteriorGenerationInput) async throws -> [String]
    func generateExterior(request: ExteriorGenerationInput) async throws -> [String]
    func generateGarden(request: GardenGenerationInput) async throws -> [String]
    func generateReferenceStyle(request: ReferenceStyleInput) async throws -> [String]
    func removeObjects(request: RemoveObjectsInput) async throws -> [String]
    func replaceObjects(request: ReplaceObjectsInput) async throws -> [String]
    func generateNewFlooring(request: NewFlooringInput) async throws -> [String]
    func generateNewWalls(request: NewWallsInput) async throws -> [String]
    func findFurniture(image: HomeDesignsImageSource, countryCode: String?) async throws -> FurnitureFinderResponse
    func upscale(image: HomeDesignsImageSource) async throws -> [String]
}
```

Recipes:

```text
Interior/Exterior/Garden:
/perfect_redesign -> extract queue id -> poll status -> output_images

Reference Style:
/design_transfer -> output_images

Remove Objects:
prompt -> labels -> /create_maskimage -> /furniture_removal -> output_images

Replace Objects:
prompt -> labels -> /create_maskimage -> /change_color_textures -> output_images
If texture selected: /material_swap instead.

New Flooring:
If texture preset exists: /floor_editor -> output_images
Fallback: /create_maskimage labels=floor -> /change_color_textures -> output_images

New Walls:
/create_maskimage labels=wall -> rgb/color parser -> /paint_visualizer -> output_images
If texture prompt: /change_color_textures instead.
```

---

## 9. Local-Only App Features

No HomeDesignsAI API needed.

| App Feature | Storage |
|---|---|
| Onboarding state | UserDefaults |
| Free generation count | UserDefaults |
| Pro state cache | RevenueCat/StoreKit + UserDefaults cache |
| History | Realm/CoreData/SQLite |
| Archive | Realm/CoreData/SQLite |
| Favorites | Realm/CoreData/SQLite |
| Inspiration feed | Bundled JSON or remote config/CMS |
| Settings language | UserDefaults |
| Share/download | iOS native APIs |
| Remove watermark gate | Pro entitlement |

---

## 10. Suggested Project File Structure

```text
HomeDesignsAI/
├── Core/
│   ├── HomeDesignsAPIClient.swift
│   ├── HomeDesignsAPIClientProtocol.swift
│   ├── HomeDesignsAPIError.swift
│   ├── HomeDesignsAuthMode.swift
│   ├── HomeDesignsEndpoint.swift
│   ├── MultipartFormDataBuilder.swift
│   └── ImageUploadSource.swift
│
├── Models/
│   ├── Common/
│   │   ├── GeneratedImagesResponse.swift
│   │   ├── QueueResponse.swift
│   │   └── StatusCheckResponse.swift
│   │
│   ├── Requests/
│   │   ├── PerfectRedesignRequest.swift
│   │   ├── DesignTransferRequest.swift
│   │   ├── CreateMaskImageRequest.swift
│   │   ├── FurnitureRemovalRequest.swift
│   │   ├── ChangeColorTexturesRequest.swift
│   │   ├── MaterialSwapRequest.swift
│   │   ├── FloorEditorRequest.swift
│   │   ├── PaintVisualizerRequest.swift
│   │   ├── FurnitureFinderRequest.swift
│   │   └── FullHDRequest.swift
│   │
│   └── Responses/
│       ├── CreateMaskImageResponse.swift
│       └── FurnitureFinderResponse.swift
│
├── Services/
│   ├── HomeGPTAIService.swift
│   ├── HomeGPTAIServiceProtocol.swift
│   ├── PromptMaskLabelMapper.swift
│   ├── ColorPromptMapper.swift
│   └── TexturePromptMapper.swift
│
└── Tests/
    ├── HomeDesignsAPIClientTests.swift
    ├── MultipartFormDataBuilderTests.swift
    ├── PromptMaskLabelMapperTests.swift
    ├── ColorPromptMapperTests.swift
    └── HomeGPTAIServiceTests.swift
```

---

## 11. Endpoint Enum

```swift
enum HomeDesignsEndpoint {
    case perfectRedesign
    case perfectRedesignStatus(queueId: String)
    case designTransfer
    case createMaskImage
    case furnitureRemoval
    case changeColorTextures
    case materialSwap
    case floorEditor
    case paintVisualizer
    case furnitureFinder
    case fullHD

    var path: String {
        switch self {
        case .perfectRedesign: return "/perfect_redesign"
        case .perfectRedesignStatus(let queueId): return "/perfect_redesign/status_check/\(queueId)"
        case .designTransfer: return "/design_transfer"
        case .createMaskImage: return "/create_maskimage"
        case .furnitureRemoval: return "/furniture_removal"
        case .changeColorTextures: return "/change_color_textures"
        case .materialSwap: return "/material_swap"
        case .floorEditor: return "/floor_editor"
        case .paintVisualizer: return "/paint_visualizer"
        case .furnitureFinder: return "/furniture_finder"
        case .fullHD: return "/full_hd"
        }
    }

    var method: String {
        switch self {
        case .perfectRedesignStatus: return "GET"
        default: return "POST"
        }
    }
}
```

---

## 12. Validation Rules

Common:
- Image data must be non-empty.
- Prefer validating decoded image width >= 512 and height >= 512.

Perfect Redesign:
- `noDesign` must be 1...2.
- `designStyle` cannot be empty.
- `roomType` required for Interior.
- `houseAngle` required for Exterior.
- `gardenType` required for Garden.

Create Mask Image:
- labels cannot be empty.
- labels joined by `|`.

Change Color Textures:
- `noDesign` must be 1...4.
- at least one of `prompt`, `color`, `materials` should be non-empty.

Material Swap:
- `noDesign` must be 2...5.
- `noOfTexture` must be `1 X 1`, `2 X 2`, `3 X 3`, `4 X 4`, or `5 X 5`.

Floor Editor:
- `noOfTexture` must be `1 X 1`, `2 X 2`, `3 X 3`, or `4 X 4`.

Paint Visualizer:
- `noDesign` must be 1...4.
- either `rgbColor` or `colorImage` is required.
- `rgbColor` format: `R,G,B`, values 0...255.

---

## 13. Result Handling

Most generation APIs return something like:

```json
{
  "input_image": "https://...",
  "output_images": [
    "https://...",
    "https://..."
  ]
}
```

Some APIs may wrap result differently. Make decoder tolerant:
- Try direct `GeneratedImagesResponse`.
- Try `{ "success": GeneratedImagesResponse }`.
- Try `{ "data": GeneratedImagesResponse }`.
- Try `{ "result": GeneratedImagesResponse }`.
- For Furniture Finder, parse `resultArray`.

---

## 14. Downloading Remote Images

Generated output is usually a URL.

Create:

```swift
protocol RemoteImageDownloaderProtocol {
    func downloadData(from urlString: String) async throws -> Data
}
```

Use cases:
- save result to local history
- share image
- call `/full_hd` with generated image
- call follow-up advanced tool on generated image

---

## 15. Security Notes for Direct iOS Integration

For this MVP, API is called directly from iOS.

Do:
- Store token outside git.
- Use `.xcconfig`, CI secret, or Keychain.
- Add remote kill switch if token is abused.
- Limit API plan quotas.

Do not:
- Commit token into repository.
- Print token in logs.
- Put token in README.
- Hardcode token in generated source.

Recommended config:

```swift
struct HomeDesignsAPIConfig {
    let baseURL: URL
    let authMode: HomeDesignsAuthMode
}
```

---

## 16. Testing Requirements

Generate unit tests for:

Multipart builder:
- appends string fields
- appends JPEG file
- appends PNG file
- contains expected boundary
- ends with closing boundary

Request validation:
- Interior without room type fails
- Exterior without house angle fails
- Garden without garden type fails
- noDesign out of range fails
- Paint Visualizer without color fails

Prompt mapper:
- `remove tv on the wall` -> `television receiver`
- `remove sofa` -> `sofa`
- `replace dining table` -> `table`
- `change wall color` -> `wall`
- `new wooden floor` -> `floor`

Color mapper:
- `warm white` -> `245,240,230`
- `beige` -> `221,196,170`
- `blue` -> `0,0,255`

Service tests:
- Interior calls perfect redesign then polls.
- Remove objects calls create mask then furniture removal.
- Replace objects calls create mask then change color textures.
- New walls calls create mask then paint visualizer.
- New flooring calls floor editor if texture preset exists.

---

## 17. MVP Implementation Priority

Build in this order:

1. `MultipartFormDataBuilder`
2. `HomeDesignsAPIClient`
3. `/perfect_redesign`
4. status polling
5. Interior AI flow
6. Exterior/Garden flow
7. `/design_transfer`
8. `/create_maskimage`
9. `/furniture_removal`
10. `/change_color_textures`
11. `/floor_editor`
12. `/paint_visualizer`
13. `/furniture_finder`
14. `/full_hd`
15. Local history/archive integration

---

## 18. Known Product Decisions

- No user account for MVP.
- No Firebase Auth.
- No custom backend for now.
- Credits/free generations are local.
- History/archive/favorites are local.
- HomeDesignsAI access token is used directly for now.
- Prompt-based advanced editing is acceptable for MVP.
- Mask drawing UI is not required for MVP.
- For APIs requiring mask, generate masks automatically via `/create_maskimage`.

---

## 19. Open Questions / TODO

Codex should leave these as TODOs in generated code:

```swift
// TODO: Verify exact Authorization header format from active HomeDesignsAI account/Postman collection.
// TODO: Verify whether endpoints accept remote image URLs or require file upload only.
// TODO: Verify exact response wrapper for each endpoint with real API token.
// TODO: Replace default style/room strings with live data or curated app constants.
// TODO: Add backend proxy before production release to protect access token.
```

---

## 20. Suggested Curated Constants for UI

Room Types:

```swift
let interiorRoomTypes = [
    "Living room", "Bedroom", "Bathroom", "Kitchen", "Dining room",
    "Home office", "Study room", "Coffee shop", "Restaurant",
    "Gaming room", "Attic", "Office", "Toilet", "Balcony"
]
```

House Angles:

```swift
let exteriorHouseAngles = [
    "Front of House", "Back of House", "Side of House"
]
```

Garden Types:

```swift
let gardenTypes = [
    "Backyard", "Front Yard", "Courtyard", "Patio", "Terrace", "Garden"
]
```

Design Styles:

```swift
let commonDesignStyles = [
    "Modern", "Contemporary", "Industrial", "Scandinavian", "Minimalist",
    "Bohemian", "Luxury", "Cozy Cabin", "Luxe", "No Style"
]
```

---

## 21. Minimal Example Usage

```swift
let client = HomeDesignsAPIClient(
    config: HomeDesignsAPIConfig(
        baseURL: URL(string: "https://homedesigns.ai/api/v2")!,
        authMode: .bearer(token: token)
    )
)

let request = PerfectRedesignRequest(
    image: .jpegData(imageData),
    designType: .interior,
    aiIntervention: .mid,
    noDesign: 1,
    designStyle: "Modern",
    roomType: "Living room",
    customInstruction: "Make it cozy, bright, and premium.",
    keepStructuralElement: true
)

let queue = try await client.perfectRedesign(request)
guard let queueId = queue.resolvedQueueId else {
    throw HomeDesignsAPIError.apiMessage("Missing queue id")
}

let result = try await client.pollPerfectRedesign(queueId: queueId)
let outputImages = result.outputImages ?? []
```

---

## 22. Final API Coverage Statement

HomeDesignsAI APIs are sufficient for the AI-related features shown in the design PDF:

- Interior AI: `/perfect_redesign`
- Exterior AI: `/perfect_redesign`
- Garden Redesign: `/perfect_redesign`
- Reference Style: `/design_transfer`
- Remove Objects: `/create_maskimage` + `/furniture_removal`
- Replace Objects: `/create_maskimage` + `/change_color_textures` or `/material_swap`
- New Flooring: `/floor_editor` or `/create_maskimage` + `/change_color_textures`
- New Walls: `/create_maskimage` + `/paint_visualizer` or `/change_color_textures`
- Furniture Finder: `/furniture_finder`
- HD Export: `/full_hd`

Non-AI product features such as onboarding, paywall, free credits, history, archive, favorites, settings, language, and restore purchase are app-side/local features and do not require HomeDesignsAI API calls.

---

## 23. API Provider Strategy

The app now supports more than one API provider behind the same service facade.
The intent is to keep all existing feature call sites unchanged while making it easy to switch backends.

### Service Layer Shape

```swift
HomeGPTAIService (facade)
└── HomeGPTGenerationProviderProtocol (strategy)
    ├── LegacyHomeDesignsProvider
    └── HomeAIDeepArtProvider
```

`HomeGPTAIService` stays as the public entry point used by feature screens and view models.
It forwards every request to the currently selected provider.

### Provider Kinds

```swift
public enum HomeGPTProviderKind: String, Codable, CaseIterable {
    case legacyHomeDesigns = "legacy_home_designs"
    case homeAIBackend = "home_ai_backend"
}
```

Recommended default:
- `home_ai_backend`

Legacy fallback:
- `legacy_home_designs`

### Switching Rules

Provider selection is resolved in this order:

1. Environment variable `HOME_GPT_PROVIDER_KIND`
2. Local override stored in `UserDefaults`
3. Remote Config default
4. Fallback default `home_ai_backend`

This means:
- CI / debugging can force a provider with environment variables.
- The app can persist a local override for testing.
- Remote Config can set the default provider for all users.

### Remote Config Key

Use this Remote Config key:

```text
home_gpt_provider_kind
```

Accepted values:
- `home_ai_backend`
- `legacy_home_designs`

Recommended Remote Config default:
- `home_ai_backend`

### Current App Behavior

- Provider setting is currently hidden from the Settings UI.
- The backend provider is still selectable in code and via Remote Config.
- The app currently starts on `home_ai_backend` so the new backend can be tested immediately.

### Local Override Storage

Local override is stored in:

```text
UserDefaults key: home_gpt_provider_kind_override
```

Use this only for developer/testing flows.
If you want to return to remote-controlled behavior, clear the local override and let Remote Config decide.

### New Backend Contract

The new backend uses the async job flow:

```http
POST /deepart/jobs
GET  /deepart/jobs/{job_id}
```

Create-job response:
- `job_id`
- `poll_after_ms`
- optional `message`

Poll response:
- `status`
- `result_url`
- optional `error`
- optional `poll_after_ms`

Feature mapping used by the app:

| App feature | Backend `feature` |
|---|---|
| Interior | `interior` |
| Exterior | `exterior` |
| Garden | `garden` |
| Reference Style | `stylematch` |
| Remove Objects | `remove` |
| Replace Objects | `replace` |
| New Flooring | `flooring` |
| New Walls | `walls` |

### Implementation Notes

- Keep `HomeGPTAIService` as the only type used by views and view models.
- Add new provider implementations behind `HomeGPTGenerationProviderProtocol`.
- Preserve the legacy provider as a fallback so no existing flow breaks.
- Do not change the feature call sites when adding another provider later.
- Keep provider-specific auth logic inside the provider, not in the UI.

### Suggested Testing Checklist

- Launch app with `home_ai_backend` selected.
- Verify interior generation goes through `/deepart/jobs`.
- Verify polling stops on `completed` and downloads `result_url`.
- Switch Remote Config default to `legacy_home_designs` and confirm fallback still works.
- Verify feature screens do not depend on the provider type directly.
