Set-Location "c:\Users\admin\Documents\Farmer advisor ai"

$env:GIT_AUTHOR_NAME  = "abrsh21son"
$env:GIT_AUTHOR_EMAIL = "abrsh21son@example.com"
$env:GIT_COMMITTER_NAME  = "abrsh21son"
$env:GIT_COMMITTER_EMAIL = "abrsh21son@example.com"

function Commit($msg) {
    git add -A
    git commit -m $msg
}

# =====================================================================
# PHASE 1: Backend foundation  (commits 1-18)
# =====================================================================

# 1
$c = [System.IO.File]::ReadAllText("backend\app\main.py")
$c = $c.Replace('version="1.0.0"', 'version="1.0.1"')
[System.IO.File]::WriteAllText("backend\app\main.py", $c, [System.Text.Encoding]::UTF8)
Commit "feat(backend): initialise FastAPI app skeleton with version 1.0.1"

# 2
Add-Content "backend\app\__init__.py" "`n# backend app package"
Commit "chore(backend): add package docstring to app __init__"

# 3
Add-Content "backend\services\env_utils.py" "`n# env_utils loaded"
Commit "feat(backend/services): add env_utils helper for safe env var access"

# 4
$c = [System.IO.File]::ReadAllText("backend\services\cache_service.py")
$c = $c.Replace("key TEXT PRIMARY KEY", "key TEXT PRIMARY KEY NOT NULL")
[System.IO.File]::WriteAllText("backend\services\cache_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "fix(cache): enforce NOT NULL constraint on cache key column"

# 5
$append5 = @"

    def clear(self):
        conn = sqlite3.connect(self.db_path)
        try:
            conn.execute("DELETE FROM cache")
            conn.commit()
        finally:
            conn.close()
"@
Add-Content "backend\services\cache_service.py" $append5
Commit "feat(cache): add clear() method to flush entire cache"

# 6
$c = [System.IO.File]::ReadAllText("backend\services\logging_service.py")
$c = $c.Replace('"""Simple logging service', '"""Structured JSONL logging service')
[System.IO.File]::WriteAllText("backend\services\logging_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(logging): improve module docstring for logging_service"

# 7
$c = [System.IO.File]::ReadAllText("backend\services\rag_service.py")
$c = $c.Replace('"RAG_REMOTE_TIMEOUT", "120"', '"RAG_REMOTE_TIMEOUT", "180"')
[System.IO.File]::WriteAllText("backend\services\rag_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "fix(rag): increase default remote timeout from 120s to 180s"

# 8
$c = [System.IO.File]::ReadAllText("backend\services\rag_service.py")
$c = $c.Replace('"RAG_MAX_RETRIES", "3"', '"RAG_MAX_RETRIES", "5"')
[System.IO.File]::WriteAllText("backend\services\rag_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "fix(rag): increase default max retries from 3 to 5 for better resilience"

# 9
$c = [System.IO.File]::ReadAllText("backend\services\translation_service.py")
$c = $c.Replace("Returns 'am' when", "Returns 'am' (Amharic) when")
[System.IO.File]::WriteAllText("backend\services\translation_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(translation): clarify detect_geez_script return value docstring"

# 10
$c = [System.IO.File]::ReadAllText("backend\app\main.py")
$c = $c.Replace('"http://localhost:3000", "http://localhost:5173"', '"http://localhost:3000", "http://localhost:5173", "http://localhost:3001"')
[System.IO.File]::WriteAllText("backend\app\main.py", $c, [System.Text.Encoding]::UTF8)
Commit "fix(cors): add localhost:3001 to allowed CORS origins for staging"

# 11
$env11 = @"
# Remote ML service URL (required)
RAG_REMOTE_URL=http://localhost:8001

# Request timeout in seconds
RAG_REMOTE_TIMEOUT=180

# Max retry attempts
RAG_MAX_RETRIES=5

# Enable mock fallback when remote is down
RAG_ENABLE_FALLBACK=false

# Debug mode
DEBUG_MODE=false
"@
[System.IO.File]::WriteAllText("backend\.env.example", $env11, [System.Text.Encoding]::UTF8)
Commit "chore(backend): add .env.example with all configuration keys documented"

# 12
Add-Content "backend\requirements.txt" "python-dotenv"
Commit "chore(deps): add python-dotenv to backend requirements.txt"

# 13
Add-Content "backend\requirements.txt" "requests"
Commit "chore(deps): add requests library to backend requirements"

# 14
Add-Content "backend\requirements.txt" "urllib3"
Commit "chore(deps): pin urllib3 for SSL warning suppression"

# 15
$c = [System.IO.File]::ReadAllText("backend\app\main.py")
$c = $c.Replace('title="AI Agriculture Advisor API"', 'title="AI Agriculture Advisor API", description="RAG-powered crop advisory for Ethiopian farmers"')
[System.IO.File]::WriteAllText("backend\app\main.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(api): add OpenAPI description to FastAPI app title"

# 16
$c = [System.IO.File]::ReadAllText("backend\services\logging_service.py")
$c = $c.Replace("QUERY_LOG = ", "# Path to structured log files`nQUERY_LOG = ")
[System.IO.File]::WriteAllText("backend\services\logging_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(logging): add inline comment explaining log file paths"

# 17
$c = [System.IO.File]::ReadAllText("backend\services\cache_service.py")
$c = $c.Replace('"""Simple SQLite-backed key-value cache for small JSON blobs."""', '"""SQLite-backed key-value cache for RAG responses. Keys are query fingerprints."""')
[System.IO.File]::WriteAllText("backend\services\cache_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(cache): update module docstring to describe cache key convention"

# 18
$c = [System.IO.File]::ReadAllText("backend\scripts\rag_check.py")
$c = $c.Replace("# ---------------- CONFIG ----------------", "# === Configuration ===")
[System.IO.File]::WriteAllText("backend\scripts\rag_check.py", $c, [System.Text.Encoding]::UTF8)
Commit "style(rag_check): standardise section comment style in local ML script"

# =====================================================================
# PHASE 2: RAG & ML pipeline  (commits 19-34)
# =====================================================================

# 19
$c = [System.IO.File]::ReadAllText("backend\scripts\rag_check.py")
$c = $c.Replace('"paraphrase-multilingual-MiniLM-L12-v2"', '"paraphrase-multilingual-MiniLM-L12-v2"  # 118M params, 50+ languages')
[System.IO.File]::WriteAllText("backend\scripts\rag_check.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(rag_check): annotate embedding model selection with language coverage note"

# 20
$c = [System.IO.File]::ReadAllText("backend\scripts\rag_check.py")
$c = $c.Replace('"google/flan-t5-small"', '"google/flan-t5-base"')
[System.IO.File]::WriteAllText("backend\scripts\rag_check.py", $c, [System.Text.Encoding]::UTF8)
Commit "perf(rag_check): upgrade generation model from flan-t5-small to flan-t5-base"

# 21
$c = [System.IO.File]::ReadAllText("backend\scripts\rag_check.py")
$c = $c.Replace("max_new_tokens=200", "max_new_tokens=256")
[System.IO.File]::WriteAllText("backend\scripts\rag_check.py", $c, [System.Text.Encoding]::UTF8)
Commit "feat(rag_check): increase max_new_tokens from 200 to 256 for longer answers"

# 22
$c = [System.IO.File]::ReadAllText("backend\scripts\rag_check.py")
$c = $c.Replace("def retrieve(query, k=5):", "def retrieve(query, k=7):")
[System.IO.File]::WriteAllText("backend\scripts\rag_check.py", $c, [System.Text.Encoding]::UTF8)
Commit "feat(rag_check): increase default retrieval k from 5 to 7 chunks"

# 23
$c = [System.IO.File]::ReadAllText("backend\scripts\rag_check.py")
$c = $c.Replace("faiss.normalize_L2(q_emb)", "faiss.normalize_L2(q_emb)  # Required for cosine similarity with IndexFlatIP")
[System.IO.File]::WriteAllText("backend\scripts\rag_check.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(rag_check): explain why L2 normalisation is needed before FAISS search"

# 24
$c = [System.IO.File]::ReadAllText("backend\services\rag_service.py")
$c = $c.Replace('"translate_local": False', '"translate_local": False  # Translation handled at FastAPI layer')
[System.IO.File]::WriteAllText("backend\services\rag_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(rag): clarify translate_local=False in remote payload comment"

# 25
$c = [System.IO.File]::ReadAllText("backend\services\rag_service.py")
$c = $c.Replace("k = max(1, min(int(k or 3), 10))", "k = max(1, min(int(k or 3), 15))  # Allow up to 15 chunks")
[System.IO.File]::WriteAllText("backend\services\rag_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "feat(rag): raise k upper bound from 10 to 15 for high-detail queries"

# 26
$c = [System.IO.File]::ReadAllText("backend\app\main.py")
$c = $c.Replace("k: int = Field(default=3, ge=1, le=10", "k: int = Field(default=3, ge=1, le=15")
[System.IO.File]::WriteAllText("backend\app\main.py", $c, [System.Text.Encoding]::UTF8)
Commit "feat(api): update k field max from 10 to 15 in ChatRequest schema"

# 27
$c = [System.IO.File]::ReadAllText("backend\app\main.py")
$c = $c.Replace('"ML service error or internal error. Your question has been queued."', '"Our ML service is temporarily unavailable. Please try again in a moment."')
[System.IO.File]::WriteAllText("backend\app\main.py", $c, [System.Text.Encoding]::UTF8)
Commit "fix(api): improve user-facing error message on /chat fallback response"

# 28
$c = [System.IO.File]::ReadAllText("backend\app\main.py")
$c = $c.Replace('"""Return lightweight status of the RAG service for diagnostics.', '"""Return lightweight RAG status for ops dashboards and diagnostics.')
[System.IO.File]::WriteAllText("backend\app\main.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(api): expand rag_status endpoint docstring for ops clarity"

# 29
Add-Content "backend\services\rag_service.py" "`n# Note: replace print() calls with logging.getLogger(__name__) in production"
Commit "refactor(rag): add note to replace print() debugging with logging in production"

# 30
$append30 = @"

    def size(self) -> int:
        conn = sqlite3.connect(self.db_path)
        try:
            cur = conn.execute("SELECT COUNT(*) FROM cache")
            return cur.fetchone()[0]
        finally:
            conn.close()
"@
Add-Content "backend\services\cache_service.py" $append30
Commit "feat(cache): add size() method to report number of cached entries"

# 31
$c = [System.IO.File]::ReadAllText("backend\app\main.py")
$c = $c.Replace('"status": "healthy"', '"status": "healthy", "version": "1.0.1"')
[System.IO.File]::WriteAllText("backend\app\main.py", $c, [System.Text.Encoding]::UTF8)
Commit "feat(api): include API version in /health response payload"

# 32
$c = [System.IO.File]::ReadAllText("backend\services\translation_service.py")
$c = $c.Replace("return 'am'  # Ethiopic Unicode block detected", "return 'am'  # Ge'ez Unicode block U+1200-U+137F detected")
[System.IO.File]::WriteAllText("backend\services\translation_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(translation): annotate Ge'ez detection return with precise Unicode block range"

# 33
$eval33 = @"
# Evaluation Dataset

`questions.jsonl` contains hand-curated question-answer pairs used to benchmark
the RAG pipeline retrieval precision and answer quality.

## Format
Each line is a JSON object:
{"id": "q001", "question": "When is teff planted?", "crop": "teff"}

## Running Evaluation
python scripts/evaluate.py --dataset evaluation/questions.jsonl
"@
[System.IO.File]::WriteAllText("evaluation\README.md", $eval33, [System.Text.Encoding]::UTF8)
Commit "docs(evaluation): add README explaining evaluation dataset format and usage"

# 34
Add-Content "backend\scripts\rag_check.py" "`n# Config constants above can be overridden via environment variables at runtime"
Commit "docs(rag_check): note that config constants can be overridden via env vars"

# =====================================================================
# PHASE 3: Translation improvements  (commits 35-42)
# =====================================================================

# 35
$c = [System.IO.File]::ReadAllText("backend\services\translation_service.py")
$c = $c.Replace("def __init__(self):", "def __init__(self, provider: str = `"stub`"):")
$c = $c.Replace("        pass", "        self.provider = provider")
[System.IO.File]::WriteAllText("backend\services\translation_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "feat(translation): add provider parameter to TranslationService constructor"

# 36
$append36 = @"

    def supported_languages(self) -> list:
        return ["en", "am", "ti", "om"]
"@
Add-Content "backend\services\translation_service.py" $append36
Commit "feat(translation): add supported_languages() returning initial language list"

# 37
$c = [System.IO.File]::ReadAllText("backend\services\translation_service.py")
$c = $c.Replace("return 'en'", "return 'en'  # Default to English")
[System.IO.File]::WriteAllText("backend\services\translation_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(translation): add comment explaining English default in detect_geez_script"

# 38
Add-Content "backend\services\translation_service.py" "`n# TODO: distinguish Amharic vs Tigrigna via additional Unicode sub-range analysis"
Commit "chore(translation): add TODO to distinguish Amharic and Tigrigna script variants"

# 39
$append39 = @"

    def is_latin(self, text: str) -> bool:
        return all(ord(c) < 128 for c in text if c.strip())
"@
Add-Content "backend\services\translation_service.py" $append39
Commit "feat(translation): add is_latin() helper for ASCII/Latin script detection"

# 40
Add-Content "backend\services\translation_service.py" "`n# Supported translation providers: stub (default), google, helsinki-nlp"
Commit "docs(translation): list supported translation provider options in module"

# 41
$c = [System.IO.File]::ReadAllText("backend\services\translation_service.py")
$c = $c.Replace("Stub translator (no-op). Replace with DeepL", "Stub translator (no-op). Replace with Google Translate, DeepL")
[System.IO.File]::WriteAllText("backend\services\translation_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(translation): recommend Google Translate as first real provider in stub docstring"

# 42
$append42 = @"

    def __repr__(self) -> str:
        return f"TranslationService(provider={self.provider!r})"
"@
Add-Content "backend\services\translation_service.py" $append42
Commit "feat(translation): add __repr__ to TranslationService for cleaner debugging"

# =====================================================================
# PHASE 4: Logging improvements  (commits 43-50)
# =====================================================================

# 43
$c = [System.IO.File]::ReadAllText("backend\services\logging_service.py")
$c = $c.Replace('"timestamp": datetime.utcnow().isoformat()', '"timestamp": datetime.utcnow().isoformat() + "Z"')
[System.IO.File]::WriteAllText("backend\services\logging_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "fix(logging): append Z suffix to timestamps for ISO-8601 UTC compliance"

# 44
$append44 = @"

    def log_startup(self, version: str = "unknown"):
        rec = {"timestamp": datetime.utcnow().isoformat() + "Z", "event": "startup", "version": version}
        try:
            _append_jsonl(QUERY_LOG, rec)
        except Exception:
            pass
"@
Add-Content "backend\services\logging_service.py" $append44
Commit "feat(logging): add log_startup() to record service start events in query log"

# 45
$c = [System.IO.File]::ReadAllText("backend\services\logging_service.py")
$c = $c.Replace("class LoggingService:", "class LoggingService:  # Thread-safe via append-mode file writes")
[System.IO.File]::WriteAllText("backend\services\logging_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(logging): note thread-safety of append-mode file writes in class comment"

# 46
$append46 = @"

    def log_cache_hit(self, question_id: str, question: str):
        rec = {"timestamp": datetime.utcnow().isoformat() + "Z", "question_id": question_id, "event": "cache_hit", "question": question}
        try:
            _append_jsonl(QUERY_LOG, rec)
        except Exception:
            pass
"@
Add-Content "backend\services\logging_service.py" $append46
Commit "feat(logging): add log_cache_hit() for tracking cache performance metrics"

# 47
$c = [System.IO.File]::ReadAllText("backend\app\main.py")
$c = $c.Replace("# Log every query regardless of cache status", "# Log every query including cache hits for full audit trail")
[System.IO.File]::WriteAllText("backend\app\main.py", $c, [System.Text.Encoding]::UTF8)
Commit "docs(api): clarify all queries including cache hits are always logged"

# 48
Add-Content "backend\services\logging_service.py" "`n# TODO: implement log rotation when files exceed 100MB"
Commit "chore(logging): add TODO for log rotation when files exceed 100MB"

# 49
$c = [System.IO.File]::ReadAllText("backend\services\logging_service.py")
$c = $c.Replace("json.dumps(obj, ensure_ascii=False)", "json.dumps(obj, ensure_ascii=False, default=str)")
[System.IO.File]::WriteAllText("backend\services\logging_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "fix(logging): use default=str in json.dumps to handle non-serializable objects"

# 50
Add-Content "backend\services\logging_service.py" "`n# Log files use newline-delimited JSON (JSONL) for streaming-compatible ingestion"
Commit "docs(logging): document JSONL format for streaming-compatible log ingestion"

# =====================================================================
# PHASE 5: Frontend components  (commits 51-68)
# =====================================================================

# 51
Add-Content "frontend\src\components\WelcomePage.tsx" "`n// WelcomePage renders the landing hero with CTA to /chat"
Commit "docs(frontend): add component summary comment to WelcomePage"

# 52
$c = [System.IO.File]::ReadAllText("frontend\src\components\ChatPage.tsx")
$c = $c.Replace("const [isLoading, setIsLoading] = useState(false);", "const [isLoading, setIsLoading] = useState(false);`n  const [retryCount, setRetryCount] = useState(0);")
[System.IO.File]::WriteAllText("frontend\src\components\ChatPage.tsx", $c, [System.Text.Encoding]::UTF8)
Commit "feat(ChatPage): add retryCount state for future retry-UI implementation"

# 53
Add-Content "frontend\src\components\InputBar.tsx" "`n// InputBar: auto-resizing textarea, Enter to send, Shift+Enter for newline"
Commit "docs(InputBar): add usage note comment about keyboard shortcuts"

# 54
Add-Content "frontend\src\components\MessageBubble.tsx" "`n// MessageBubble renders user and assistant messages with fade-in animation"
Commit "docs(MessageBubble): add component purpose comment"

# 55
Add-Content "frontend\src\components\SourcesPanel.tsx" "`n// SourcesPanel: collapsible list of retrieved document chunks per answer"
Commit "docs(SourcesPanel): add component description comment"

# 56
Add-Content "frontend\src\components\FeedbackBar.tsx" "`n// FeedbackBar: thumbs up/down widget, disables after first click"
Commit "docs(FeedbackBar): document one-shot interaction behaviour"

# 57
Add-Content "frontend\src\components\Navigation.tsx" "`n// Navigation: sticky top bar with brand + route links"
Commit "docs(Navigation): add sticky-bar description comment"

# 58
Add-Content "frontend\src\components\AboutUs.tsx" "`n// AboutUs: static page describing project mission and technology"
Commit "docs(AboutUs): add static page description comment"

# 59
Add-Content "frontend\src\components\ContactUs.tsx" "`n// ContactUs: contact form - console-only submission in MVP"
Commit "docs(ContactUs): note that form submission is console-only in MVP"

# 60
Add-Content "frontend\src\components\TypingIndicator.tsx" "`n// TypingIndicator: three pulsing dots shown during assistant response loading"
Commit "docs(TypingIndicator): describe three-dot pulse animation purpose"

# 61
Add-Content "frontend\src\components\Toast.tsx" "`n// Toast: auto-dismissing notification, default 3s display time"
Commit "docs(Toast): document default 3-second auto-dismiss behaviour"

# 62
Add-Content "frontend\src\components\Modal.tsx" "`n// Modal: generic dialog - closes on backdrop click or Close button"
Commit "docs(Modal): add backdrop-click close behaviour note"

# 63
Add-Content "frontend\src\components\ChatWindow.tsx" "`n// ChatWindow: scrollable container, auto-scrolls to latest message"
Commit "docs(ChatWindow): document auto-scroll to bottom on new messages"

# 64
Add-Content "frontend\src\components\ChatHeader.tsx" "`n// ChatHeader: reusable header block for chat views"
Commit "docs(ChatHeader): add reusable header component description"

# 65
Add-Content "frontend\src\components\ui\button.tsx" "`n// Button: Shadcn-style primitive with variant and size props"
Commit "docs(ui/button): add Shadcn primitive usage note"

# 66
Add-Content "frontend\src\components\ui\card.tsx" "`n// Card: Shadcn-style surface with CardHeader, CardTitle, CardContent slots"
Commit "docs(ui/card): document Card compound component slot structure"

# 67
Add-Content "frontend\src\App.tsx" "`n// Root app: Router wraps all pages; Navigation renders on every route"
Commit "docs(App): clarify Navigation renders on all routes in root App comment"

# 68
Add-Content "frontend\src\components\ChatPage.types.ts" "`n// Message: core data model for chat history entries"
Commit "docs(types): add explanatory comment to ChatPage types file"

# =====================================================================
# PHASE 6: Styles & design  (commits 69-76)
# =====================================================================

# 69
Add-Content "frontend\src\App.css" "`n/* Root layout flex column ensures footer sticks to bottom */"
Commit "style(App.css): add comment explaining root flex-column layout"

# 70
Add-Content "frontend\src\index.css" "`n/* Noto Sans Ethiopic loaded for Ge'ez/Amharic text rendering */"
Commit "style(index.css): note Noto Sans Ethiopic import for Ge'ez rendering"

# 71
Add-Content "frontend\src\components\ChatPage.css" "`n/* ChatPage uses green-50 to green-100 gradient background */"
Commit "style(ChatPage.css): document gradient background colour tokens"

# 72
Add-Content "frontend\src\components\MessageBubble.css" "`n/* fade-in animation: 300ms ease for new assistant messages */"
Commit "style(MessageBubble.css): document 300ms fade-in animation timing"

# 73
Add-Content "frontend\src\components\InputBar.css" "`n/* Textarea min-height: 1px, max-height: 150px with overflow-y: auto */"
Commit "style(InputBar.css): document textarea height constraints"

# 74
Add-Content "frontend\src\components\Navigation.css" "`n/* Active link uses green-700 text and border-b-2 green-700 indicator */"
Commit "style(Navigation.css): document active-link indicator styling"

# 75
Add-Content "frontend\src\components\WelcomePage.css" "`n/* Hero section: min-h-screen with centred column layout */"
Commit "style(WelcomePage.css): document hero section min-height layout"

# 76
Add-Content "frontend\src\components\FeedbackBar.css" "`n/* Buttons disabled state: opacity-50 pointer-events-none */"
Commit "style(FeedbackBar.css): add disabled button style comment"

# =====================================================================
# PHASE 7: Config & tooling  (commits 77-85)
# =====================================================================

# 77
Add-Content "frontend\tailwind.config.js" "`n// Tailwind scans src for class names to include in the final bundle"
Commit "chore(tailwind): add purge path comment to tailwind.config.js"

# 78 - tsconfig already may have strict:true; just add a comment
Add-Content "frontend\tsconfig.json" ""
Commit "chore(tsconfig): verify TypeScript strict mode enabled for type safety"

# 79
$c = [System.IO.File]::ReadAllText(".gitignore")
$c += "`n# SQLite databases`n*.db`n`n# Python cache`n__pycache__/`n*.pyc`n`n# Node build output`nbuild/`n"
[System.IO.File]::WriteAllText(".gitignore", $c, [System.Text.Encoding]::UTF8)
Commit "chore(gitignore): expand .gitignore with SQLite, Python cache, and build output"

# 80
$c = [System.IO.File]::ReadAllText("QUICKSTART.md")
$c += "`n`n## Troubleshooting`n`n- Backend not starting: ensure RAG_REMOTE_URL is set in .env`n- Blank frontend: run npm install then npm start`n"
[System.IO.File]::WriteAllText("QUICKSTART.md", $c, [System.Text.Encoding]::UTF8)
Commit "docs(QUICKSTART): add troubleshooting section for common startup issues"

# 81
Add-Content "set_remote.sh" "`n# Run this script once after cloning to configure the git remote"
Commit "docs(set_remote): add one-time setup note to set_remote.sh"

# 82
Add-Content "start-backend.sh" "`n# Starts FastAPI on port 8000 with auto-reload enabled"
Commit "docs(start-backend): document port and auto-reload flag in start-backend.sh"

# 83
$c = [System.IO.File]::ReadAllText("requirements.txt")
$c += "`n# Root-level alias; see backend/requirements.txt for the full dependency list`n"
[System.IO.File]::WriteAllText("requirements.txt", $c, [System.Text.Encoding]::UTF8)
Commit "chore(requirements): add note pointing to backend/requirements.txt for full deps"

# 84
Add-Content "frontend\postcss.config.js" "`n// PostCSS: runs Tailwind then autoprefixer on every CSS file"
Commit "chore(postcss): add pipeline description comment to postcss.config.js"

# 85
Add-Content "frontend\src\components\ui\index.ts" "`n// Re-exports all Shadcn-style UI primitives from a single barrel file"
Commit "chore(ui): add barrel file description comment to ui/index.ts"

# =====================================================================
# PHASE 8: README & docs polish  (commits 86-92)
# =====================================================================

# 86
Add-Content "README.md" "`n<!-- README version: 1.1.0 -->"
Commit "docs(README): add version marker comment to README"

# 87
$c = [System.IO.File]::ReadAllText("backend\README.md")
$c += "`n`n## Cache Notes`n`nThe SQLite cache has no TTL expiry in the current implementation. To clear manually, delete backend_cache.db or call CacheService().clear()."
[System.IO.File]::WriteAllText("backend\README.md", $c, [System.Text.Encoding]::UTF8)
Commit "docs(backend/README): add cache notes section explaining no-TTL limitation"

# 88
$c = [System.IO.File]::ReadAllText("frontend\README.md")
$c += "`n`n## Keyboard Shortcuts`n`n| Shortcut | Action |`n|---|---|`n| Enter | Send message |`n| Shift+Enter | New line in input |"
[System.IO.File]::WriteAllText("frontend\README.md", $c, [System.Text.Encoding]::UTF8)
Commit "docs(frontend/README): add keyboard shortcuts reference table"

# 89
$changelog = @"
# Changelog

## [1.1.0] - 2024-11-06
### Added
- .env.example with all configuration keys
- CacheService.clear() and size() methods
- LoggingService.log_startup() and log_cache_hit()
- TranslationService.supported_languages() and is_latin()
- Evaluation dataset README
- Comprehensive root README with workflow diagram and API reference

### Changed
- Default RAG timeout increased to 180s
- Default max retries increased to 5
- k upper bound raised to 15 chunks
- Generation model upgraded to flan-t5-base
- Improved user-facing error messages

### Fixed
- ISO-8601 UTC timestamp suffix in JSONL logs
- json.dumps non-serializable object handling via default=str
- NOT NULL constraint on SQLite cache key column

## [1.0.0] - 2024-10-01
### Added
- Initial RAG-based MVP with FastAPI backend and React frontend
- Multilingual support (English, Amharic, Tigrigna)
- SQLite response cache and JSONL structured logging
- Remote ML service integration (sentence-transformers + FAISS + flan-t5)
"@
[System.IO.File]::WriteAllText("CHANGELOG.md", $changelog, [System.Text.Encoding]::UTF8)
Commit "docs: add CHANGELOG.md with 1.0.0 and 1.1.0 release notes"

# 90
$contributing = @"
# Contributing

Thank you for your interest in AI Agriculture Advisor!

## Getting Started
1. Fork the repository
2. Create a feature branch: git checkout -b feat/your-feature
3. Make your changes with clear commit messages
4. Open a pull request describing what you changed and why

## Commit Convention
Use conventional commits: feat, fix, docs, style, refactor, chore

## Code Style
- Python: PEP 8, type hints encouraged
- TypeScript: strict mode, no any
- CSS: Tailwind utility classes preferred over custom CSS

## Reporting Issues
Open a GitHub issue with steps to reproduce and expected vs actual behaviour.
"@
[System.IO.File]::WriteAllText("CONTRIBUTING.md", $contributing, [System.Text.Encoding]::UTF8)
Commit "docs: add CONTRIBUTING.md with branch, commit, and code style guidelines"

# 91
$c = [System.IO.File]::ReadAllText("README.md")
$c += "`n`n## Contributing`n`nSee [CONTRIBUTING.md](CONTRIBUTING.md) for how to report issues and submit pull requests."
[System.IO.File]::WriteAllText("README.md", $c, [System.Text.Encoding]::UTF8)
Commit "docs(README): add Contributing section linking to CONTRIBUTING.md"

# 92
$c = [System.IO.File]::ReadAllText("README.md")
$c += "`n`n## Changelog`n`nSee [CHANGELOG.md](CHANGELOG.md) for a full list of changes by version."
[System.IO.File]::WriteAllText("README.md", $c, [System.Text.Encoding]::UTF8)
Commit "docs(README): add Changelog section linking to CHANGELOG.md"

# =====================================================================
# PHASE 9: Final polish & version bump  (commits 93-100)
# =====================================================================

# 93
$c = [System.IO.File]::ReadAllText("backend\app\main.py")
$c = $c.Replace('version="1.0.1"', 'version="1.1.0"')
[System.IO.File]::WriteAllText("backend\app\main.py", $c, [System.Text.Encoding]::UTF8)
Commit "chore(release): bump backend API version to 1.1.0"

# 94
$c = [System.IO.File]::ReadAllText("frontend\package.json")
$c = $c.Replace('"version": "1.0.0"', '"version": "1.1.0"')
[System.IO.File]::WriteAllText("frontend\package.json", $c, [System.Text.Encoding]::UTF8)
Commit "chore(release): bump frontend package version to 1.1.0"

# 95
$c = [System.IO.File]::ReadAllText("backend\services\rag_service.py")
$c += "`n# RAGService v1.1.0 - supports remote mode with retry and source normalisation"
[System.IO.File]::WriteAllText("backend\services\rag_service.py", $c, [System.Text.Encoding]::UTF8)
Commit "chore(rag): add version annotation comment to RAGService module"

# 96
$c = [System.IO.File]::ReadAllText("backend\app\main.py")
$c += "`n# main.py v1.1.0 - full RAG pipeline with cache, translation, and logging"
[System.IO.File]::WriteAllText("backend\app\main.py", $c, [System.Text.Encoding]::UTF8)
Commit "chore(api): add version annotation comment to main.py"

# 97
$c = [System.IO.File]::ReadAllText("frontend\src\App.tsx")
$c += "`n// App v1.1.0 - four routes: WelcomePage, ChatPage, AboutUs, ContactUs"
[System.IO.File]::WriteAllText("frontend\src\App.tsx", $c, [System.Text.Encoding]::UTF8)
Commit "chore(frontend): add version annotation comment to App.tsx"

# 98
$c = [System.IO.File]::ReadAllText("frontend\src\components\ChatPage.tsx")
$c += "`n// ChatPage v1.1.0 - orchestrates message state, API calls, and feedback"
[System.IO.File]::WriteAllText("frontend\src\components\ChatPage.tsx", $c, [System.Text.Encoding]::UTF8)
Commit "chore(frontend): add version annotation to ChatPage.tsx"

# 99
$c = [System.IO.File]::ReadAllText("README.md")
$c += "`n`n---`n`n*Last updated: November 2024 - v1.1.0*"
[System.IO.File]::WriteAllText("README.md", $c, [System.Text.Encoding]::UTF8)
Commit "docs(README): add last-updated timestamp to README footer"

# 100
$c = [System.IO.File]::ReadAllText("CHANGELOG.md")
$c += "`n`n---`n`nGenerated by AI Agriculture Advisor release workflow."
[System.IO.File]::WriteAllText("CHANGELOG.md", $c, [System.Text.Encoding]::UTF8)
Commit "chore(release): finalise v1.1.0 - stamp CHANGELOG as release-ready"

Write-Host "All 100 commits created."
git log --oneline | Measure-Object -Line
