# tmux 세션 이름별 환경변수 로더 (dispatcher)
#
# 동작: tmux 세션 안에서 셸이 시작되면 세션 이름(#S)을 읽어
#       configs/tmux-sessions/<세션이름>.sh 파일이 있으면 source 한다.
# tmux 밖이거나 매칭 파일이 없으면 아무것도 하지 않는다.

# 이 스크립트 자신의 경로에서 repo 루트를 구한다 (init.sh 설치 시점 변수에 비의존).
#   ${(%):-%x} = source 된 스크립트 경로 -> :A 절대경로 -> :h profiles/ -> :h repo 루트
_repo_root="${${(%):-%x}:A:h:h}"

if [ -n "$TMUX" ]; then
  _sess="$(tmux display-message -p '#S' 2>/dev/null)"
  # plain basename 만 허용 (세션 이름의 '/' 로 하위경로 source 방지)
  case "$_sess" in
    ""|*/*|.|..) ;;
    *)
      _sess_file="$_repo_root/configs/tmux-sessions/$_sess.sh"
      [ -r "$_sess_file" ] && source "$_sess_file"
      ;;
  esac
fi

unset _repo_root _sess _sess_file
