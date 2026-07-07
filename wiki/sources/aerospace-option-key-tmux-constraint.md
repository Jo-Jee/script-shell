---
title: AeroSpace Option 키 점유 → tmux M-* 바인딩 금지
type: source
created: 2026-07-07
updated: 2026-07-07
sources: [raw/notes/aerospace-option-key-tmux-constraint.md]
tags: [aerospace, tmux, keybinding, macos, constraint]
---

# AeroSpace Option 키 점유 → tmux M-* 바인딩 금지

2026-07-07, tmux 세션 목록 키바인딩 작업 중 확인된 제약 노트.

## 핵심 주장

- [[aerospace]](macOS 타일링 WM)는 alt(Option) 키를 글로벌 모디파이어로 사용한다 (aerospace.toml의 `alt-*` 바인딩).
- Option 키 입력은 AeroSpace가 OS 레벨에서 먼저 가로채므로, 터미널/[[tmux]]까지 도달하지 않거나 충돌한다.
- **결론: tmux 키바인딩에서 `M-*`(Meta/Alt) 계열은 사용하지 않는다.**

## 배경 — tmux root 테이블 키 예산

- tmux 세션 목록을 프리픽스 없이 여는 키 후보로 `M-s`가 나왔으나 위 이유로 기각.
- root 테이블에서 이미 점유된 키:
  - `C-h/j/k/l`, `C-\` — vim-tmux-navigator
  - `C-t` — 하단 분할
  - `C-Space` — 프리픽스
- `C-l`은 vim-tmux-navigator의 오른쪽 pane 이동이라 다른 용도(세션 목록 등)로 쓸 수 없음.

## See Also
- [[aerospace]] — Option/alt 키를 글로벌 점유하는 윈도우 매니저
- [[tmux]] — 이 제약이 적용되는 키바인딩 대상
