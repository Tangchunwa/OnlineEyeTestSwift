# 視力測試應用 - 開發者指南

## 專案結構

```
uitest2/
├── Assets.xcassets/         # 應用資源（圖片、顏色等）
├── ContentView.swift        # 主入口視圖
├── WelcomeView.swift        # 歡迎頁面
├── TermsOfAgreementView.swift # 使用條款頁面
├── PermissionManager.swift  # 權限管理
├── VisionTestManager.swift  # 視力測試管理器
├── FaceDistanceManager.swift # 面部距離檢測
├── newVisionTestView.swift  # LogMAR 視力測試視圖
├── newVisionTestViewResult.swift # 視力測試結果視圖
├── MacularDegenerationTestView.swift # 黃斑部測試視圖
├── ColorBlindnessTestView.swift # 色盲測試視圖
├── TestResultsView.swift    # 總測試結果視圖
└── uitest2App.swift         # 應用啓動點
```

## 技術架構

### 1. 視圖結構

```
ContentView
├── WelcomeView
│   └── TermsOfAgreementView
├── TermsOfAgreementView (若需要再次確認)
└── TestFlowView
    ├── PermissionRequestView
    ├── LogMARTestView
    │   └── VisionTestResultView (局部結果)
    ├── MacularDegenerationTestView
    ├── ColorBlindnessTestView
    └── TestResultsView
        └── VisionTestResultView (綜合結果)
```

### 2. 主要功能類

#### VisionTestManager

這是核心測試管理類，負責：
- 跟蹤當前測試級別
- 生成測試字母
- 處理用戶輸入（語音或手動）
- 計算和存儲 LogMAR 結果
- 管理左右眼測試

主要屬性：
- `currentLevel`: 當前測試級別 (0-4)
- `currentEye`: 當前測試的眼睛 (.left 或 .right)
- `rightEyeLogMAR`/`leftEyeLogMAR`: 兩眼的 LogMAR 值
- `testCompleted`: 測試是否完成

主要方法：
- `startRecording()`: 開始語音識別
- `stopRecording()`: 停止語音識別
- `processInputText()`: 處理用戶手動輸入
- `updateCurrentLetters()`: 更新當前級別的字母

#### FaceDistanceManager

負責通過前置相機檢測用戶與設備的距離：
- 使用 ARKit 和面部跟蹤計算距離
- 提供是否在理想測試距離範圍內的狀態

主要屬性：
- `distance`: 當前測量的距離
- `isInIdealRange`: 是否在理想測試距離範圍內 (55-60cm)

主要方法：
- `startCameraDetection()`: 開始相機檢測
- `stopCameraDetection()`: 停止相機檢測

#### PermissionManager

管理應用所需的權限：
- 語音識別權限
- 相機權限

主要屬性：
- `isSpeechAuthorized`: 語音識別權限狀態
- `isCameraAuthorized`: 相機權限狀態
- `allPermissionsGranted`: 是否已獲取所有權限

主要方法：
- `checkSpeechPermission()`: 檢查並請求語音識別權限
- `checkCameraPermission()`: 檢查並請求相機權限

## 關鍵數據流

### 用戶資料

```
WelcomeView (@AppStorage("username")) -> TestResultsView (讀取用戶名)
```

### 視力測試結果

```
LogMARTestView (VisionTestManager 實例) -> 
VisionTestManager.shared (單例) ->
TestResultsView (讀取結果)
```

### 測試流程控制

```
TestFlowView (控制測試流程) -> 
各測試視圖 (通過 onComplete 回調) ->
TestFlowView (進入下一測試) ->
TestResultsView (顯示最終結果)
```

## 擴展指南

### 1. 添加新測試

1. 創建新的測試視圖，例如 `NewEyeTestView.swift`
2. 實現測試邏輯和 UI
3. 在 `TestFlowView` 中添加新的測試步驟
4. 在 `TestResultsView` 中添加結果顯示

### 2. 修改現有測試

#### LogMAR 測試修改

主要文件：
- `VisionTestManager.swift` - 測試邏輯
- `newVisionTestView.swift` - 測試 UI
- `FaceDistanceManager.swift` - 距離檢測

#### 黃斑部測試修改

主要文件：
- `MacularDegenerationTestView.swift` - 包含所有測試邏輯和 UI

#### 色盲測試修改

主要文件：
- `ColorBlindnessTestView.swift` - 包含所有測試邏輯和 UI

### 3. 本地化支持

目前應用支持切換語言，但尚未實現完整的本地化。實現步驟：

1. 添加 `Localizable.strings` 文件
2. 將所有文本替換為使用 `NSLocalizedString` 或 SwiftUI 的 `Text(_:tableName:bundle:comment:)` 初始化

## 測試注意事項

1. **視力測試距離**: 確保 `FaceDistanceManager` 準確測量用戶距離
2. **圖像資源**: 確保所有測試圖像都已添加到 `Assets.xcassets`
3. **權限處理**: 測試不同權限狀態下的應用行為

## 常見問題與解決方案

1. **問題**: 語音識別不準確
   **解決方案**: 調整 `VisionTestManager` 中的語音處理邏輯

2. **問題**: 距離檢測不準確
   **解決方案**: 校準 `FaceDistanceManager` 中的距離計算公式

3. **問題**: 測試流程中斷
   **解決方案**: 檢查 `onComplete` 回調是否正確傳遞和處理 