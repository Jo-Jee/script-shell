## [2026-06-30] init | Wiki initialized
- note: wiki initialization complete

## [2026-06-30] work | AeroSpace 설정 저장소 관리 추가
- moved: ~/.aerospace.toml → configs/aerospace.toml (저장소가 source of truth)
- linked: ~/.aerospace.toml → configs/aerospace.toml (심볼릭 링크)
- modified: init.sh (멱등 심링크 생성 블록 추가, 기존 파일은 .bak 백업)
- created: concepts/aerospace-config-management.md, entities/aerospace.md
- verified: bash -n / ./init.sh 멱등 / aerospace reload-config 정상

## [2026-06-30] work | tmux 설정 저장소 관리 추가
- moved: ~/.tmux.conf → configs/tmux.conf (저장소가 source of truth, byte-identical 복사)
- linked: ~/.tmux.conf → configs/tmux.conf (심볼릭 링크, aerospace와 동일 패턴)
- modified: init.sh (aerospace 블록 뒤 멱등 심링크 블록 추가, 기존 파일은 .bak 백업)
- created: concepts/tmux-config-management.md, entities/tmux.md
- verified: bash -n / 샌드박스 HOME 멱등 3-케이스 / readlink 해석 정상
- note: 적용은 main 머지 후 저장소 루트에서 ./init.sh 실행 필요

## [2026-06-30] ingest | tmux 세션별 환경변수 로더
- 생성: sources/tmux-session-env-loader.md, concepts/tmux-session-env-loader.md
- 수정: entities/tmux.md (설정+세션로딩 통합), concepts/aerospace-config-management.md, index.md
- note: entities/tmux.md 는 tmux 설정 커밋과 add/add 충돌 → 양쪽 내용 병합

## [2026-07-07] ingest | AeroSpace Option 키 점유 → tmux M-* 금지
- 생성: sources/aerospace-option-key-tmux-constraint.md
- 수정: entities/aerospace.md, entities/tmux.md
