#!/bin/bash

ZSHRC="$HOME/.zshrc"
CURRENT_DIR="$(pwd)"

# 여기에 원하는 문자열을 배열로 추가하세요
LINES_TO_ADD=(
  "export PATH=\"$CURRENT_DIR/bin:\$PATH\""
  "export GIT_CONFIG_GLOBAL=\"$CURRENT_DIR/configs/gitconfig\""
  "for f in '$CURRENT_DIR/profiles'/*; do source \$f; done"
  "export PATH=\"$HOME/.local/bin:\$PATH\""
)

added_any_line=false

for LINE in "${LINES_TO_ADD[@]}"; do
  if ! grep -Fqx "$LINE" "$ZSHRC"; then
    if [ "$added_any_line" = false ]; then
      echo "" >> "$ZSHRC"  # 빈 줄 한 줄 추가
      added_any_line=true
    fi
    echo "$LINE" >> "$ZSHRC"
    echo "✅  추가됨: $LINE"
  else
    echo "⚠️  이미 존재함: $LINE"
  fi
done

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
