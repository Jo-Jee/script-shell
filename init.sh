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

# tmux-sessionizer paths 디렉터리 심볼릭 링크 (~/.config/tmux-sessionizer -> configs/tmux-sessionizer)
# 세션별 paths.<세션> 파일들이 이 디렉터리에 함께 담긴다.
TSZ_CFG_SRC="$CURRENT_DIR/configs/tmux-sessionizer"
TSZ_CFG_DEST="$HOME/.config/tmux-sessionizer"
mkdir -p "$(dirname "$TSZ_CFG_DEST")"

if [ -L "$TSZ_CFG_DEST" ] && [ "$(readlink "$TSZ_CFG_DEST")" = "$TSZ_CFG_SRC" ]; then
  echo "⚠️  이미 링크됨: $TSZ_CFG_DEST"
elif [ -e "$TSZ_CFG_DEST" ] || [ -L "$TSZ_CFG_DEST" ]; then
  mv "$TSZ_CFG_DEST" "$TSZ_CFG_DEST.bak"
  ln -s "$TSZ_CFG_SRC" "$TSZ_CFG_DEST"
  echo "✅  기존 디렉터리 백업($TSZ_CFG_DEST.bak) 후 링크 생성: $TSZ_CFG_DEST"
else
  ln -s "$TSZ_CFG_SRC" "$TSZ_CFG_DEST"
  echo "✅  링크 생성: $TSZ_CFG_DEST"
fi
