---
title: AeroSpace 설정 관리
type: concept
created: 2026-06-30
updated: 2026-06-30
sources: []
tags: [aerospace, dotfiles, init, symlink]
---

# AeroSpace 설정 관리

이 저장소(`script-shell`)가 [[aerospace]] 윈도우 매니저의 설정을 버전 관리하는 방식.

## 핵심

| 항목 | 위치 |
|------|------|
| 설정 원본(source of truth) | `configs/aerospace.toml` (저장소 내부, git 추적) |
| 실제 사용 파일 | `~/.aerospace.toml` → 심볼릭 링크 → `configs/aerospace.toml` |
| 링크 생성 | `init.sh`의 멱등(idempotent) 블록 |

`configs/aerospace.toml`을 편집하면 그것이 곧 `~/.aerospace.toml`이고, `git commit`으로 버전 관리된다.

## 왜 심볼릭 링크인가

같은 저장소가 `gitconfig`은 `GIT_CONFIG_GLOBAL` 환경변수로 가리켜 관리한다(파일은 저장소에 두고 git이 참조). 그러나 **AeroSpace에는 설정 경로를 지정하는 환경변수나 `--config-path` 플래그가 없다.** 고정 경로(`~/.aerospace.toml` 또는 `~/.config/aerospace/aerospace.toml`)만 읽는다. 따라서 환경변수 방식은 불가능하고, 홈 경로에서 저장소 파일로 거는 **심볼릭 링크**가 표준 방식이다.

## init.sh 동작

`init.sh` 끝에 추가된 블록:

1. `~/.aerospace.toml`이 이미 올바른 심링크면 → 건너뜀 (`이미 링크됨`)
2. 실제 파일이나 다른 심링크가 있으면 → `~/.aerospace.toml.bak`으로 백업 후 링크 생성
3. 없으면 → 링크 생성

`reload-config`는 사용자 요청에 따라 `init.sh`에 넣지 않음 — AeroSpace가 다음 실행 시 자동 리로드하거나 수동으로 `aerospace reload-config` 실행.

## 검증

- `bash -n init.sh` → 문법 정상
- `./init.sh` 재실행 → `이미 링크됨` (멱등)
- `aerospace reload-config` → 심링크 경유로 설정 정상 파싱

## See Also
- [[aerospace]] — 윈도우 매니저 본체 및 설정 내용 요약
- [[tmux-session-env-loader]] — 같은 저장소의 또 다른 설정 관리 메커니즘. AeroSpace가 환경변수를 못 써서 심링크를 쓴 것과 대조적으로, tmux 세션별 환경변수는 `profiles/` source 루프를 통해 env var를 동적 주입한다.
