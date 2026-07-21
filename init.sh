#!/bin/bash

ZSHRC="$HOME/.zshrc"
CURRENT_DIR="$(pwd)"

# .zshrc 에 삽입할 블록을 마커로 감싼다.
# 이 마커 덕분에 script-shell 위치를 옮긴 뒤 다시 실행해도
# 옛 경로가 박힌 블록을 통째로 교체할 수 있다(중복/깨진 줄 방지).
BLOCK_BEGIN="# >>> script-shell init >>>"
BLOCK_END="# <<< script-shell init <<<"

LINES_TO_ADD=(
  "export PATH=\"$CURRENT_DIR/bin:\$PATH\""
  "export GIT_CONFIG_GLOBAL=\"$CURRENT_DIR/configs/gitconfig\""
  "for f in '$CURRENT_DIR/profiles'/*; do source \$f; done"
  "export PATH=\"$HOME/.local/bin:\$PATH\""
)

touch "$ZSHRC"

# 기존 마커 블록이 있으면 제거한다(마커 라인 포함).
if grep -Fqx "$BLOCK_BEGIN" "$ZSHRC"; then
  TMP_ZSHRC="$(mktemp)"
  awk -v b="$BLOCK_BEGIN" -v e="$BLOCK_END" '
    $0 == b { skip = 1; next }
    $0 == e { skip = 0; next }
    !skip   { print }
  ' "$ZSHRC" > "$TMP_ZSHRC"
  # 블록 제거로 생긴 끝쪽 빈 줄을 정리한다.
  awk 'NF { last = NR } { lines[NR] = $0 } END { for (i = 1; i <= last; i++) print lines[i] }' "$TMP_ZSHRC" > "$ZSHRC"
  rm -f "$TMP_ZSHRC"
  echo "🔄  기존 블록을 갱신합니다: $CURRENT_DIR"
else
  echo "✅  새 블록을 추가합니다: $CURRENT_DIR"
fi

# 마커 블록을 새로 기록한다.
{
  echo ""
  echo "$BLOCK_BEGIN"
  for LINE in "${LINES_TO_ADD[@]}"; do
    echo "$LINE"
  done
  echo "$BLOCK_END"
} >> "$ZSHRC"

# AeroSpace 설정 심볼릭 링크 (~/.aerospace.toml -> 이 저장소의 configs/aerospace.toml)
AEROSPACE_SRC="$CURRENT_DIR/configs/aerospace.toml"
AEROSPACE_DEST="$HOME/.aerospace.toml"

if [ -L "$AEROSPACE_DEST" ] && [ "$(readlink "$AEROSPACE_DEST")" = "$AEROSPACE_SRC" ]; then
  echo "⚠️  이미 링크됨: $AEROSPACE_DEST"
elif [ -e "$AEROSPACE_DEST" ] || [ -L "$AEROSPACE_DEST" ]; then
  mv "$AEROSPACE_DEST" "$AEROSPACE_DEST.bak"
  ln -s "$AEROSPACE_SRC" "$AEROSPACE_DEST"
  echo "✅  기존 파일 백업($AEROSPACE_DEST.bak) 후 링크 생성: $AEROSPACE_DEST"
else
  ln -s "$AEROSPACE_SRC" "$AEROSPACE_DEST"
  echo "✅  링크 생성: $AEROSPACE_DEST"
fi

# tmux 설정 심볼릭 링크 (~/.tmux.conf -> 이 저장소의 configs/tmux.conf)
TMUX_SRC="$CURRENT_DIR/configs/tmux.conf"
TMUX_DEST="$HOME/.tmux.conf"

if [ -L "$TMUX_DEST" ] && [ "$(readlink "$TMUX_DEST")" = "$TMUX_SRC" ]; then
  echo "⚠️  이미 링크됨: $TMUX_DEST"
elif [ -e "$TMUX_DEST" ] || [ -L "$TMUX_DEST" ]; then
  mv "$TMUX_DEST" "$TMUX_DEST.bak"
  ln -s "$TMUX_SRC" "$TMUX_DEST"
  echo "✅  기존 파일 백업($TMUX_DEST.bak) 후 링크 생성: $TMUX_DEST"
else
  ln -s "$TMUX_SRC" "$TMUX_DEST"
  echo "✅  링크 생성: $TMUX_DEST"
fi

# tmux-sessionizer 스크립트 심볼릭 링크 (~/.local/bin/tmux-sessionizer -> bin/tmux-sessionizer)
# tmux 바인딩(bind f)이 ~/.local/bin/tmux-sessionizer 를 가리키므로 여기 링크한다.
TSZ_SRC="$CURRENT_DIR/bin/tmux-sessionizer"
TSZ_DEST="$HOME/.local/bin/tmux-sessionizer"
mkdir -p "$(dirname "$TSZ_DEST")"

if [ -L "$TSZ_DEST" ] && [ "$(readlink "$TSZ_DEST")" = "$TSZ_SRC" ]; then
  echo "⚠️  이미 링크됨: $TSZ_DEST"
elif [ -e "$TSZ_DEST" ] || [ -L "$TSZ_DEST" ]; then
  mv "$TSZ_DEST" "$TSZ_DEST.bak"
  ln -s "$TSZ_SRC" "$TSZ_DEST"
  echo "✅  기존 파일 백업($TSZ_DEST.bak) 후 링크 생성: $TSZ_DEST"
else
  ln -s "$TSZ_SRC" "$TSZ_DEST"
  echo "✅  링크 생성: $TSZ_DEST"
fi

# sessionizer paths 는 더 이상 ~/.config/tmux-sessionizer 로 링크하지 않는다.
# 이제 tmux-sessionizer 가 자기 심볼릭 링크 경로에서 repo 루트를 찾아
# configs/tmux-sessions/<세션>/project_paths.conf 를 직접 읽는다.
# 과거 설치로 남은 링크가 있으면 정리한다 (실제 디렉터리면 건드리지 않음).
TSZ_CFG_OLD="$HOME/.config/tmux-sessionizer"
if [ -L "$TSZ_CFG_OLD" ]; then
  rm "$TSZ_CFG_OLD"
  echo "🧹  더 이상 쓰지 않는 링크 제거: $TSZ_CFG_OLD"
fi
