# AeroSpace가 Option 키를 점유 → tmux에서 M-* 바인딩 금지

날짜: 2026-07-07 (tmux 세션 목록 키바인딩 작업 중 확인)

## 사실

- AeroSpace(macOS 타일링 WM)는 alt(Option) 키를 글로벌 모디파이어로 사용한다 (aerospace.toml의 `alt-*` 바인딩).
- Option 키 입력은 AeroSpace가 OS 레벨에서 먼저 가로채므로, 터미널/tmux까지 도달하지 않거나 충돌한다.
- 따라서 tmux 키바인딩에서 `M-*`(Meta/Alt) 계열은 사용하지 않는다.

## 배경

- tmux 세션 목록을 프리픽스 없이 여는 키를 고르던 중 `M-s`가 후보로 나왔으나, 위 이유로 기각.
- root 테이블에서 이미 점유된 키: C-h/j/k/l, C-\ (vim-tmux-navigator), C-t (하단 분할), C-Space (프리픽스).
- C-l은 vim-tmux-navigator의 오른쪽 pane 이동이라 세션 목록에 쓸 수 없음.
