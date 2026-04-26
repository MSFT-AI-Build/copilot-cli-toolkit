#!/usr/bin/env bash
# init.sh — Copilot CLI Toolkit 초기 환경 설정
#
# 설치 항목:
#   1. GitHub Copilot CLI  (npm, @github/copilot)
#   2. Azure CLI           (Microsoft 공식 스크립트)
#
# 사용법:
#   ./init.sh              # 전체 설치
#   ./init.sh --check      # 설치 상태만 확인

set -euo pipefail

# ── 헬퍼 ───────────────────────────────────────────────────
info()  { echo "ℹ️  $*"; }
ok()    { echo "✅ $*"; }
warn()  { echo "⚠️  $*"; }
fail()  { echo "❌ $*"; exit 1; }

check_cmd() {
  command -v "$1" &>/dev/null
}

# ── 상태 확인 ──────────────────────────────────────────────
print_status() {
  echo ""
  echo "═══════════════════════════════════════════"
  echo "  Copilot CLI Toolkit — 환경 상태"
  echo "═══════════════════════════════════════════"

  if check_cmd node; then
    ok "Node.js        : $(node --version)"
  else
    warn "Node.js        : 미설치"
  fi

  if check_cmd npm; then
    ok "npm            : v$(npm --version)"
  else
    warn "npm            : 미설치"
  fi

  if check_cmd copilot; then
    ok "Copilot CLI    : $(copilot --version 2>&1 | head -1)"
  else
    warn "Copilot CLI    : 미설치"
  fi

  if check_cmd az; then
    ok "Azure CLI      : $(az version -o tsv 2>/dev/null | head -1)"
  else
    warn "Azure CLI      : 미설치"
  fi

  echo "═══════════════════════════════════════════"
  echo ""
}

# --check: 상태만 확인하고 종료
if [[ "${1:-}" == "--check" ]]; then
  print_status
  exit 0
fi

# ── 사전 조건 확인 ─────────────────────────────────────────
if ! check_cmd node || ! check_cmd npm; then
  fail "Node.js 와 npm 이 필요합니다. 먼저 설치해주세요."
fi

# ── 1. Copilot CLI 설치 (npm) ─────────────────────────────
echo ""
info "GitHub Copilot CLI 설치 확인 중..."

if check_cmd copilot; then
  CURRENT_VER="$(copilot --version 2>&1 | head -1)"
  ok "Copilot CLI 이미 설치됨: ${CURRENT_VER}"
  info "최신 버전으로 업데이트합니다..."
  npm install -g @github/copilot@latest 2>&1 | tail -3
else
  info "Copilot CLI 를 설치합니다..."
  npm install -g @github/copilot@latest 2>&1 | tail -3
fi

if check_cmd copilot; then
  ok "Copilot CLI 설치 완료: $(copilot --version 2>&1 | head -1)"
else
  fail "Copilot CLI 설치에 실패했습니다."
fi

# ── 2. Azure CLI 설치 ─────────────────────────────────────
echo ""
info "Azure CLI 설치 확인 중..."

if check_cmd az; then
  ok "Azure CLI 이미 설치됨: $(az version -o tsv 2>/dev/null | head -1)"
else
  info "Azure CLI 를 설치합니다..."
  curl -sL https://aka.ms/InstallAzureCLIDeb | bash 2>&1 | tail -5

  if check_cmd az; then
    ok "Azure CLI 설치 완료: $(az version -o tsv 2>/dev/null | head -1)"
  else
    fail "Azure CLI 설치에 실패했습니다. 수동으로 설치해주세요: https://aka.ms/InstallAzureCLIDeb"
  fi
fi

# ── 설치 결과 ──────────────────────────────────────────────
print_status

echo "🎉 초기 환경 설정이 완료되었습니다!"
echo ""
echo "다음 단계:"
echo "  1. az login                  # Azure 로그인"
echo "  2. ./copilot_foundry.sh      # Copilot CLI BYOK + OFFLINE_MODE 실행"
echo ""
