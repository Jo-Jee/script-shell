# tmux 세션 이름별 환경변수 로더

날짜: 2026-06-30
브랜치: `worktree-tmux-session-config`

## 무엇을 만들었나

tmux 세션 이름(`#S`)에 따라 세션 전용 환경변수를 자동 로드하는 구조.

- **`profiles/tmux-session-env.sh`** — dispatcher. 기존 `.zshrc` 의
  `for f in '$REPO/profiles'/*; do source $f; done` 루프에 자동 포함된다.
  tmux 안일 때 세션 이름을 읽어 `configs/tmux-sessions/<세션이름>.sh` 를 source.
- **`configs/tmux-sessions/{bunjang,pp,hs}.sh`** — 세션별 scaffold.
  `bunjang.sh` 는 `CLAUDE_CONFIG_DIR="$HOME/Workspace/bunjang/.claude"` 를 설정
  (없으면 lazy `mkdir -p`).

## 왜 이렇게 했나 (diff 에 안 드러나는 결정들)

- **세션 파일을 `profiles/` 가 아니라 `configs/tmux-sessions/` 에 둔 이유**:
  `profiles/*` 안의 파일은 *모든* 셸에서 source 된다. 세션 파일을 거기 두면
  "세션별" 스코핑이 깨진다. 그래서 별도 디렉터리로 분리.
- **디렉터리 이름을 `sessions` 가 아니라 `tmux-sessions` 로**: 키가 tmux 세션
  이름임을 명시하기 위함.
- **repo 루트를 스크립트 자기 경로(`${${(%):-%x}:A:h:h}`)에서 해석**: `init.sh` 의
  `$CURRENT_DIR` 는 *설치 시점* 변수라 셸 런타임엔 존재하지 않는다. dispatcher 를
  설치 로직과 디커플링하기 위해 스크립트 자신의 위치로 루트를 찾는다. (zsh 전용 구문)
- **`init.sh` 는 손대지 않음**: dispatcher 도 그냥 `profiles/` 안의 파일이라 기존
  source 루프에 자동 포함된다.

## 알려진 한계

- 환경변수는 **셸 시작 시점**에 설정된다. 세션 이름을 나중에 바꿔도 이미 열린 pane 엔
  소급 적용 안 됨 (새 pane 부터 반영). 기존 profile 모델과 동일.
- dispatcher 는 **zsh 전용** (`${(%):-%x}`). bash 에선 동작 안 함 — 단 profiles 는
  zsh 에서 돌아가므로 실사용엔 문제없음.

## 보안 메모

세션 이름에 `/` 가 들어가면 하위경로 source 가 가능했던 점을 리뷰에서 발견.
tmux 가 `..` → `__` 로 치환해 트리 탈출은 막지만 `/` 는 보존하므로, dispatcher 에서
plain basename(`case "$_sess" in ""|*/*|.|..) ;; ...`) 만 허용하도록 가드 추가.

## 사용법

세션 이름 `bunjang`/`pp`/`hs` 로 tmux 를 열고, 해당 scaffold 파일에 `export` 추가.
그 세션의 새 pane 부터 자동 반영. `pp`, `hs` 는 아직 빈 scaffold.
