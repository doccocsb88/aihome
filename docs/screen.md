# HomeGPT / AI Home Design - Screen & Module Implementation Spec

> Purpose: This file is written for Codex / AI coding agents to generate the iOS app module structure directly from the design PDF and existing API mapping.
>
> Design source:
> - PDF: `i001_AI Home Design.pdf`
> - Figma: `https://www.figma.com/design/d6tjcFd5lOKH5UKzVDQA5T/i001_AI-Home-Design?node-id=803-1977`
> - Note: Figma access may require permission. Use the PDF page references below as the primary implementation source.
>
> Architecture target:
> - iOS app
> - Swift
> - UIKit + SnapKit or SwiftUI are both acceptable, but keep every screen as an isolated feature module/folder.
> - Suggested style for this project: VIPER or MVVM-C.
> - Local-first MVP: no user account, no cloud sync.
> - API: call HomeDesignsAI directly for now.

---

## 0. App Module Rules

Each screen or feature flow must live in its own folder.

Recommended folder structure:

```text
HomeGPT/
  App/
    AppCoordinator.swift
    AppRoute.swift
    DependencyContainer.swift
  Core/
    Network/
    Storage/
    DesignSystem/
    Extensions/
    Utilities/
  Features/
    Splash/
    Onboarding/
    TrialEnabled/
    MainTab/
    Home/
    Inspiration/
    InspirationFilter/
    History/
    Settings/
    Paywall/
    PhotoSourcePicker/
    InteriorFlow/
    ExteriorFlow/
    GardenFlow/
    ReferenceStyleFlow/
    ReplaceObjectsFlow/
    RemoveObjectsFlow/
    NewFlooringFlow/
    NewWallsFlow/
    GenerationLoading/
    Result/
    AdvancedTools/
```

Each module should include:

```text
<ModuleName>/
  <ModuleName>ViewController.swift or <ModuleName>View.swift
  <ModuleName>ViewModel.swift
  <ModuleName>Coordinator.swift
  <ModuleName>Models.swift
  <ModuleName>Builder.swift
```

For VIPER, use:

```text
<ModuleName>/
  <ModuleName>ViewController.swift
  <ModuleName>Presenter.swift
  <ModuleName>Interactor.swift
  <ModuleName>Router.swift
  <ModuleName>Models.swift
  <ModuleName>Builder.swift
```

---

## 1. Global Navigation Map

```text
Splash
  -> Welcome
  -> Onboarding Interior
  -> Onboarding Exterior
  -> Onboarding Landscape
  -> Trial Enabled / Paywall Gate
  -> MainTab

MainTab
  -> Home
  -> Inspiration
  -> History
  -> Settings

Home
  -> InteriorFlow
  -> ExteriorFlow
  -> GardenFlow
  -> ReferenceStyleFlow
  -> RemoveObjectsFlow
  -> ReplaceObjectsFlow
  -> NewFlooringFlow
  -> NewWallsFlow

Any Generation Flow
  -> GenerationLoading
  -> Result
  -> AdvancedTools
  -> Save to Archive / Download / Share / Regenerate
```

---

## 2. Global Models

### 2.1 Project Type

```swift
enum ProjectType: String, Codable, CaseIterable {
    case interior
    case exterior
    case garden
    case referenceStyle
    case replaceObjects
    case removeObjects
    case newFlooring
    case newWalls
}
```

### 2.2 AI Intervention

PDF labels: `HIGH`, `MEIDUM` / `MEDIUM`, `LIGHT`.

Map to API values:

```swift
enum AIIntervention: String, Codable, CaseIterable {
    case light
    case medium
    case high

    var apiValue: String {
        switch self {
        case .light: return "Very Low" // or "Low" depending API enum acceptance
        case .medium: return "Mid"
        case .high: return "Extreme"
        }
    }
}
```

### 2.3 Local Project

```swift
struct LocalProject: Codable, Identifiable {
    let id: String
    let type: ProjectType
    let title: String
    let styleName: String?
    let roomType: String?
    let createdAt: Date
    let originalImagePath: String
    let generatedImagePaths: [String]
    let selectedGeneratedImagePath: String?
    var isFavorite: Bool
}
```

### 2.4 Generation Job

```swift
struct GenerationJob: Codable, Identifiable {
    let id: String
    let queueId: String?
    let projectType: ProjectType
    let createdAt: Date
    var status: GenerationStatus
    var inputImagePath: String
    var outputImageURLs: [URL]
    var errorMessage: String?
}

enum GenerationStatus: String, Codable {
    case idle
    case uploading
    case queued
    case generating
    case completed
    case failed
}
```

---

## 3. Local Storage Requirements

No account sync for MVP.

Use local storage only:

```text
UserDefaults:
  - hasSeenOnboarding: Bool
  - freeGenerationsRemaining: Int
  - isProCached: Bool
  - selectedLanguageCode: String

FileManager:
  - original uploaded images
  - generated images
  - thumbnails

Realm/CoreData/SQLite:
  - LocalProject
  - Favorite inspiration item
  - GenerationJob cache
```

Suggested file paths:

```text
Documents/HomeGPT/originals/<projectId>.jpg
Documents/HomeGPT/generated/<projectId>/<imageId>.jpg
Documents/HomeGPT/thumbnails/<projectId>.jpg
```

---

## 4. API Layer Dependency

The screen modules should depend on a protocol, not concrete API client.

```swift
protocol HomeDesignsAPIService {
    func perfectRedesign(_ request: PerfectRedesignRequest) async throws -> GenerationQueueResponse
    func checkPerfectRedesignStatus(queueId: String) async throws -> GenerationStatusResponse
    func designTransfer(_ request: DesignTransferRequest) async throws -> ImageGenerationResponse
    func createMaskImage(_ request: CreateMaskImageRequest) async throws -> MaskImageResponse
    func furnitureRemoval(_ request: FurnitureRemovalRequest) async throws -> ImageGenerationResponse
    func changeColorTextures(_ request: ChangeColorTexturesRequest) async throws -> ImageGenerationResponse
    func materialSwap(_ request: MaterialSwapRequest) async throws -> ImageGenerationResponse
    func floorEditor(_ request: FloorEditorRequest) async throws -> ImageGenerationResponse
    func paintVisualizer(_ request: PaintVisualizerRequest) async throws -> ImageGenerationResponse
    func furnitureFinder(_ request: FurnitureFinderRequest) async throws -> FurnitureFinderResponse
    func fullHD(_ request: FullHDRequest) async throws -> ImageGenerationResponse
}
```

Reference the separate `api_readme.md` for endpoint-level detail.

---

# 5. Screen Modules

---

## 5.1 Splash Module

**Folder:** `Features/Splash/`

**PDF page:** 1

**Purpose:** Initial app launch screen.

**UI elements:**
- App name/logo: `HomeGPT`
- Fullscreen minimal background

**State:**

```swift
struct SplashState {
    let hasSeenOnboarding: Bool
}
```

**Actions:**
- On appear, wait briefly or immediately route.
- If `hasSeenOnboarding == false`, navigate to `Welcome`.
- Else navigate to `MainTab`.

**No API call.**

**Implementation notes:**
- Keep it lightweight.
- Do not block on remote config for MVP.

---

## 5.2 Welcome Module

**Folder:** `Features/Onboarding/Welcome/`

**PDF page:** 2

**Purpose:** Introduce app value proposition.

**UI elements:**
- Title: `Welcome to HomeGPT`
- Subtitle: `Transform your space with AI`
- CTA: `Get Started`
- Footer links:
  - Terms of use
  - Subscription Terms
  - Privacy Policy

**Actions:**
- Tap `Get Started` -> `OnboardingInteriorIntro`
- Tap terms/privacy -> open web view / Safari.

**No API call.**

---

## 5.3 Onboarding Interior Intro Module

**Folder:** `Features/Onboarding/InteriorIntro/`

**PDF page:** 3

**Purpose:** Show before/after interior transformation.

**UI elements:**
- Before/After image comparison visual
- Title: `Interior Design`
- Subtitle: `Redesign your space instantly`
- CTA: `Continue`

**Actions:**
- Tap `Continue` -> `OnboardingExteriorIntro`

**No API call.**

---

## 5.4 Onboarding Exterior Intro Module

**Folder:** `Features/Onboarding/ExteriorIntro/`

**PDF page:** 4

**Purpose:** Show before/after exterior transformation.

**UI elements:**
- Before/After image comparison visual
- Title: `Exterior Design`
- Subtitle: `Reimagine your facade`
- CTA: `Continue`

**Actions:**
- Tap `Continue` -> `OnboardingLandscapeIntro`

**No API call.**

---

## 5.5 Onboarding Landscape Intro Module

**Folder:** `Features/Onboarding/LandscapeIntro/`

**PDF page:** 5

**Purpose:** Show garden/landscape transformation.

**UI elements:**
- Before/After image comparison visual
- Title: `Landscape Design`
- Subtitle: `Refresh your garden with AI`
- CTA: `Continue`

**Actions:**
- Tap `Continue` -> `TrialEnabled` or `Paywall`

**No API call.**

---

## 5.6 Trial Enabled Module

**Folder:** `Features/TrialEnabled/`

**PDF page:** 6

**Purpose:** Confirmation after trial/subscription activation.

**UI elements:**
- Title: `3-day free trial is enabled!`
- Subtitle: `You now have full access to all premium features.`

**Actions:**
- Auto route or CTA route to `MainTab`.
- Set `hasSeenOnboarding = true`.

**Dependencies:**
- StoreKit / RevenueCat if implemented.

**No HomeDesignsAI API call.**

---

## 5.7 MainTab Module

**Folder:** `Features/MainTab/`

**PDF pages:** 9, 11, 20, 24, 26

**Purpose:** Main app shell with bottom navigation.

**Tabs:**
- Home
- Inspiration
- History
- Settings

**Shared UI:**
- Top badge: free generation count, e.g. `3/3`
- Pro badge: `PRO`

**State:**

```swift
struct MainTabState {
    let selectedTab: MainTab
    let freeGenerationsRemaining: Int
    let isPro: Bool
}

enum MainTab: CaseIterable {
    case home
    case inspiration
    case history
    case settings
}
```

**No HomeDesignsAI API call.**

---

## 5.8 Home Module

**Folder:** `Features/Home/`

**PDF pages:** 9, 11

**Purpose:** Dashboard of AI tools.

**Sections:**

### Primary tools
- Interior AI
- Exterior AI
- Garden Redesign

### Advanced Editing
- Reference Style
- Remove Objects
- Replace Objects
- New Flooring
- New Walls

**UI list item model:**

```swift
struct HomeToolItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let projectType: ProjectType
    let isPro: Bool
}
```

**Actions:**
- Tap Interior AI -> `InteriorPhotoStep`
- Tap Exterior AI -> `ExteriorInput`
- Tap Garden Redesign -> `GardenPhotoStep`
- Tap Reference Style -> `ReferenceStyleSourcePhotoStep`
- Tap Remove Objects -> `RemoveObjectsInput`
- Tap Replace Objects -> `ReplaceObjectsInput`
- Tap New Flooring -> `NewFlooringInput`
- Tap New Walls -> `NewWallsInput`

**No API call directly.**

---

## 5.9 Upgrade / Free Generations Gate Module

**Folder:** `Features/Paywall/GenerationLimit/`

**PDF page:** 15

**Purpose:** Shown when user hits free generation limit or taps PRO.

**UI elements:**
- Title: `3/3 Free Generations Left`
- Description: `Unlock unlimited features, faster processing, and premium designs with Pro.`
- CTA: `Upgrade Now`

**State:**

```swift
struct GenerationLimitState {
    let freeGenerationsRemaining: Int
    let isPro: Bool
}
```

**Actions:**
- Tap Upgrade Now -> open Paywall / StoreKit purchase.
- If purchase succeeds -> update `isProCached`.

**No HomeDesignsAI API call.**

---

## 5.10 Inspiration Module

**Folder:** `Features/Inspiration/`

**PDF pages:** 18, 19, 20, 21, 22, 23

**Purpose:** Browse design inspirations.

**Tabs:**
- Interior
- Exterior
- Garden

**Card content examples:**
- `THE CURVE LOFT`
- `MODERN LOFT`
- `MONOLITH KITCHEN`
- `KITCHEN MARBLE`

**Card model:**

```swift
struct InspirationItem: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let category: InspirationCategory
    let spaceType: String
    let styleTag: String
    let imageNameOrURL: String
    var isLiked: Bool
}

enum InspirationCategory: String, Codable {
    case interior
    case exterior
    case garden
}
```

**Actions:**
- Tap card -> `InspirationDetail`
- Tap favorite -> save locally
- Tap filter -> `InspirationFilter`

**No HomeDesignsAI API call.**

**Implementation notes:**
- For MVP, ship static JSON bundled in app.
- Later can replace with remote CMS.

---

## 5.11 Inspiration Filter Module

**Folder:** `Features/InspirationFilter/`

**PDF page:** 21

**Purpose:** Filter inspiration feed.

**Filters:**
- Favourite:
  - All
  - Liked
- Interior Spaces:
  - All
  - Living room
  - Bathroom
  - Bedroom
  - Toilet
  - Kitchen
- Exterior Spaces:
  - All
  - Garden
  - Villa
  - Backyard
  - Pool

**Actions:**
- Tap Reset -> clear filters
- Tap Apply -> return selected filters to Inspiration module

**No API call.**

---

## 5.12 Inspiration Detail Module

**Folder:** `Features/Inspiration/Detail/`

**PDF page:** 22

**Purpose:** Show detail for one inspiration item.

**UI elements:**
- Large image
- Title, e.g. `Stockholm Studio`
- Subtitle, e.g. `Scandinavian Workspace`
- Advanced Tools chips:
  - Reference
  - Replace
  - Remove
  - New Wall
  - New Flooring
  - Furniture Finder
- CTA: `REDESIGN`

**Actions:**
- Tap Reference -> start `ReferenceStyleFlow` using inspiration image as reference
- Tap Replace -> start `ReplaceObjectsFlow`
- Tap Remove -> start `RemoveObjectsFlow`
- Tap New Wall -> start `NewWallsFlow`
- Tap New Flooring -> start `NewFlooringFlow`
- Tap Furniture Finder -> start `FurnitureFinderFlow`
- Tap REDESIGN -> start Interior/Exterior/Garden flow depending item category

**No API call until user starts a generation flow.**

---

## 5.13 History Module

**Folder:** `Features/History/`

**PDF pages:** 24, 25

**Purpose:** Show locally saved projects.

**States:**

### Non-empty state
PDF page 24.

Items:
- Living Room / Minimalist
- Villa Facade / Modern
- Kitchen / Marble
- Reading Nook / Nordic
- Bathroom / Spa
- Pool Area / Resort

### Empty state
PDF page 25.

Text:
- `Start your first project`
- `Create a new space and watch your ideas come to life.`
- CTA: `Create New Project`

**Actions:**
- Load `LocalProject` from local DB.
- Tap item -> open `Result` in read-only / archived mode.
- Tap Create New Project -> Home or Photo Source picker.
- Swipe/delete -> remove local project and images.

**No HomeDesignsAI API call.**

---

## 5.14 Settings Module

**Folder:** `Features/Settings/`

**PDF page:** 26

**Purpose:** App settings.

**Rows:**
- Restore Purchase
- Language: `ENGLISH`
- Privacy Policy
- Terms of Service
- Feedback

**Footer text:**
- `homegpt-ai interior design`

**Actions:**
- Restore Purchase -> StoreKit/RevenueCat restore
- Language -> Language picker
- Privacy Policy -> open URL
- Terms of Service -> open URL
- Feedback -> mail composer or feedback form

**No HomeDesignsAI API call.**

---

# 6. Generation Shared Modules

---

## 6.1 Photo Source Picker Module

**Folder:** `Features/PhotoSourcePicker/`

**PDF pages:** 28, 35, 43, 50, 55, 60, 65

**Purpose:** Reusable UI for choosing image source.

**UI elements:**
- Title depends flow:
  - `Start with a photo`
  - `Choose your photo.`
- Hint: `For better results, use a horizontal direction.`
- Buttons:
  - Gallery
  - Camera
  - Try a sample / Try a template
- CTA:
  - `Get Started`
  - `Generate`
  - `Continue`

**State:**

```swift
struct PhotoSourceState {
    let title: String
    let subtitle: String?
    let selectedImage: UIImage?
    let allowsSample: Bool
    let sampleImages: [SampleImage]
    let ctaTitle: String
    let canContinue: Bool
}
```

**Actions:**
- Tap Gallery -> PHPicker / UIImagePickerController
- Tap Camera -> Camera capture
- Tap sample -> use bundled sample image
- Tap CTA -> return selected image to parent flow

**No HomeDesignsAI API call.**

---

## 6.2 Generation Loading Module

**Folder:** `Features/GenerationLoading/`

**PDF pages:** 33, 36, 40, 48, 52, 57, 62, 67

**Purpose:** Shared loading state while calling AI API.

**UI elements:**
- Text: `Generating...`
- Progress visual
- Optional tips carousel

**State:**

```swift
struct GenerationLoadingState {
    let projectType: ProjectType
    let status: GenerationStatus
    let progressText: String
    let canCancel: Bool
}
```

**Actions:**
- Start generation task on appear.
- If API returns queue ID, poll until completed.
- On success -> `Result`
- On failure -> show retry error state.

**API calls:**
- Depends on flow.
- Usually one generate request + optional polling request.

---

## 6.3 Result Module

**Folder:** `Features/Result/`

**PDF pages:** 34, 37, 41, 49, 53, 58, 63, 68

**Purpose:** Show generated output and post-generation actions.

**UI elements:**
- Header: `Pro Result`
- App name: `HomeGPT`
- Button: `Remove Watermark`
- Section: `Advanced Tools`
- Tool chips vary by source:
  - Edit
  - Replace
  - Remove
  - New Wall
  - New Flooring
  - Furniture Finder
- Bottom actions:
  - Regenerate
  - Download
  - Share
  - Save to archive

**State:**

```swift
struct ResultState {
    let project: LocalProject
    let originalImage: UIImage
    let generatedImages: [UIImage]
    let selectedIndex: Int
    let availableAdvancedTools: [AdvancedTool]
    let isPro: Bool
    let hasWatermark: Bool
}

enum AdvancedTool: String, CaseIterable {
    case edit
    case replace
    case remove
    case newWall
    case newFlooring
    case furnitureFinder
}
```

**Actions:**
- Regenerate -> rerun original request
- Download -> save selected image to Photos
- Share -> UIActivityViewController
- Save to archive -> save `LocalProject` locally
- Remove Watermark -> if not Pro show paywall; if Pro use clean image
- Tap advanced tool -> start corresponding flow with selected generated image as input

**Optional API call:**
- Full HD upscale if user taps HD/download high quality.

---

# 7. Core Generation Flows

---

## 7.1 InteriorFlow Module

**Folder:** `Features/InteriorFlow/`

**PDF pages:** 28, 29, 30, 31, 32, 33, 34

**Purpose:** Generate interior room redesign.

### Step 1: InteriorPhotoStep

**PDF pages:** 28, 29

**UI:**
- `Step 1/4`
- `Start with a photo`
- `Upload or select from template to try`
- Gallery / Camera
- Try a sample
- CTA: `Get Started`

**State:**

```swift
struct InteriorDraft {
    var sourceImage: UIImage?
    var roomType: RoomType?
    var designStyle: DesignStyle?
    var intervention: AIIntervention?
}
```

**Action:**
- Continue -> Step 2 if image selected.

### Step 2: Pick Room Type

**PDF page:** 30

**Options:**
- Dining room
- Bathroom
- Bedroom
- Home office
- Study room
- Coffee shop
- Living room
- Kitchen
- Restaurant
- Gaming room
- Attic
- Office
- Toilet
- Balcony

**Action:**
- Select room type -> continue.

### Step 3: Pick Design Style

**PDF page:** 31

**Options shown:**
- Custom style
- Contemporary
- Luxe
- St. Valentines
- Industrial
- Cozy Cabin

**Action:**
- Select style -> Step 4.
- If Custom style selected, show text input.

### Step 4: AI Intervention

**PDF page:** 32

**Options:**
- HIGH: Creative redesign with high innovation, low preservation.
- MEDIUM: Balanced redesign with key room elements preserved.
- LIGHT: Layout decoration with only textures and furniture updates.

**Action:**
- Tap Generate -> `GenerationLoading`

### API Mapping

Call:

```text
POST /perfect_redesign
```

Request mapping:

```swift
PerfectRedesignRequest(
    image: sourceImage,
    designType: .interior,
    roomType: selectedRoomType.apiValue,
    designStyle: selectedStyle.apiValue,
    aiIntervention: selectedIntervention.apiValue,
    noDesign: 1,
    customInstruction: customStylePrompt
)
```

Then poll status if queue response:

```text
GET /perfect_redesign/status_check/{queue_id}
```

---

## 7.2 ExteriorFlow Module

**Folder:** `Features/ExteriorFlow/`

**PDF pages:** 35, 36, 37

**Purpose:** Generate exterior/facade redesign.

**UI page:** Exterior Redesign input.

**PDF page 35 elements:**
- Title: `Exterior Redesign`
- Choose your photo.
- Hint: `For better results, use a horizontal direction.`
- Gallery
- Camera
- Prompt input: `Tailor the prompt with your own instructions to get the exact design you want.`
- Try a sample
- CTA: `Generate`

**State:**

```swift
struct ExteriorDraft {
    var sourceImage: UIImage?
    var prompt: String?
    var style: DesignStyle?
    var houseAngle: String?
    var intervention: AIIntervention
}
```

**Actions:**
- Pick image
- Enter prompt
- Tap Generate -> call API -> Loading -> Result

**API Mapping:**

```text
POST /perfect_redesign
```

```swift
PerfectRedesignRequest(
    image: sourceImage,
    designType: .exterior,
    designStyle: selectedStyle?.apiValue,
    houseAngle: houseAngle,
    aiIntervention: intervention.apiValue,
    noDesign: 1,
    customInstruction: prompt
)
```

Then poll:

```text
GET /perfect_redesign/status_check/{queue_id}
```

---

## 7.3 GardenFlow Module

**Folder:** `Features/GardenFlow/`

**PDF pages:** Home entry at 9, 11. Use same flow pattern as Exterior or Interior depending implementation.

**Purpose:** Generate garden/landscape redesign.

**Suggested screens:**
1. GardenPhotoStep
2. GardenStyleStep
3. AIInterventionStep
4. GenerationLoading
5. Result

**State:**

```swift
struct GardenDraft {
    var sourceImage: UIImage?
    var gardenType: String?
    var designStyle: DesignStyle?
    var prompt: String?
    var intervention: AIIntervention
}
```

**API Mapping:**

```text
POST /perfect_redesign
```

```swift
PerfectRedesignRequest(
    image: sourceImage,
    designType: .garden,
    gardenType: gardenType,
    designStyle: selectedStyle?.apiValue,
    aiIntervention: intervention.apiValue,
    noDesign: 1,
    customInstruction: prompt
)
```

Then poll status.

---

# 8. Advanced Editing Flows

---

## 8.1 ReferenceStyleFlow Module

**Folder:** `Features/ReferenceStyleFlow/`

**PDF pages:** 43, 44, 45, 46, 47, 48, 49

**Purpose:** Apply style from reference image/template to user's space.

### Step 1: Start with source photo

**PDF pages:** 43, 44

**UI:**
- `Step 1/3`
- `Start with a photo`
- Gallery / Camera
- Try a template
- CTA: `Get Started`

### Step 2: Pick reference style

**PDF pages:** 45, 46

**UI:**
- `Step 2/3`
- `Pick a reference style`
- Upload or select from template
- Gallery / Camera
- Try a template
- CTA: `continue`

### Step 3: AI Intervention

**PDF page:** 47

The PDF says `Step 4/4`, but for this flow it should be treated as final intervention step.

**Options:**
- HIGH
- MEDIUM
- LIGHT

### Loading and Result

**PDF pages:** 48, 49

Result advanced tools include:
- Replace
- Remove
- New Wall
- New Flooring
- Furniture Finder

**State:**

```swift
struct ReferenceStyleDraft {
    var sourceImage: UIImage?
    var referenceImage: UIImage?
    var intervention: AIIntervention?
}
```

**API Mapping:**

```text
POST /design_transfer
```

Request:

```swift
DesignTransferRequest(
    image: sourceImage,
    styleImage: referenceImage,
    aiIntervention: intervention.apiValue
)
```

---

## 8.2 ReplaceObjectsFlow Module

**Folder:** `Features/ReplaceObjectsFlow/`

**PDF pages:** 50, 51, 52, 53, 54

**Purpose:** Replace furniture/object/material by prompt.

**PDF page 50 UI:**
- Title: `Replace Objects`
- Choose your photo
- Gallery / Camera
- Prompt input text:
  - `Tailor the prompt with your own instructions to get the exact design you want.`
- Try a sample

**PDF page 51:**
- CTA: `Generate`

**PDF page 52:**
- Loading

**PDF page 53:**
- Result
- Advanced tools:
  - Edit
  - Remove
  - New Walls
  - New Flooring
- Bottom actions:
  - Regenerate
  - Download
  - Share
  - Save to archive

**State:**

```swift
struct ReplaceObjectsDraft {
    var sourceImage: UIImage?
    var prompt: String
    var parsedLabel: String?
    var replacementDescription: String?
    var textureImage: UIImage?
}
```

**Implementation strategy:**

For MVP, use prompt-based UX. Network layer can support two direct API paths:

### Path A: Change Color / Textures

Use when user asks for color/texture/material change without explicit mask image.

```text
POST /change_color_textures
```

### Path B: Material Swap with auto mask

Use when user asks to replace a specific object/material and app can infer label.

1. Create mask:

```text
POST /create_maskimage
```

```swift
CreateMaskImageRequest(
    image: sourceImage,
    labels: parsedLabel // e.g. "sofa", "chair", "table", "wall", "floor"
)
```

2. Swap material:

```text
POST /material_swap
```

```swift
MaterialSwapRequest(
    image: sourceImage,
    maskedImage: maskImage,
    textureImage: textureImage,
    noDesign: 1
)
```

**Codex TODO:**
- Implement a simple local `PromptIntentParser`:

```swift
struct PromptIntentParser {
    func parseObjectLabel(from prompt: String) -> String?
    func parseColor(from prompt: String) -> RGBColor?
    func parseMaterial(from prompt: String) -> String?
}
```

Examples:

```text
"replace sofa with beige leather sofa" -> label: sofa, material/color: beige leather
"change TV wall to marble texture" -> label: wall, material: marble
```

---

## 8.3 RemoveObjectsFlow Module

**Folder:** `Features/RemoveObjectsFlow/`

**PDF pages:** 55, 56, 57, 58, 59

**Purpose:** Remove object by prompt.

**PDF page 55 UI:**
- Title: `Remove Objects`
- Choose your photo
- Gallery / Camera
- Prompt input:
  - `Tailor the prompt with your own instructions to get the exact design you want.`
- Try a sample

**PDF page 56:**
- CTA: `Generate`

**PDF page 57:**
- Loading

**PDF page 58:**
- Result
- Advanced tools:
  - Edit
  - Replace
  - New Walls
  - New Flooring

**State:**

```swift
struct RemoveObjectsDraft {
    var sourceImage: UIImage?
    var prompt: String
    var parsedLabel: String?
}
```

**API Mapping:**

Direct HomeDesignsAI remove flow requires mask.

1. Convert prompt to label:

```text
"remove TV on the wall" -> "tv"
"remove chair near sofa" -> "chair"
```

2. Create mask:

```text
POST /create_maskimage
```

```swift
CreateMaskImageRequest(
    image: sourceImage,
    labels: parsedLabel
)
```

3. Remove object:

```text
POST /furniture_removal
```

```swift
FurnitureRemovalRequest(
    image: sourceImage,
    maskedImage: generatedMaskImage
)
```

**Error handling:**
- If parser cannot detect label, show inline error:
  - `Please describe the object you want to remove, e.g. "remove the TV".`
- If mask generation fails, allow manual retry or prompt edit.

---

## 8.4 NewFlooringFlow Module

**Folder:** `Features/NewFlooringFlow/`

**PDF pages:** 60, 61, 62, 63, 64

**Purpose:** Replace floor material/texture.

**PDF page 60 UI:**
- Title: `New Flooring`
- Choose your photo
- Gallery / Camera
- Prompt input
- Try a sample

**PDF page 61:**
- CTA: `Generate`

**PDF page 62:**
- Loading

**PDF page 63:**
- Result
- Advanced tools:
  - Edit
  - Replace
  - Remove
  - New Walls

**State:**

```swift
struct NewFlooringDraft {
    var sourceImage: UIImage?
    var prompt: String
    var selectedTextureImage: UIImage?
    var parsedMaterial: String?
}
```

**API Mapping:**

```text
POST /floor_editor
```

```swift
FloorEditorRequest(
    image: sourceImage,
    textureImage: selectedTextureImage,
    noOfTexture: 1
)
```

**Implementation notes:**
- PDF only shows prompt input, not texture picker.
- For MVP, implement a small local texture catalog:
  - oak wood
  - walnut wood
  - marble
  - concrete
  - terrazzo
  - tile
- Parse prompt and map to bundled texture image.

Example:

```text
"change floor to oak wood" -> texture: Assets/Textures/Floor/oak_wood.jpg
"replace floor with beige marble" -> texture: Assets/Textures/Floor/beige_marble.jpg
```

---

## 8.5 NewWallsFlow Module

**Folder:** `Features/NewWallsFlow/`

**PDF pages:** 65, 66, 67, 68, 69

**Purpose:** Change wall color or texture.

**PDF page 65 UI:**
- Title: `New Walls`
- Choose your photo
- Gallery / Camera
- Prompt input
- Try a sample

**PDF page 66:**
- CTA: `Generate`

**PDF page 67:**
- Loading

**PDF page 68:**
- Result
- Advanced tools:
  - Edit
  - Replace
  - Remove
  - New Flooring

**State:**

```swift
struct NewWallsDraft {
    var sourceImage: UIImage?
    var prompt: String
    var parsedColor: RGBColor?
    var selectedColorImage: UIImage?
}
```

**API Mapping:**

1. Create wall mask:

```text
POST /create_maskimage
```

```swift
CreateMaskImageRequest(
    image: sourceImage,
    labels: "wall"
)
```

2. Paint visualizer:

```text
POST /paint_visualizer
```

```swift
PaintVisualizerRequest(
    image: sourceImage,
    maskedImage: wallMaskImage,
    rgbColor: parsedColor,
    colorImage: selectedColorImage
)
```

**Implementation notes:**
- For MVP, parse common color names:
  - warm white
  - beige
  - gray
  - concrete gray
  - sage green
  - navy
  - cream
- If texture requested, map to bundled wall texture/color image.

---

## 8.6 FurnitureFinderFlow Module

**Folder:** `Features/FurnitureFinderFlow/`

**PDF page:** 49 / Inspiration detail page 22 lists Furniture Finder as advanced tool

**Purpose:** Find similar furniture from an input image or generated result.

**State:**

```swift
struct FurnitureFinderDraft {
    var sourceImage: UIImage?
    var prompt: String?
}
```

**API Mapping:**

```text
POST /furniture_finder
```

**UI:**
- Input image preview
- Optional prompt/filter
- Loading
- Product result list

**Result item model:**

```swift
struct FurnitureProduct: Codable, Identifiable {
    let id: String
    let title: String
    let imageURL: URL?
    let productURL: URL?
    let priceText: String?
    let sourceName: String?
}
```

---

# 9. AdvancedTools Module

**Folder:** `Features/AdvancedTools/`

**PDF pages:** 34, 37, 38, 39, 41, 42, 49, 53, 54, 58, 59, 63, 64, 68, 69

**Purpose:** Reusable horizontal chip menu shown on result pages.

**Input:**

```swift
struct AdvancedToolsConfig {
    let sourceProjectType: ProjectType
    let availableTools: [AdvancedTool]
    let inputImage: UIImage
}
```

**Tool availability by result source:**

```text
Interior Result:
  Edit, Replace, Remove, New Wall, New Flooring

Exterior Result:
  Edit, Replace, Remove

Reference Style Result:
  Replace, Remove, New Wall, New Flooring, Furniture Finder

Replace Objects Result:
  Edit, Remove, New Walls, New Flooring

Remove Objects Result:
  Edit, Replace, New Walls, New Flooring

New Flooring Result:
  Edit, Replace, Remove, New Walls

New Walls Result:
  Edit, Replace, Remove, New Flooring
```

**Actions:**
- Tap Replace -> `ReplaceObjectsFlow` with current generated image
- Tap Remove -> `RemoveObjectsFlow` with current generated image
- Tap New Wall -> `NewWallsFlow` with current generated image
- Tap New Flooring -> `NewFlooringFlow` with current generated image
- Tap Furniture Finder -> `FurnitureFinderFlow` with current generated image

---

# 10. Shared Components

## 10.1 GenerationCounterBadge

**PDF pages:** 9, 15, 20, 24

Displays:

```text
3/3
PRO
```

State:

```swift
struct GenerationCounterBadgeState {
    let remaining: Int
    let total: Int
    let isPro: Bool
}
```

---

## 10.2 ImageUploadCard

Used by:
- Interior step 1
- Exterior
- Reference source image
- Reference style image
- Replace Objects
- Remove Objects
- New Flooring
- New Walls

Actions:
- Gallery
- Camera
- Sample/template

---

## 10.3 PromptInputView

Used by:
- Exterior
- Replace Objects
- Remove Objects
- New Flooring
- New Walls

Placeholder:

```text
Tailor the prompt with your own instructions to get the exact design you want.
```

---

## 10.4 AIInterventionSelector

Used by:
- Interior
- Reference Style
- Optional Exterior/Garden

Options:
- HIGH
- MEDIUM
- LIGHT

---

## 10.5 ResultActionBar

Buttons:
- Regenerate
- Download
- Share
- Save to archive

---

# 11. Prompt Intent Parser

Create a utility for prompt-based advanced tools.

**Folder:** `Core/Utilities/PromptIntentParser/`

```swift
struct PromptIntent {
    let objectLabel: String?
    let color: RGBColor?
    let materialKeyword: String?
    let textureAssetName: String?
}

final class PromptIntentParser {
    func parse(_ prompt: String, projectType: ProjectType) -> PromptIntent
}
```

## Object label examples

```text
TV -> tv
television -> tv
sofa -> sofa
couch -> sofa
chair -> chair
table -> table
bed -> bed
lamp -> lamp
carpet -> carpet
rug -> rug
cabinet -> cabinet
wall -> wall
floor -> floor
```

## Color examples

```text
white -> RGB(255,255,255)
warm white -> RGB(245,241,232)
beige -> RGB(222,204,177)
gray -> RGB(128,128,128)
concrete gray -> RGB(139,140,135)
sage green -> RGB(156,175,136)
navy -> RGB(20,40,80)
cream -> RGB(245,235,210)
```

## Material examples

```text
oak wood -> floor_oak_wood.jpg
walnut wood -> floor_walnut_wood.jpg
marble -> material_marble.jpg
beige marble -> floor_beige_marble.jpg
concrete -> wall_concrete.jpg
terrazzo -> floor_terrazzo.jpg
tile -> floor_tile.jpg
```

---

# 12. Error / Empty / Edge States

Every generation flow must handle:

```text
- no image selected
- invalid prompt
- free generation limit reached
- API token missing
- upload failed
- API request failed
- queue timeout
- generation failed
- empty output images
- save to photo library denied
```

Suggested error model:

```swift
enum AppGenerationError: Error, LocalizedError {
    case missingImage
    case missingPrompt
    case missingRequiredSelection(String)
    case generationLimitReached
    case apiTokenMissing
    case uploadFailed
    case requestFailed(String)
    case queueTimeout
    case emptyResult
}
```

---

# 13. Free Generation Logic

MVP local logic only.

```swift
protocol GenerationQuotaService {
    var freeGenerationsRemaining: Int { get }
    var isPro: Bool { get }
    func canGenerate() -> Bool
    func consumeOneGenerationIfNeeded()
    func resetForDebug()
}
```

Rules:

```text
if isPro == true:
  allow unlimited
else if freeGenerationsRemaining > 0:
  allow and decrement after successful generation starts or completes
else:
  show Upgrade screen
```

PDF references:
- Home shows `3/3 PRO`
- Upgrade page shows `3/3 Free Generations Left`

---

# 14. PDF Page Mapping Summary

| PDF Page | Screen / Module |
|---:|---|
| 1 | Splash |
| 2 | Welcome |
| 3 | Onboarding Interior Intro |
| 4 | Onboarding Exterior Intro |
| 5 | Onboarding Landscape Intro |
| 6 | Trial Enabled |
| 9 | Home / MainTab |
| 11 | Home tool list / Advanced Editing |
| 15 | Generation Limit / Upgrade |
| 18 | Inspiration Card Detail Visual |
| 19 | Inspiration Card Detail Visual |
| 20 | Inspiration List |
| 21 | Inspiration Filter |
| 22 | Inspiration Detail / Advanced Tools |
| 24 | History Non-empty |
| 25 | History Empty |
| 26 | Settings |
| 27 | Advanced Tool Chips |
| 28 | Interior Step 1 - Start with Photo |
| 29 | Interior Step 1 - Selected State |
| 30 | Interior Step 2 - Room Type |
| 31 | Interior Step 3 - Design Style |
| 32 | Interior Step 4 - AI Intervention |
| 33 | Interior Generating |
| 34 | Interior Result |
| 35 | Exterior Input |
| 36 | Exterior Generating |
| 37 | Exterior Result |
| 38 | Exterior Advanced Tools |
| 39 | Interior/Advanced Tool Chips |
| 40 | Generic Generating |
| 41 | Generic Result |
| 42 | Tool Chips |
| 43 | Reference Style Step 1 |
| 44 | Reference Style Step 1 Selected |
| 45 | Reference Style Step 2 |
| 46 | Reference Style Step 2 Selected |
| 47 | Reference Style AI Intervention |
| 48 | Reference Style Generating |
| 49 | Reference Style Result |
| 50 | Replace Objects Input |
| 51 | Replace Objects Generate CTA |
| 52 | Replace Objects Generating |
| 53 | Replace Objects Result |
| 54 | Replace Objects Advanced Tools |
| 55 | Remove Objects Input |
| 56 | Remove Objects Generate CTA |
| 57 | Remove Objects Generating |
| 58 | Remove Objects Result |
| 59 | Remove Objects Advanced Tools |
| 60 | New Flooring Input |
| 61 | New Flooring Generate CTA |
| 62 | New Flooring Generating |
| 63 | New Flooring Result |
| 64 | New Flooring Advanced Tools |
| 65 | New Walls Input |
| 66 | New Walls Generate CTA |
| 67 | New Walls Generating |
| 68 | New Walls Result |
| 69 | New Walls Advanced Tools |

---

# 15. Figma Mapping

Use this Figma file as visual source when access is available:

```text
https://www.figma.com/design/d6tjcFd5lOKH5UKzVDQA5T/i001_AI-Home-Design?node-id=803-1977&t=ZdJx8iMP1SyrVUUy-0
```

Known Figma node:

```text
fileKey: d6tjcFd5lOKH5UKzVDQA5T
nodeId: 803:1977
```

If Figma connector cannot access the file, implement from PDF page mapping above.

---

# 16. Recommended Implementation Order

1. Core DesignSystem
2. AppCoordinator + MainTab
3. Splash + Onboarding
4. Home
5. PhotoSourcePicker
6. InteriorFlow end-to-end
7. GenerationLoading + Result
8. Local History
9. ExteriorFlow
10. ReferenceStyleFlow
11. RemoveObjectsFlow
12. ReplaceObjectsFlow
13. NewFlooringFlow
14. NewWallsFlow
15. Inspiration + Filters
16. Settings
17. Paywall / quota gate
18. FurnitureFinder

---

# 17. Codex Generation Prompt

Use this prompt when asking Codex to implement:

```text
Implement the iOS app modules from screen.md.
Use each screen as an isolated module/folder under Features/.
Follow the PDF page mapping for visual layout.
Use local-first storage only; no Firebase Auth.
Use HomeDesignsAI APIs directly through HomeDesignsAPIService protocol.
Create reusable components for ImageUploadCard, PromptInputView, AIInterventionSelector, AdvancedToolsView, ResultActionBar, and GenerationCounterBadge.
Implement InteriorFlow first as the complete reference flow, then reuse the pattern for all other generation flows.
```

