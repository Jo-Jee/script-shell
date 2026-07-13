---
title: tmux 세션별 환경변수 로딩
type: concept
created: 2026-06-30
updated: 2026-07-13
sources: [raw/notes/2026-06-30/tmux-session-env-loader.md, raw/notes/2026-07-13/sessionizer-per-session-paths.md]
tags: [tmux, zsh, env, dotfiles, profiles, security]
---

# tmux 세션별 환경변수 로딩

이 저장소(`script-shell`)가 [[tmux]] 세션 이름별로 다른 환경변수를 자동 주입하는 방식.

## 구조

| 역할 | 위치 | 설명 |
|------|------|------|
| dispatcher | `profiles/tmux-session-env.sh` | `.zshrc`의 `for f in profiles/*` 루프에 자동 포함. tmux 안이면 세션 이름 읽어 해당 scaffold를 source |
| 세션 scaffold | `configs/tmux-sessions/<세션이름>/init.sh` | 세션 전용 `export` 모음. `bunjang`, `pp`, `hs` 존재. 같은 폴더에 sessionizer 검색 루트 `project_paths.conf` 도 둔다 |

dispatcher는 tmux 세션 이름(`#S`)을 키로 `configs/tmux-sessions/<이름>/init.sh`를 찾아 source 한다. 예: `bunjang` 세션 → `CLAUDE_CONFIG_DIR="$HOME/Workspace/bunjang/.claude"` 설정.

## 설계 포인트

- **스코핑**: 세션 파일을 `profiles/`(모든 셸에서 source)가 아니라 `configs/tmux-sessions/`에 두어 "세션별" 적용을 보장.
- **디커플링**: repo 루트를 `init.sh`의 설치 시점 변수가 아니라 스크립트 자기 경로 `${${(%):-%x}:A:h:h}`(zsh)에서 해석 → dispatcher가 설치 로직과 분리됨.
- **무수정 통합**: dispatcher도 `profiles/`의 파일이라 `init.sh` 변경 없이 기존 source 루프에 자동 편입.
- **보안 가드**: 세션 이름에 `/`가 있으면 하위경로 source가 가능했음 → plain basename만 허용(`case "$_sess" in ""|*/*|.|..) ;;`). tmux가 `..`→`__`로 치환하지만 `/`는 보존하기 때문.

## 한계

- 환경변수는 셸 시작 시점에만 설정 → 이미 열린 pane엔 소급 미적용(새 pane부터).
- dispatcher는 zsh 전용 (`${(%):-%x}`). bash 미지원이나 profiles가 zsh에서 도므로 실사용 무관.

## 같은 저장소의 설정 관리 방식과의 관계

이 저장소는 설정을 관리하는 메커니즘이 여럿이다.

- [[aerospace-config-management]]: 고정 경로만 읽는 AeroSpace를 위해 **심볼릭 링크** 사용.
- gitconfig: `GIT_CONFIG_GLOBAL` **환경변수**로 저장소 파일 가리킴.
- 본 로더: tmux 세션 이름에 따라 `profiles/` source 루프로 **환경변수를 동적 주입**.

세 방식 모두 "설정 원본을 저장소에 두고 git으로 버전 관리한다"는 공통 목표를 다른 통합 지점(심링크 / env var / source 루프)으로 달성한다.

## See Also
- [[tmux-session-env-loader]] (source) — 원본 노트
- [[tmux]] — 세션 이름 제공 주체
- [[aerospace-config-management]] — 심볼릭 링크 기반 설정 관리
