#!/usr/bin/env bash
# Start both services in this one container (same as localhost):
#   backend  gunicorn -> http://localhost:7860
#   frontend streamlit -> http://localhost:8501  (calls the backend on :7860)
set -uo pipefail
cd "$(dirname "$0")/.."

export OPENAI_API_BASE="${OPENAI_API_BASE:-https://aibe.mygreatlearning.com/openai/v1}"
export OPENAI_BASE_URL="${OPENAI_BASE_URL:-$OPENAI_API_BASE}"

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "!! OPENAI_API_KEY is not set."
  echo "   Add it under repo Settings -> Secrets and variables -> Codespaces,"
  echo "   then rebuild/reopen the Codespace (or 'export OPENAI_API_KEY=... ' for a quick test)."
  exit 1
fi

# --- Backend (background) -------------------------------------------------
echo ">> Starting backend (gunicorn) on :7860"
( cd backend && exec gunicorn -w 1 --timeout 120 -b 0.0.0.0:7860 app:rag_api ) \
  > /tmp/backend.log 2>&1 &
BACKEND_PID=$!
trap 'echo; echo ">> Stopping backend ($BACKEND_PID)"; kill $BACKEND_PID 2>/dev/null' EXIT

# --- Wait for backend health ---------------------------------------------
echo -n ">> Waiting for backend"
for i in $(seq 1 60); do
  if curl -sf http://localhost:7860/ >/dev/null 2>&1; then echo " — up."; break; fi
  if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo " — backend died. Last log lines:"; tail -n 30 /tmp/backend.log; exit 1
  fi
  echo -n "."; sleep 2
done

# --- Frontend (foreground) -----------------------------------------------
echo ">> Starting frontend (streamlit) on :8501"
echo "   Open the forwarded :8501 URL (Ports tab) to use the app."
cd frontend
exec streamlit run app.py \
  --server.port=8501 --server.address=0.0.0.0 --server.enableXsrfProtection=false
