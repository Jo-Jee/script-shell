---
title: tmux 세션별 환경변수 로더
type: source
created: 2026-06-30
updated: 2026-07-13
sources: [raw/notes/2026-06-30/tmux-session-env-loader.md]
tags: [tmux, zsh, env, dotfiles, profiles]
---

# tmux 세션별 환경변수 로더

브랜치 `worktree-tmux-session-config`에서 추가한, tmux 세션 이름(`#S`)에 따라 세션 전용 환경변수를 자동 로드하는 구조에 대한 노트.

## 요약

- **`profiles/tmux-session-env.sh`** — dispatcher. `.zshrc`의 `for f in "$REPO/profiles"/*; do source $f; done` 루프에 자동 포함된다. tmux 안일 때 현재 세션 이름을 읽어 `configs/tmux-sessions/<세션이름>/init.sh`를 source 한다. (※ 파일명은 이후 `<세션이름>.sh` → `<세션이름>/init.sh` 로 정리됨)
- **`configs/tmux-sessions/{bunjang,pp,hs}/init.sh`** — 세션별 scaffold. `bunjang/init.sh`는 `CLAUDE_CONFIG_DIR="$HOME/Workspace/bunjang/.claude"`를 설정(없으면 lazy `mkdir -p`). `pp`, `hs`는 아직 빈 scaffold. 같은 세션 폴더의 `project_paths.conf`는 sessionizer 검색 루트.
- 사용법: 세션 이름 `bunjang`/`pp`/`hs`로 tmux를 열고 해당 scaffold 파일에 `export`를 추가하면, 그 세션의 **새 pane**부터 자동 반영된다.

## 핵심 결정 (diff에 안 드러나는 것들)

- **세션 파일을 `profiles/`가 아니라 `configs/tmux-sessions/`에 둔 이유**: `profiles/*`의 파일은 *모든* 셸에서 source 되므로 거기 두면 "세션별" 스코핑이 깨진다. 그래서 별도 디렉터리로 분리.
- **디렉터리 이름을 `sessions`가 아니라 `tmux-sessions`로**: 키가 tmux 세션 이름임을 명시하기 위함.
- **repo 루트를 스크립트 자기 경로(`${${(%):-%x}:A:h:h}`)에서 해석**: `init.sh`의 `$CURRENT_DIR`는 *설치 시점* 변수라 셸 런타임엔 없다. dispatcher를 설치 로직과 디커플링하려고 스크립트 자신의 위치로 루트를 찾는다 (zsh 전용 구문).
- **`init.sh`는 손대지 않음**: dispatcher도 그냥 `profiles/`의 파일이라 기존 source 루프에 자동 포함된다.

## 보안 가드

세션 이름에 `/`가 들어가면 하위경로 source가 가능했던 점을 리뷰에서 발견. tmux가 `..` → `__`로 치환해 트리 탈출은 막지만 `/`는 보존하므로, dispatcher에서 plain basename만 허용하도록 가드를 추가했다.

> `case "$_sess" in ""|*/*|.|..) ;; ...`

## 알려진 한계

- 환경변수는 **셸 시작 시점**에 설정된다. 세션 이름을 나중에 바꿔도 이미 열린 pane엔 소급 적용되지 않는다(새 pane부터 반영). 기존 profile 모델과 동일.
- dispatcher는 **zsh 전용**(`${(%):-%x}`)이라 bash에선 동작하지 않는다 — 단 profiles 자체가 zsh에서 돌므로 실사용엔 문제없음.

## See Also
- [[tmux-session-env-loader]] — 이 메커니즘의 개념 정리
- [[tmux]] — 세션 이름(`#S`) 제공 주체
- [[aerospace-config-management]] — 같은 저장소의 또 다른 설정 관리 메커니즘
