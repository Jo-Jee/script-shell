---
title: tmux 설정 관리
type: concept
created: 2026-06-30
updated: 2026-06-30
sources: []
tags: [tmux, dotfiles, init, symlink]
---

# tmux 설정 관리

이 저장소(`script-shell`)가 [[tmux]] 터미널 멀티플렉서의 설정을 버전 관리하는 방식.
[[aerospace-config-management]]와 동일한 심볼릭 링크 패턴을 따른다.

## 핵심

| 항목 | 위치 |
|------|------|
| 설정 원본(source of truth) | `configs/tmux.conf` (저장소 내부, git 추적) |
| 실제 사용 파일 | `~/.tmux.conf` → 심볼릭 링크 → `configs/tmux.conf` |
| 링크 생성 | `init.sh`의 멱등(idempotent) 블록 |

`configs/tmux.conf`을 편집하면 그것이 곧 `~/.tmux.conf`이고, `git commit`으로 버전 관리된다.

## 왜 심볼릭 링크인가

tmux는 `tmux -f <file>`로 설정 경로를 지정할 수 있지만, 대화형으로 띄우는 셸 세션마다 플래그를 넣을 수는 없다. 인자 없이 실행할 때 tmux는 고정 경로(`~/.tmux.conf` 또는 `~/.config/tmux/tmux.conf`)를 읽으므로, 홈 경로에서 저장소 파일로 거는 **심볼릭 링크**가 [[aerospace]]와 동일하게 가장 단순하고 일관된 방식이다.

설정 내부의 `bind r source-file ~/.tmux.conf`(리로드)와 TPM 초기화(`~/.tmux/plugins/tpm/tpm`)는 `~/.tmux.conf`를 경유하므로 심링크 적용 후에도 그대로 동작한다.

## init.sh 동작

`init.sh`에서 [[aerospace-config-management|aerospace 블록]] 바로 뒤에 추가된 블록:

1. `~/.tmux.conf`이 이미 올바른 심링크면 → 건너뜀 (`이미 링크됨`)
2. 실제 파일이나 다른 심링크가 있으면 → `~/.tmux.conf.bak`으로 백업 후 링크 생성
3. 없으면 → 링크 생성

## 검증

- `bash -n init.sh` → 문법 정상
- 샌드박스(가짜 `HOME`)에서 블록 3회 실행 → 생성 / `이미 링크됨`(멱등) / 기존 파일 `.bak` 백업 모두 정상
- `readlink ~/.tmux.conf` → `configs/tmux.conf`로 해석됨
- 적용은 main 머지 후 저장소 루트에서 `./init.sh` 실행으로 완료

## See Also
- [[tmux]] — 멀티플렉서 본체 및 설정 내용 요약
- [[aerospace-config-management]] — 동일 패턴을 쓰는 윈도우 매니저 설정 관리
