# Gmail AI Summarizer

Fetches the last 24 hours of Gmail, summarizes with a local Ollama model, saves the summary to disk, and emails it back to you — runs daily at 7 PM via cron.

## How it works

1. Connects to Gmail over IMAP (SSL)
2. Pulls every email received in the last 24 hours
3. Sends the combined content to `gemma4:e2b` running in Ollama
4. Saves the summary as a Markdown file in `summaries/`
5. Sends the summary back to your Gmail address via SMTP

---

## Setup (on the Ollama machine)

### 1. Transfer the project

From your other machine:
```bash
scp -r /path/to/aiProject user@ollama-machine:~/aiProject
```

### 2. Create a Gmail App Password

> Required because Google blocks plain password login for IMAP/SMTP.

1. Go to myaccount.google.com/security
2. Enable **2-Step Verification** if not already on
3. Search for **App Passwords** → create one named "Email Summarizer"
4. Copy the 16-character password (format: `xxxx xxxx xxxx xxxx`)

### 3. Configure credentials

```bash
cd ~/aiProject
cp .env.example .env
nano .env          # fill in GMAIL_ADDRESS and GMAIL_APP_PASSWORD
```

### 4. Install dependencies

```bash
chmod +x setup.sh
./setup.sh
```

### 5. Test it

```bash
.venv/bin/python gmail_summarizer.py
```

You should see output like:
```
[2026-05-10 19:00:01] Fetching emails from the last 24 hours...
  Found 12 email(s).
  Summarizing with gemma4:e2b via http://localhost:11434...
  Summary saved → /home/you/aiProject/summaries/summary_2026-05-10.md
  Sending summary email...
  Done.
```

---

## Cron job (daily at 7 PM)

```bash
crontab -e
```

Add this line (adjust the path to match where you placed the project):

```
0 19 * * * /home/USER/aiProject/.venv/bin/python /home/USER/aiProject/gmail_summarizer.py >> /home/USER/aiProject/summaries/cron.log 2>&1
```

Replace `USER` with your actual username. Save and exit.

Verify it was added:
```bash
crontab -l
```

---

## Files

| File | Purpose |
|------|---------|
| `gmail_summarizer.py` | Main script |
| `.env` | Your credentials (never commit this) |
| `.env.example` | Template for `.env` |
| `requirements.txt` | Python dependencies |
| `setup.sh` | One-time environment setup |
| `summaries/summary_YYYY-MM-DD.md` | Daily saved summaries |
| `summaries/cron.log` | Cron run log |

---

## Troubleshooting

**IMAP login fails** — Make sure you used an App Password, not your real Gmail password. Also ensure IMAP is enabled: Gmail Settings → See all settings → Forwarding and POP/IMAP → Enable IMAP.

**Ollama timeout** — Large inboxes take time. The script allows up to 10 minutes for the model to respond. If it's still timing out, reduce `BODY_CHAR_LIMIT` in `gmail_summarizer.py`.

**No emails found** — Gmail's IMAP SINCE filter is date-based. If you run this just after midnight, it may catch emails from both today and yesterday but will still apply the precise 24-hour cutoff.
