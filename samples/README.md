# 📂 Copilot CLI 활용 예제 모음

GitHub Copilot CLI의 다양한 기능을 실전 예제로 보여주는 샘플 스크립트 모음입니다.
각 스크립트는 **교육 목적**으로 작성되었으며, 실행 전에 내용을 꼭 확인하세요.

---

## 🗂️ 목차

| 스크립트 | 설명 |
|---|---|
| [`git_detective.sh`](git_detective.sh) | **Git 탐정** — Git 히스토리를 분석하고, 버그를 도입한 커밋을 찾고, 요약 리포트를 생성하는 예제 |
| [`one_liner_magic.sh`](one_liner_magic.sh) | **한 줄의 마법** — 코드 생성, 파일 분석, 리팩터링 제안, 테스트 생성 등 강력한 원라이너 패턴 모음 |
| [`fleet_mode_demo.sh`](fleet_mode_demo.sh) | **Fleet 모드 데모** — 병렬 서브에이전트 실행(`/fleet`)으로 대규모 작업을 동시에 처리하는 방법 |
| [`research_automation.sh`](research_automation.sh) | **리서치 자동화** — `/research` 명령으로 라이브러리 조사, 보안 취약점 분석, 기술 비교를 수행하는 예제 |

---

## 🚀 사용 방법

```bash
# 1. 스크립트에 실행 권한이 이미 부여되어 있습니다
ls -la samples/

# 2. 스크립트 내용을 먼저 확인하세요
cat samples/git_detective.sh

# 3. 원하는 명령어를 복사해서 사용하세요
#    (스크립트를 통째로 실행하기보다는 개별 명령어를 참고하는 것을 권장합니다)
```

## ⚠️ 주의사항

- 이 스크립트들은 **교육 및 참고용**입니다. 맹목적으로 실행하지 마세요.
- 일부 명령은 **Copilot CLI가 설치**되어 있어야 동작합니다.
- `copilot` 명령 대신 `github-copilot-cli` 또는 프로젝트 설정에 따라 다른 이름일 수 있습니다.
- 환경에 맞게 경로와 프롬프트를 수정해서 사용하세요.

## 🔗 관련 문서

- [프로젝트 메인 README](../README.md)
- [init.sh — 초기 환경 설정](../init.sh)
- [copilot_foundry.sh — BYOK + Foundry 연결](../copilot_foundry.sh)
