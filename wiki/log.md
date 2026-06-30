## [2026-06-30] init | Wiki initialized
- note: wiki initialization complete

## [2026-06-30] work | AeroSpace 설정 저장소 관리 추가
- moved: ~/.aerospace.toml → configs/aerospace.toml (저장소가 source of truth)
- linked: ~/.aerospace.toml → configs/aerospace.toml (심볼릭 링크)
- modified: init.sh (멱등 심링크 생성 블록 추가, 기존 파일은 .bak 백업)
- created: concepts/aerospace-config-management.md, entities/aerospace.md
- verified: bash -n / ./init.sh 멱등 / aerospace reload-config 정상
