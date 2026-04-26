#!/usr/bin/env bash
# copilot_foundry.sh — Copilot CLI × Microsoft Foundry 연결 스크립트
#
# Copilot CLI 의 BYOK(Bring Your Own Key) 기능을 활용하여
# OFFLINE_MODE 로 Microsoft Foundry 에 호스팅된 Azure OpenAI 모델을 호출합니다.
#
# BYOK + OFFLINE_MODE 조합으로 GitHub 서버를 경유하지 않고
# 조직 내 Microsoft Foundry 엔드포인트에 직접 연결합니다.
#
# .env 파일에서 Azure OpenAI 엔드포인트/키를 읽어
# Copilot CLI 의 BYOK 환경변수를 설정한 뒤 copilot 을 실행합니다.
#
# 사용법:
#   ./copilot_foundry.sh                    # Copilot CLI 인터랙티브 모드
#   ./copilot_foundry.sh -p "질문 내용"     # 프롬프트 직접 전달
#   source copilot_foundry.sh --env-only    # 환경변수만 export (copilot 실행 안 함)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

# ── .env 로드 ──────────────────────────────────────────────
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ .env 파일을 찾을 수 없습니다: $ENV_FILE"
  exit 1
fi

while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" =~ ^# ]] && continue
  key="$(echo "$key" | xargs)"
  value="$(echo "$value" | xargs)"
  declare "$key=$value"
done < "$ENV_FILE"

# 필수 변수 확인
if [[ -z "${AZURE_OPEN_AI_ENDPOINT:-}" ]]; then
  echo "❌ AZURE_OPEN_AI_ENDPOINT 가 .env 에 설정되어 있지 않습니다."
  exit 1
fi

# ── Copilot CLI BYOK 환경변수 구성 (OFFLINE_MODE → Foundry 직접 연결) ──
# 엔드포인트에서 base URL 추출 (쿼리 파라미터·경로 제거)
# 예: https://xxx.cognitiveservices.azure.com/openai/responses?api-version=...
#   → https://xxx.cognitiveservices.azure.com
BASE_URL="${AZURE_OPEN_AI_ENDPOINT}"

# Azure API 버전 추출 (있으면)
API_VERSION=""
if [[ "$AZURE_OPEN_AI_ENDPOINT" =~ api-version=([^&]+) ]]; then
  API_VERSION="${BASH_REMATCH[1]}"
fi

export COPILOT_PROVIDER_BASE_URL="${BASE_URL}"
export COPILOT_PROVIDER_TYPE="azure"
export COPILOT_OFFLINE="true"

# ── 인증: Bearer 토큰 (Entra ID) 우선, 실패 시 API 키 대체 ──
AUTH_LABEL=""

if command -v az &>/dev/null; then
  echo "🔐 Azure CLI 로 Bearer 토큰을 발급합니다..."
  if BEARER_TOKEN=$(az account get-access-token \
        --resource "https://cognitiveservices.azure.com" \
        --query accessToken -o tsv 2>/dev/null); then
    export COPILOT_PROVIDER_BEARER_TOKEN="${BEARER_TOKEN}"
    AUTH_LABEL="Entra ID Bearer Token (az cli)"
  fi
fi

if [[ -z "${AUTH_LABEL}" && -n "${AZURE_OPEN_AI_KEY:-}" ]]; then
  echo "⚠️  Bearer 토큰 발급 불가 — API Key 로 대체합니다."
  export COPILOT_PROVIDER_API_KEY="${AZURE_OPEN_AI_KEY}"
  AUTH_LABEL="API Key"
fi

if [[ -z "${AUTH_LABEL}" ]]; then
  echo "❌ 인증 수단이 없습니다."
  echo "   - az login 으로 Azure 에 로그인하거나"
  echo "   - .env 에 AZURE_OPEN_AI_KEY 를 설정하세요."
  exit 1
fi

# Azure API 버전 설정 (있으면)
if [[ -n "${API_VERSION}" ]]; then
  export COPILOT_PROVIDER_AZURE_API_VERSION="${API_VERSION}"
fi

# Responses API 사용 (엔드포인트 경로에 /responses 포함 시)
if [[ "$AZURE_OPEN_AI_ENDPOINT" == *"/responses"* ]]; then
  export COPILOT_PROVIDER_WIRE_API="responses"
fi

# 모델 설정
export COPILOT_MODEL="${AZURE_OPEN_AI_MODEL:-gpt-5.3-codex}"

# ── 설정 확인 출력 ─────────────────────────────────────────
echo "🔗 Copilot CLI BYOK (OFFLINE_MODE → Microsoft Foundry) 구성 완료"
echo "   COPILOT_OFFLINE              = ${COPILOT_OFFLINE}"
echo "   COPILOT_PROVIDER_TYPE        = ${COPILOT_PROVIDER_TYPE}"
echo "   COPILOT_PROVIDER_BASE_URL    = ${COPILOT_PROVIDER_BASE_URL}"
echo "   COPILOT_PROVIDER_WIRE_API    = ${COPILOT_PROVIDER_WIRE_API:-completions}"
echo "   AUTH                         = ${AUTH_LABEL}"
[[ -n "${API_VERSION}" ]] && \
echo "   COPILOT_PROVIDER_AZURE_API_VERSION = ${API_VERSION}"
[[ -n "${COPILOT_MODEL:-}" ]] && \
echo "   COPILOT_MODEL                = ${COPILOT_MODEL}"
echo ""

# --env-only: 환경변수만 export 하고 copilot 실행 안 함
if [[ "${1:-}" == "--env-only" ]]; then
  echo "💡 환경변수가 설정되었습니다. 'copilot' 을 직접 실행하세요."
  return 0 2>/dev/null || exit 0
fi

# ── Copilot CLI 실행 ───────────────────────────────────────
echo "🚀 Copilot CLI 를 시작합니다..."
echo ""
exec copilot "$@"
