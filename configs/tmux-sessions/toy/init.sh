# tmux session: toy
# 이 파일은 tmux 세션 이름이 "toy" 일 때 자동으로 source 됩니다.

# toy 전용 Claude Code 설정 디렉터리 (기본 ~/.claude 와 분리)
export CLAUDE_CONFIG_DIR="$HOME/Workspace/toy/.claude"
[ -d "$CLAUDE_CONFIG_DIR" ] || mkdir -p "$CLAUDE_CONFIG_DIR"

# 이 세션 전용 환경변수를 아래에 추가하세요. 예:
#   export AWS_PROFILE="toy"
#   export KUBECONFIG="$HOME/.kube/toy"
