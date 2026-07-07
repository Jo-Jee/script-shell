---
title: AeroSpace
type: entity
created: 2026-06-30
updated: 2026-07-07
sources: []
tags: [aerospace, window-manager, macos, tiling-wm]
---

# AeroSpace

macOS용 i3 스타일 타일링 윈도우 매니저 (<https://nikitabobko.github.io/AeroSpace/guide>).
이 환경에는 brew로 `0.20.3-Beta` 설치됨. 설정 관리 방식은 [[aerospace-config-management]] 참고.

## 설정 요약 (`configs/aerospace.toml`)

### 일반 동작
- `config-version = 2`, `start-at-login = true` (로그인 시 자동 실행)
- i3 스타일 트리 정규화 활성화 (flatten containers, opposite-orientation for nested)
- 기본 레이아웃 `tiles`, 방향 `auto` (가로 모니터=가로분할, 세로=세로분할)
- gaps 전부 0 (창 간격/화면 여백 없음)
- 키 매핑 프리셋 `qwerty`
- 모니터 포커스 전환 시 마우스를 해당 모니터 중앙으로 이동
- accordion 레이아웃 여백 1px

### 워크스페이스 (7개, 항상 유지)
`persistent-workspaces = ["M", "BB", "BC", "BH", "SL", "SP", "E"]`

| WS | 용도 | 모니터 강제 배정 |
|----|------|------------------|
| `M` | iTerm | 모니터 2 우선, 없으면 main |
| `BB` | Chrome | 모니터 3 우선, 없으면 main |
| `BC` | Chrome (수동/프로필용) | 모니터 3 우선, 없으면 main |
| `BH` | Chrome (수동/프로필용) | 모니터 3 우선, 없으면 main |
| `SL` | Slack | main |
| `SP` | Spark (메일) | main |
| `E` | 범용 / catch-all | main |

## 제약: Option/alt 키 글로벌 점유

AeroSpace는 alt(Option) 키를 글로벌 모디파이어로 OS 레벨에서 먼저 가로챈다.
따라서 Option 키 입력이 터미널/[[tmux]]까지 도달하지 않거나 충돌하므로,
**tmux 키바인딩에서 `M-*`(Meta/Alt) 계열은 사용 금지**다.
출처: [[aerospace-option-key-tmux-constraint]] (2026-07-07)

### 키바인딩 — main 모드 (모디파이어 = Alt/⌥, tmux `C-Space`와 비충돌)
- `alt-enter`: 새 iTerm 열기
- `alt-slash` / `alt-comma`: tiles / accordion 레이아웃 토글
- `alt-h/j/k/l`: 포커스 이동 (vim 방향) · `alt-shift-h/j/k/l`: 창 이동
- `alt-minus` / `alt-equal`: smart 리사이즈 (∓50)
- 워크스페이스 전환: `alt-1`→M, `alt-2`→SL, `alt-3`→SP, `alt-4`→E, `alt-q`→BB, `alt-w`→BC, `alt-e`→BH
- `alt-shift-{1..4,q,w,e}`: 현재 창을 해당 워크스페이스로 이동(이동 후 따라가기)
- `alt-tab`: 직전 워크스페이스 토글 · `alt-shift-tab`: 워크스페이스를 다음 모니터로
- `alt-shift-space`: 플로팅↔타일 토글 · `alt-shift-f`: 풀스크린
- `alt-shift-;`: service 모드 진입

### 키바인딩 — service 모드 (한 번 실행 후 main 복귀)
- `esc`: 설정 리로드 · `r`: 트리 평탄화(레이아웃 리셋)
- `f`: 플로팅 토글 · `backspace`: 현재 창 빼고 모두 닫기
- `alt-shift-h/j/k/l`: 인접 창과 컨테이너 합치기(join)

### 앱 자동 배치 (`on-window-detected`, 첫 매칭에서 멈춤)
- iTerm → `M`
- Chrome → auto-assign 안 함, `layout tiling`만 (수동 배치, catch-all 회피)
- Slack → `SL`, 세로 아코디언으로 쌓기
- Spark → `SP`, 세로 아코디언으로 쌓기
- 시스템 설정 / 카카오톡 → 플로팅 (원래 크기 유지)
- catch-all(맨 마지막): 위에 안 걸린 앱은 모두 `E`로, 세로 아코디언

## See Also
- [[aerospace-config-management]] — 이 설정 파일을 저장소가 관리하는 방식
- [[tmux]] — Option 키 점유 때문에 M-* 바인딩을 피해야 하는 대상
- [[aerospace-option-key-tmux-constraint]] — Option 키 점유 → tmux M-* 금지 제약 노트
