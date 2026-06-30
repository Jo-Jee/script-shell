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
