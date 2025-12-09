# NotchDrop - Claude Code Guidelines

MacBook의 노치를 파일 드롭 존으로 변환하는 macOS 유틸리티 앱.

## 빠른 시작

```bash
# Xcode에서 프로젝트 열기
open NotchDrop.xcodeproj

# 빌드 및 실행
# Xcode에서 Command + R
```

## 프로젝트 구조

### 핵심 디렉토리

```
NotchDrop/
├── NotchDrop/              # 메인 소스 코드
│   ├── Assets.xcassets/    # 이미지, 색상 에셋
│   └── *.swift             # Swift 소스 파일들
├── Resources/              # 문서, 스크린샷, 번역
└── NotchDrop.xcodeproj/    # Xcode 프로젝트 설정
```

### 아키텍처 (MVVM + Combine)

프로젝트는 MVVM 패턴과 Combine 프레임워크를 사용한 반응형 아키텍처를 따릅니다.

## 파일별 가이드

### 앱 진입점 및 생명주기

| 파일 | 역할 |
|------|------|
| `main.swift` | 앱 진입점, 전역 상수 정의, PID 관리, 디렉토리 초기화 |
| `AppDelegate.swift` | 앱 생명주기 관리, 화면 변경 감지, 윈도우 컨트롤러 관리 |

### ViewModel (상태 관리)

| 파일 | 역할 |
|------|------|
| `NotchViewModel.swift` | 노치 UI의 핵심 상태 관리 (Status, OpenReason, ContentType enum 정의) |
| `NotchViewModel+Events.swift` | 이벤트 핸들링 로직 (마우스 이동, 클릭, 드래그 이벤트 처리) |
| `TrayDrop.swift` | 파일 트레이 싱글톤, 파일 보관 기간 설정, 만료 파일 정리 |

### View (SwiftUI)

| 파일 | 역할 |
|------|------|
| `NotchView.swift` | 메인 노치 컨테이너, 드래그 감지기, 노치 마스킹 구현 |
| `NotchHeaderView.swift` | 노치 헤더 영역 UI |
| `NotchContentView.swift` | 노치 콘텐츠 영역, contentType에 따른 뷰 전환 |
| `NotchMenuView.swift` | 메뉴 바 통합 UI |
| `NotchSettingsView.swift` | 설정 패널 UI (언어, 자동 시작, 햅틱 피드백) |
| `TrayDrop+View.swift` | 드롭된 파일 목록 표시 |
| `TrayDrop+DropItemView.swift` | 개별 드롭 아이템 UI |
| `Share+View.swift` | 파일 공유 뷰 |

### Window 관리

| 파일 | 역할 |
|------|------|
| `NotchWindow.swift` | NSWindow 커스텀 구현 (투명, 항상 최상단) |
| `NotchWindowController.swift` | 윈도우 컨트롤러, ViewModel과 View 연결 |
| `NotchViewController.swift` | SwiftUI 뷰를 호스팅하는 NSHostingController |

### 데이터 모델

| 파일 | 역할 |
|------|------|
| `TrayDrop+DropItem.swift` | 드롭된 파일 모델 (DropItem struct), Transferable 구현 |
| `Language.swift` | 지원 언어 enum, 언어 변경 및 앱 재시작 로직 |

### 유틸리티 및 Extension

| 파일 | 역할 |
|------|------|
| `PublishedPersist.swift` | 영속 저장소 Property Wrapper (@Persist, @PublishedPersist) |
| `Ext+NSScreen.swift` | 노치 크기 계산, 내장 디스플레이 감지 |
| `Ext+NSAlert.swift` | 에러/재시작 알림 헬퍼 |
| `Ext+NSImage.swift` | 이미지 처리 유틸리티 |
| `Ext+URL.swift` | URL 관련 유틸리티 |
| `Ext+FileProvider.swift` | NSItemProvider 파일 변환, 임시 저장소 복사 |

### 이벤트 처리

| 파일 | 역할 |
|------|------|
| `EventMonitor.swift` | 전역 이벤트 모니터 클래스 |
| `EventMonitors.swift` | 마우스/키보드 이벤트 구독 (싱글톤) |

### 공유 기능

| 파일 | 역할 |
|------|------|
| `Share.swift` | 공유 서비스 통합 (NSSharingService) |

## 핵심 개념

### 노치 상태 (Status)

노치의 세 가지 상태를 이해하려면 `NotchViewModel.swift`의 Status enum을 확인:
- `closed`: 닫힌 상태
- `opened`: 열린 상태
- `popping`: 팝 애니메이션 상태

### 열기 이유 (OpenReason)

노치가 열린 이유를 추적 - `NotchViewModel.swift`의 OpenReason enum 참조:
- `click`: 클릭으로 열림
- `drag`: 파일 드래그로 열림
- `boot`: 앱 시작 시
- `unknown`: 알 수 없음

### 영속 저장소

데이터 저장 방식을 이해하려면 `PublishedPersist.swift` 참조:
- `@Persist`: 기본 영속 저장 Property Wrapper
- `@PublishedPersist`: ObservableObject와 통합된 영속 저장

저장 위치: `~/Documents/NotchDrop/Config/`

### 파일 저장 구조

드롭된 파일 저장 방식 - `TrayDrop+DropItem.swift` 참조:
- 저장 위치: `~/Documents/NotchDrop/CopiedItems/[UUID]/[filename]`
- 파일별 UUID 폴더로 격리
- 만료 시 자동 정리 (`TrayDrop.swift`의 cleanExpiredFiles)

## 주요 의존성

### 내부 프레임워크
- **AppKit**: macOS 네이티브 UI
- **SwiftUI**: 선언적 UI
- **Combine**: 반응형 데이터 흐름
- **QuickLook**: 파일 미리보기

### 외부 라이브러리
- **ColorfulX**: 그라데이션 배경 UI
- **LaunchAtLogin**: 로그인 시 자동 시작
- **OrderedCollections**: 순서 유지 Set

## 코드 스타일

코드 스타일 가이드라인은 `AGENTS.md` 파일을 참조하세요.

### 주요 컨벤션

1. **파일 명명**: PascalCase, Extension은 `+` 사용 (예: `Ext+NSScreen.swift`)
2. **들여쓰기**: 4 스페이스
3. **타입 확장**: 기능별로 별도 파일 분리 (예: `NotchViewModel+Events.swift`)

## 자주 수정되는 영역

### 새 설정 추가
1. `NotchViewModel.swift`에 @PublishedPersist 프로퍼티 추가
2. `NotchSettingsView.swift`에 UI 컨트롤 추가

### 새 언어 지원 추가
1. `Language.swift`의 Language enum에 케이스 추가
2. 해당 언어의 .lproj 폴더 및 Localizable.strings 추가

### 드롭 아이템 동작 수정
1. 데이터 모델: `TrayDrop+DropItem.swift`
2. UI 표시: `TrayDrop+DropItemView.swift`
3. 저장/삭제 로직: `TrayDrop.swift`

### 이벤트 핸들링 수정
1. 이벤트 구독: `EventMonitors.swift`
2. 이벤트 처리: `NotchViewModel+Events.swift`

## 디버깅 팁

### PID 관리
앱이 중복 실행되지 않도록 PID 파일을 사용 - `main.swift` 참조
- 위치: `~/Documents/NotchDrop/ProcessIdentifier`

### 노치 감지
노치가 있는 화면 감지 로직 - `Ext+NSScreen.swift`의 `notchSize` 프로퍼티 참조

### 앱 종료 시 정리
임시 파일 정리 로직 - `AppDelegate.swift`의 `applicationWillTerminate` 참조

## 테스트 방법

현재 별도의 테스트 타겟이 없습니다. 수동 테스트 시:
1. 파일을 노치 영역에 드래그하여 드롭 기능 확인
2. 설정 패널에서 언어/자동시작/보관기간 변경 확인
3. Option 키 + X 버튼으로 파일 삭제 확인

## 빌드 요구사항

- **macOS**: 노치가 있는 MacBook 권장 (없어도 동작)
- **Xcode**: 최신 버전 권장
- **Swift**: 5.9+
- **Deployment Target**: macOS 14.0+

## 관련 문서

- `README.md`: 프로젝트 개요 및 기능 소개
- `AGENTS.md`: Swift 코드 스타일 가이드라인
- `Resources/Privacy.md`: 개인정보 처리방침
- `LICENSE`: MIT 라이선스
