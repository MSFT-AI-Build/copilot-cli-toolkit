# copilot-cli-toolkit

**GitHub Copilot CLI**를 더 효과적으로 활용하기 위한 가이드와 유용한 도구 모음입니다. BYOK(Bring Your Own Key) 연동, 오프라인 모드 설정 등 다양한 시나리오별 스크립트와 샘플을 제공합니다.

## 📁 프로젝트 구성

| 경로 | 설명 |
|---|---|
| `init.sh` | 초기 환경 설정 (Copilot CLI, Azure CLI 설치) |
| `copilot_foundry.sh` | BYOK + OFFLINE_MODE로 Microsoft Foundry 연결 스크립트 |
| `samples/` | Copilot CLI 활용 예제 모음 |
| `.env` | Azure OpenAI 엔드포인트/키 설정 (Git 추적 제외) |
| `AGENTS.md` | AI 에이전트 보안 하네스 가이드라인 |

## 🚀 시작하기

### 1. 초기 환경 설정

```bash
./init.sh          # Copilot CLI + Azure CLI 설치
./init.sh --check  # 설치 상태만 확인
```

### 2. 도구 선택

프로젝트에 포함된 도구 중 필요한 것을 골라 사용하세요.

---

## 🔧 도구: copilot_foundry.sh

Copilot CLI의 **BYOK** 기능과 **OFFLINE_MODE**를 활용하여, **Microsoft Foundry**에 호스팅된 Azure OpenAI 모델에 직접 연결하는 스크립트입니다. GitHub 서버를 경유하지 않고 조직 내 Foundry 엔드포인트로 요청을 보냅니다.

### `.env` 파일 구성

프로젝트 루트에 `.env` 파일을 생성하고 Azure OpenAI 정보를 입력합니다.

```env
AZURE_OPEN_AI_ENDPOINT=https://<리소스명>.cognitiveservices.azure.com/openai/responses?api-version=2025-03-01-preview
AZURE_OPEN_AI_KEY=<API 키 (선택)>
AZURE_OPEN_AI_MODEL=gpt-5.3-codex
```

> `AZURE_OPEN_AI_KEY`는 Azure CLI 인증(`az login`)을 사용할 경우 생략할 수 있습니다.

### 실행 방법

```bash
./copilot_foundry.sh                    # 인터랙티브 모드
./copilot_foundry.sh -p "질문 내용"     # 프롬프트 직접 전달
source copilot_foundry.sh --env-only    # 환경변수만 export (copilot 실행 안 함)
```

### 동작 흐름

1. **`.env` 로드** — `AZURE_OPEN_AI_ENDPOINT`, `AZURE_OPEN_AI_KEY`, `AZURE_OPEN_AI_MODEL`을 읽습니다.
2. **엔드포인트 파싱** — URL에서 Base URL과 `api-version` 파라미터를 추출합니다.
3. **인증 처리** — 아래 우선순위로 인증을 시도합니다:
   - **Entra ID Bearer Token** (우선): `az account get-access-token`으로 토큰 발급
   - **API Key** (대체): `.env`의 `AZURE_OPEN_AI_KEY` 사용
4. **Copilot CLI 환경변수 설정** — 다음 환경변수를 export합니다:
   | 환경변수 | 설명 |
   |---|---|
   | `COPILOT_PROVIDER_BASE_URL` | Azure OpenAI 엔드포인트 Base URL |
   | `COPILOT_PROVIDER_TYPE` | `azure` 고정 |
   | `COPILOT_OFFLINE` | `true` — GitHub 서버 대신 자체 엔드포인트 사용 |
   | `COPILOT_PROVIDER_BEARER_TOKEN` | Entra ID 토큰 (az cli 사용 시) |
   | `COPILOT_PROVIDER_API_KEY` | API 키 (토큰 발급 불가 시) |
   | `COPILOT_PROVIDER_AZURE_API_VERSION` | Azure API 버전 |
   | `COPILOT_PROVIDER_WIRE_API` | `responses` (엔드포인트에 `/responses` 포함 시) |
   | `COPILOT_MODEL` | 사용할 모델명 (기본: `gpt-5.3-codex`) |
5. **Copilot CLI 실행** — `exec copilot "$@"`로 전달된 인자와 함께 실행합니다.

---

## 📋 사전 요구 사항

- **Node.js** 및 **npm**
- **GitHub Copilot CLI** (`@github/copilot`)
- **Azure CLI** (`az`) — Entra ID 인증 사용 시 필요

> `init.sh`를 실행하면 Copilot CLI와 Azure CLI를 자동으로 설치합니다.

## 📄 라이선스

이 프로젝트는 [MIT 라이선스](LICENSE)를 따릅니다.
