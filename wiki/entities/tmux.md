---
title: tmux
type: entity
created: 2026-06-30
updated: 2026-06-30
sources: []
tags: [tmux, terminal-multiplexer, tpm, dotfiles]
---

# tmux

터미널 멀티플렉서. 이 환경에는 brew로 `3.6a` 설치됨 (`/opt/homebrew/bin/tmux`).
설정 관리 방식은 [[tmux-config-management]] 참고.

## 설정 요약 (`configs/tmux.conf`)

### 일반 동작
- `allow-passthrough on`, `mode-keys vi` (copy-mode vi 키)
- `escape-time 10` (ESC 지연 제거), `mouse on`, `history-limit 50000`
- `default-terminal "tmux-256color"` + `terminal-features ",xterm-256color:RGB"` (true color)
- `set-clipboard on` (OSC 52로 SSH 클립보드 연동)

### prefix
- 기본 `C-b` 해제 → **`C-Space`**로 변경 (`bind C-Space send-prefix`)
- [[aerospace]]의 모디파이어가 Alt/⌥라 비충돌

### vim-tmux-navigator (seamless 이동)
- `C-h/j/k/l`: nvim 분할 ↔ tmux 페인 간 끊김 없는 포커스 이동 (`is_vim` 프로세스 감지)
- `C-\`: 직전 페인 토글 · copy-mode-vi에도 동일 바인딩

### 페인/창
- `prefix + k`: 화면+스크롤백 클리어 (`C-l` 자리 대체)
- `prefix + v`: 수직 분할, `prefix + h`: 수평 분할 (둘 다 현재 경로 유지)
- `C-t` (prefix 없이): 높이 20짜리 하단 수직 분할
- `prefix + r`: 설정 리로드 (`source-file ~/.tmux.conf`)

### 상태바 — prefix 대기 표시
- prefix 입력 대기 중이면 상태바 전체 색 반전(`#{client_prefix}` 조건) → 고가시성
- `status-left ' #S '` (세션 이름), 페인 보더 active=green / 기타=회색
- 주: 페인 보더는 prefix 토글 시 tmux가 다시 그리지 않아 보더 색으로는 라이브 표시 불가 → 상태바로 처리

### 플러그인 (TPM)
`prefix + I` 설치 / `prefix + U` 업데이트 / `prefix + alt-u` 정리
- `tpm` — 플러그인 매니저
- `tmux-sensible` — 합의된 기본값
- `tmux-yank` — 시스템 클립보드 복사 (pbcopy 자동 감지)
- `tmux-resurrect` — 세션/창/페인 저장·복원 (`capture-pane-contents on`)
- `tmux-continuum` — resurrect 자동화 (`restore on`, 15분마다 자동 저장)
- 마지막 줄: `run '~/.tmux/plugins/tpm/tpm'` (반드시 맨 끝)

## See Also
- [[tmux-config-management]] — 이 설정 파일을 저장소가 관리하는 방식
- [[aerospace]] — 동일 패턴으로 관리되는 윈도우 매니저 (모디파이어 비충돌)
