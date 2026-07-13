# tmux-sessionizer 세션 이름별 검색 루트

날짜: 2026-07-13
브랜치: `worktree-sessionizer-per-session-paths` → 후속 정리 `worktree-sessionizer-config-consolidation`

## 무엇을 만들었나

tmux-sessionizer 의 fzf 검색 루트를 **현재 tmux 세션 이름(`#S`)에 따라** 바꾸는 구조.
`tmux-session-env.sh` 가 `CLAUDE_CONFIG_DIR` 를 세션별로 세팅하는 것과 동일한
"세션 이름을 키로" 패턴을 sessionizer 에 적용.

- `bunjang` 세션 → `~/Workspace/bunjang/git` 검색
- `pp` 세션 → `~/Workspace/pp/git` 검색

세션별 설정은 한 디렉터리에 모은다:

```
configs/tmux-sessions/
  project_paths.conf              # 기본/폴백 검색 루트
  <세션>/
    init.sh                       # 세션 전용 env (셸에서 source)
    project_paths.conf            # 세션 전용 sessionizer 검색 루트
```

`bin/tmux-sessionizer` 의 CONFIG 해석 우선순위:

1. `$TMUX_SESSIONIZER_PATHS` — 명시적 override
2. `configs/tmux-sessions/<세션>/project_paths.conf` — `#S` 기반, 파일이 있으면
3. `configs/tmux-sessions/project_paths.conf` — 기본 폴백

세션 이름은 `tmux-session-env.sh` 와 동일하게 sanitize (빈 값·`*/*`·`.`·`..` 거부)
→ config 디렉터리를 벗어나지 못하게 함. tmux 밖(`#S` 없음)이거나 매칭 파일이 없으면
기본 `project_paths.conf` 로 폴백.

파일 편입:

- **`bin/tmux-sessionizer`** — `~/.local/bin` 에 있던 스크립트를 저장소로 옮김.
  자기 심볼릭 링크 경로에서 repo 루트를 찾아 config 를 직접 읽는다(아래 참고).
- **`configs/tmux-sessions/<세션>/{init.sh,project_paths.conf}`** + 기본
  `configs/tmux-sessions/project_paths.conf`.
- **`init.sh`** — `~/.local/bin/tmux-sessionizer` 파일만 심볼릭 링크. (paths 용
  `~/.config/tmux-sessionizer` 링크는 더 이상 만들지 않고, 남아있으면 정리.)

## 왜 이렇게 했나 (diff 에 안 드러나는 결정들)

- **환경변수로 안 하고 sessionizer 가 직접 `#S` 를 조회하는 이유**: 바인딩이
  `bind-key f run-shell "tmux neww ~/.local/bin/tmux-sessionizer"` 인데,
  `tmux neww <cmd>` 는 명령을 **셸을 거치지 않고 직접** 실행한다. 그래서 `profiles/*`
  가 source 되지 않아, 세션 `init.sh` 안에서 `export TMUX_SESSIONIZER_PATHS=...` 를
  해도 sessionizer 에 전달되지 않는다. 결국 sessionizer 가 스스로
  `tmux display-message -p '#S'` 를 호출해야 한다.
- **sessionizer 가 repo 루트를 자기 경로에서 찾는 이유**: config(`project_paths.conf`)
  가 `~/.config` 심볼릭 링크가 아니라 저장소 안(`configs/tmux-sessions/...`)에 있다.
  스크립트는 `~/.local/bin/tmux-sessionizer` 로 심볼릭 링크돼 있으므로, `BASH_SOURCE`
  의 링크 체인을 풀어 실제 경로 → `bin/` 상위 = repo 루트를 구한다. env 로더가
  zsh `${${(%):-%x}:A:h:h}` 로 하는 것과 같은 발상(이쪽은 bash).
- **세션 설정을 `configs/tmux-sessions/<세션>/` 한 폴더로 모은 이유**: 세션 env
  (`init.sh`)와 sessionizer 검색 루트(`project_paths.conf`)가 같은 세션 키를 쓰므로
  한곳에 두는 게 관리하기 쉽다. 예전엔 `tmux-sessions/<세션>.sh` 와
  `tmux-sessionizer/paths.<세션>` 로 흩어져 있었다.
- **스크립트를 저장소 `bin/` 으로 옮긴 이유**: 버전 관리 + `tmux.conf`,
  `aerospace.toml` 과 동일한 "저장소가 원본, init.sh 가 심볼릭 링크" 패턴 일관성.
  바인딩은 `~/.local/bin/...` 를 계속 가리키므로 tmux.conf 변경 불필요.

## 검증

실제 `bin/tmux-sessionizer` 를 `bash -x` + tmux/fzf 모킹으로 구동해 CONFIG 해석 확인:

- 세션 `bunjang` (bunjang/project_paths.conf 존재) → `bunjang/project_paths.conf`
- 세션에 파일 없음 → 기본 `project_paths.conf`
- 빈 세션(tmux 밖) → 기본 `project_paths.conf`
- 세션 이름에 `/` 포함 → 기본 (경로 탈출 방지)
- `$TMUX_SESSIONIZER_PATHS` 설정 → 세션 무관하게 그 값
- 심볼릭 링크 체인을 통해 repo 루트가 올바르게 해석되는지 확인

## 병합 후 수동 단계

`init.sh` 는 `~/.zshrc`·홈 심볼릭 링크를 수정하므로 이 작업에서 실행하지 않음.
메인 체크아웃에서 `./init.sh` 직접 실행 → 스크립트 링크 갱신 + 남아있던
`~/.config/tmux-sessionizer` 링크 정리.

## 알려진 한계

- 새 계정 추가 시 `configs/tmux-sessions/<이름>/` 아래 `init.sh` +
  `project_paths.conf` 를 손으로 추가해야 함(같은 세션 폴더라 한곳에서 끝남).

## 관련

- [[tmux-session-env-loader]] — 같은 "세션 이름을 키로" 패턴의 환경변수 로더
