#!/usr/bin/env bash
# One-time setup when the Codespace is created: install both services' deps
# (CPU-only torch) and pre-download the embedding model so first start is fast.
set -euo pipefail

echo ">> Upgrading pip"
pip install --no-cache-dir --upgrade pip

echo ">> Installing CPU-only torch"
pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

echo ">> Installing backend requirements"
pip install --no-cache-dir -r backend/requirements.txt

echo ">> Installing frontend requirements"
pip install --no-cache-dir -r frontend/requirements.txt

echo ">> Pre-downloading embedding model (HarishMaths/Hotel-Policy-Embedding)"
python -c "from langchain_huggingface import HuggingFaceEmbeddings; HuggingFaceEmbeddings(model_name='HarishMaths/Hotel-Policy-Embedding', model_kwargs={'device':'cpu'}, encode_kwargs={'normalize_embeddings': True})"

echo ">> Setup complete. Start both services with:  bash .devcontainer/start.sh"
