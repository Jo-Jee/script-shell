# tmux-sessionizer 세션별 검색 루트 (per-session paths)

- Date: 2026-07-13
- Status: Approved

## 배경

두 개의 독립적인 메커니즘이 존재한다.

- **`profiles/tmux-session-env.sh`** — 셸 시작 시 tmux 세션 이름(`#S`)을 읽어
  `configs/tmux-sessions/<세션>.sh` 를 source 한다. 이 파일이 `CLAUDE_CONFIG_DIR`
  등 세션 전용 환경변수를 export 한다. 현재 `bunjang`, `pp`, `hs` 3개.
- **`~/.local/bin/tmux-sessionizer`** — fzf 로 repo/worktree 디렉터리를 골라 tmux
  창/세션으로 점프한다. 검색 루트는 `$TMUX_SESSIONIZER_PATHS` 또는
  `~/.config/tmux-sessionizer/paths` 파일(디렉터리 목록)에서 온다.

두 메커니즘은 서로 연결돼 있지 않다. sessionizer 의 검색 루트는 어느 tmux 세션에
있든 항상 동일한 `paths` 파일에서 온다.

## 목표

sessionizer 의 **검색 루트를 현재 tmux 세션 이름에 따라** 바꾼다. `bunjang` 세션에서는
`~/Workspace/bunjang/git` 를, `pp` 세션에서는 `~/Workspace/pp/git` 를 검색하도록.
`tmux-session-env.sh` 와 동일한 "세션 이름을 키로" 패턴을 sessionizer 에 적용한다.

Workspace 레이아웃이 `~/Workspace/<세션>/git` 로 1:1 대응하지만, 유연성을 위해
디렉터리 규칙을 스크립트에 하드코딩하지 않고 세션별 paths 파일로 표현한다.

## 제약: 왜 환경변수로는 안 되는가

tmux 바인딩은 `bind-key f run-shell "tmux neww ~/.local/bin/tmux-sessionizer"` 이다.
`tmux neww <cmd>` 는 명령을 **셸을 거치지 않고 직접** 실행하므로 `profiles/*` 가
source 되지 않는다. 따라서 `configs/tmux-sessions/<세션>.sh` 안에서
`export TMUX_SESSIONIZER_PATHS=...` 를 해도 sessionizer 에는 전달되지 않는다.
sessionizer 가 **직접** `tmux display-message -p '#S'` 로 세션 이름을 조회해야 한다.

## 설계

### 1. sessionizer 루트 해석 (핵심 변경)

`bin/tmux-sessionizer` 의 CONFIG 결정 로직을 다음 우선순위로 바꾼다.

1. `$TMUX_SESSIONIZER_PATHS` — 명시적 override (기존 동작 유지)
2. `~/.config/tmux-sessionizer/paths.<세션>` — `#S` 기반, **파일이 있으면**
3. `~/.config/tmux-sessionizer/paths` — 기본 폴백

세션 이름은 `tmux-session-env.sh` 와 동일하게 sanitize 한다 (빈 값, `*/*`, `.`, `..`
거부) — `paths.$sess` 경로가 config 디렉터리를 벗어나지 못하게 한다. tmux 밖에서
실행되면(`#S` 없음) 곧바로 기본 `paths` 로 떨어진다. fzf / 이름 파생 / 창·세션 생성
등 이후 로직은 그대로 둔다.

의사 코드:

```bash
if [[ -n $TMUX_SESSIONIZER_PATHS ]]; then
    CONFIG="$TMUX_SESSIONIZER_PATHS"
else
    _base="$HOME/.config/tmux-sessionizer"
    _sess="$(tmux display-message -p '#S' 2>/dev/null)"
    case "$_sess" in
        ""|*/*|.|..) CONFIG="$_base/paths" ;;
        *) [[ -f "$_base/paths.$_sess" ]] && CONFIG="$_base/paths.$_sess" || CONFIG="$_base/paths" ;;
    esac
fi
```

### 2. 파일을 저장소로 편입

- **`bin/tmux-sessionizer`** — 스크립트를 이 위치로 옮긴다 (이미 PATH 에 있고
  `ash`/`ecrd`/`gcl` 와 나란히).
- **`configs/tmux-sessionizer/`** — 새 디렉터리:
  - `paths` — 기본; 세 루트 모두 나열 (`~/Workspace/{bunjang,pp,hs}/git`)
  - `paths.bunjang` → `~/Workspace/bunjang/git`
  - `paths.pp` → `~/Workspace/pp/git`
  - `paths.hs` → `~/Workspace/hs/git`

### 3. init.sh 배선 (기존 심볼릭 링크/백업 패턴 재사용)

- `~/.local/bin/tmux-sessionizer` → `$CURRENT_DIR/bin/tmux-sessionizer` 심볼릭 링크
  (기존 실제 파일은 `.bak` 로 백업). **tmux 바인딩(`~/.local/bin/tmux-sessionizer`)은
  변경 불필요** → tmux.conf 편집 없음.
- `~/.config/tmux-sessionizer` 디렉터리 전체 → `$CURRENT_DIR/configs/tmux-sessionizer`
  심볼릭 링크 (기존 디렉터리는 `.bak` 로 백업).

## 범위 밖 / 후속

- `init.sh` 는 이 작업에서 **실행하지 않는다** (사용자의 `~/.zshrc`·홈 심볼릭 링크를
  수정하며, worktree 에서 실행하면 잘못된 경로를 가리킴). 병합 후 메인 체크아웃에서
  사용자가 직접 실행한다.
- 새 계정 추가 시: `configs/tmux-sessionizer/paths.<이름>` 파일 하나 추가
  (+ 기존 `configs/tmux-sessions/<이름>.sh`).

## 검증

- `paths.bunjang` 존재 + `bunjang` 세션 → CONFIG 가 `paths.bunjang` 로 해석됨.
- 매칭 파일 없는 세션 이름 → 기본 `paths` 로 폴백.
- tmux 밖 실행 → 기본 `paths`.
- `$TMUX_SESSIONIZER_PATHS` 설정 시 → 세션 무관하게 그 값 사용.
- 세션 이름에 `/` 포함 → 폴백(경로 탈출 방지).
