# tmux-sessionizer 세션 이름별 검색 루트

날짜: 2026-07-13
브랜치: `worktree-sessionizer-per-session-paths`

## 무엇을 만들었나

tmux-sessionizer 의 fzf 검색 루트를 **현재 tmux 세션 이름(`#S`)에 따라** 바꾸는 구조.
`tmux-session-env.sh` 가 `CLAUDE_CONFIG_DIR` 를 세션별로 세팅하는 것과 동일한
"세션 이름을 키로" 패턴을 sessionizer 에 적용.

- `bunjang` 세션 → `~/Workspace/bunjang/git` 검색
- `pp` 세션 → `~/Workspace/pp/git` 검색

`bin/tmux-sessionizer` 의 CONFIG 해석 우선순위:

1. `$TMUX_SESSIONIZER_PATHS` — 명시적 override (기존 동작 유지)
2. `~/.config/tmux-sessionizer/paths.<세션>` — `#S` 기반, 파일이 있으면
3. `~/.config/tmux-sessionizer/paths` — 기본 폴백

세션 이름은 `tmux-session-env.sh` 와 동일하게 sanitize (빈 값·`*/*`·`.`·`..` 거부)
→ `paths.$sess` 경로가 config 디렉터리를 벗어나지 못하게 함. tmux 밖(`#S` 없음)이거나
매칭 파일이 없으면 기본 `paths` 로 폴백.

파일 편입:

- **`bin/tmux-sessionizer`** — `~/.local/bin` 에 있던 스크립트를 저장소로 옮김
  (이미 PATH 에 있음).
- **`configs/tmux-sessionizer/{paths,paths.bunjang,paths.pp,paths.hs}`** — 기본 +
  세션별 검색 루트 목록.
- **`init.sh`** — `~/.local/bin/tmux-sessionizer` 파일 링크 + `~/.config/tmux-sessionizer`
  디렉터리 링크 배선 (기존 백업 패턴 재사용).

## 왜 이렇게 했나 (diff 에 안 드러나는 결정들)

- **환경변수로 안 하고 sessionizer 가 직접 `#S` 를 조회하는 이유**: 바인딩이
  `bind-key f run-shell "tmux neww ~/.local/bin/tmux-sessionizer"` 인데,
  `tmux neww <cmd>` 는 명령을 **셸을 거치지 않고 직접** 실행한다. 그래서 `profiles/*`
  가 source 되지 않아, `configs/tmux-sessions/<세션>.sh` 안에서
  `export TMUX_SESSIONIZER_PATHS=...` 를 해도 sessionizer 에 전달되지 않는다.
  결국 sessionizer 가 스스로 `tmux display-message -p '#S'` 를 호출해야 한다.
- **디렉터리 규칙(`~/Workspace/<세션>/git`)을 하드코딩하지 않은 이유**: Workspace
  레이아웃이 1:1 로 대응하지만, 한 세션이 여러/특이한 루트를 가질 여지를 위해
  세션별 paths 파일로 표현. (규칙 폴백은 채택하지 않음 — paths 파일 방식만.)
- **스크립트를 `~/.local/bin` 그대로 두지 않고 저장소 `bin/` 으로 옮긴 이유**:
  버전 관리 대상으로 편입 + `tmux.conf`, `aerospace.toml` 과 동일한
  "저장소가 원본, init.sh 가 심볼릭 링크" 패턴 일관성. 바인딩은 `~/.local/bin/...`
  를 계속 가리키므로(그리로 심볼릭 링크) tmux.conf 는 변경 불필요.
- **config 를 파일 단위가 아니라 디렉터리(`~/.config/tmux-sessionizer`) 통째로 링크**:
  `paths.<세션>` 파일들이 여러 개라 디렉터리 링크가 깔끔.

## 검증

실제 `bin/tmux-sessionizer` 를 `bash -x` + tmux/fzf 모킹으로 구동해 CONFIG 해석 확인:

- 세션 `bunjang` (paths.bunjang 존재) → `paths.bunjang`
- 세션 `pp` (파일 없음) → 기본 `paths`
- 빈 세션(tmux 밖) → 기본 `paths`
- 세션 이름에 `/` 포함 → 기본 `paths` (경로 탈출 방지)
- `$TMUX_SESSIONIZER_PATHS` 설정 → 세션 무관하게 그 값

## 병합 후 수동 단계

`init.sh` 는 `~/.zshrc`·홈 심볼릭 링크를 수정하므로 이 작업에서 실행하지 않음.
메인 체크아웃에서 `./init.sh` 직접 실행 → 기존 `~/.local/bin/tmux-sessionizer`,
`~/.config/tmux-sessionizer` 는 `.bak` 로 백업 후 심볼릭 링크됨.

## 알려진 한계

- 새 계정 추가 시 `configs/tmux-sessionizer/paths.<이름>` 파일을 손으로 추가해야 함
  (기존 `configs/tmux-sessions/<이름>.sh` 추가와 마찬가지).
- 세션 이름과 검색 루트의 매핑이 두 곳(paths.<세션>, tmux-sessions/<세션>.sh)에
  나뉘어 있음 — 의도적 분리지만 세션 하나 늘릴 때 파일 두 개를 건드리게 됨.

## 관련

- [[tmux-session-env-loader]] — 같은 "세션 이름을 키로" 패턴의 환경변수 로더
