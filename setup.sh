#!/usr/bin/env bash
# Run once on the Ollama machine to set up the environment.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Creating virtual environment..."
python3 -m venv "$SCRIPT_DIR/.venv"

echo "==> Installing dependencies..."
"$SCRIPT_DIR/.venv/bin/pip" install --quiet --upgrade pip
"$SCRIPT_DIR/.venv/bin/pip" install --quiet -r "$SCRIPT_DIR/requirements.txt"

echo "==> Locking down file permissions..."
touch "$SCRIPT_DIR/.env"
chmod 600 "$SCRIPT_DIR/.env"
chmod 700 "$SCRIPT_DIR"

echo "==> Done. Next steps:"
echo "  1. cp $SCRIPT_DIR/.env.example $SCRIPT_DIR/.env"
echo "  2. Edit .env with your Gmail address and App Password"
echo "  3. Test: $SCRIPT_DIR/.venv/bin/python $SCRIPT_DIR/gmail_summarizer.py"
echo "  4. Add cron job (see README.md)"
