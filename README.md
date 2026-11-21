# aurora-stay-qna

RAG Q&A over AuroraStays hotel policies. Two services:

- **backend/** — Flask API (gunicorn, port **7860**). Loads the `HarishMaths/Hotel-Policy-Embedding`
  model + the prebuilt FAISS index, retrieves policy chunks, and generates grounded answers via the
  Great Learning OpenAI proxy. Endpoints: `/v1/answer`, `/v1/answer_with_relevant_chunks`, `/v1/relevant_chunks`.
- **frontend/** — Streamlit UI (port **8501**) that calls the backend at `http://localhost:7860`.

## Run in GitHub Codespaces

Both services run in the **same** Codespace container, so the frontend's `localhost:7860` reaches
the backend exactly like it did locally.

1. **Add the LLM key as a Codespaces Secret** — repo → Settings → Secrets and variables →
   Codespaces → *New repository secret*: `OPENAI_API_KEY` = your Great Learning proxy key.
   (The proxy base URL is non-secret and already set in `.devcontainer/devcontainer.json`.)
2. **Create a Codespace** — green `Code` button → Codespaces → *Create codespace on main*.
   On create, `.devcontainer/postcreate.sh` installs both services' deps (CPU torch) and
   pre-downloads the embedding model.
3. **Start both services** in the Codespace terminal:
   ```bash
   bash .devcontainer/start.sh
   ```
4. **Open the app** — the **Ports** tab shows 7860 (API) and 8501 (UI). Open the **8501** URL.
   Backend logs: `tail -f /tmp/backend.log`.

> If you run the notebook separately and need the backend URL, use the forwarded **7860** URL
> from the Ports tab.

## Run locally

```bash
# Backend
cd backend
pip install torch --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
export OPENAI_API_KEY=...        # Great Learning proxy key
export OPENAI_API_BASE=https://aibe.mygreatlearning.com/openai/v1
gunicorn -w 1 --timeout 120 -b 0.0.0.0:7860 app:rag_api

# Frontend (separate terminal)
cd frontend
pip install -r requirements.txt
streamlit run app.py --server.port=8501 --server.enableXsrfProtection=false
```
