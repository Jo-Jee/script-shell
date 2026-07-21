# `toy` workspace 추가 (chabis 패턴)

## 배경
chabis / hs 처럼 컨텍스트별로 분리된 워크스페이스를 하나 더 만든다: `toy`.
"workspace" = 아래 세 조각의 조합이다.

1. `~/Workspace/<name>/git/` — 그 컨텍스트의 git 저장소들이 들어가는 곳. tmux-sessionizer 검색 루트.
2. `~/Workspace/<name>/.claude/` — 기본 `~/.claude` 와 분리된 전용 Claude Code 설정 디렉터리.
3. `configs/tmux-sessions/<name>/` (이 repo) — tmux 세션 이름(`#S`)이 `<name>` 일 때 자동으로 쓰이는 설정.
   - `init.sh` : `profiles/tmux-session-env.sh` 가 `#S == <name>` 일 때 source. `CLAUDE_CONFIG_DIR` 설정.
   - `project_paths.conf` : `bin/tmux-sessionizer` 가 `#S == <name>` 일 때 읽는 검색 루트.

chabis 가 최신 템플릿(`CLAUDE_CONFIG_DIR` 설정 + `mkdir -p` 가드), hs 는 legacy(설정 없음).
그래서 `toy` 는 chabis 를 그대로 따랐다.

## 변경 내용
- 신규 `configs/tmux-sessions/toy/init.sh` — `CLAUDE_CONFIG_DIR="$HOME/Workspace/toy/.claude"` + 없으면 생성.
- 신규 `configs/tmux-sessions/toy/project_paths.conf` — 루트 `~/Workspace/toy/git`.
- `configs/tmux-sessions/project_paths.conf` (fallback) 에 `~/Workspace/toy/git` 한 줄 추가.
- 파일시스템: `~/Workspace/toy/git`, `~/Workspace/toy/.claude` 생성 (repo 밖).

`init.sh`(설치 스크립트), `bin/tmux-sessionizer` 는 **수정 불필요** — 발견은 순전히 디렉터리 이름과
`#S` 매칭으로 이뤄지므로 별도 등록이 없다.

## 사용법
```
tmux new -s toy          # 세션 진입 → toy/init.sh 자동 source, CLAUDE_CONFIG_DIR 격리
prefix+f                 # sessionizer → ~/Workspace/toy/git 하위 repo 목록
```

## 관련
- [[aerospace-option-key-tmux-constraint]]
