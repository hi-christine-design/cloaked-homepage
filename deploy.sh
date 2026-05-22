#!/bin/bash
# deploy.sh — push local changes to GitHub and redeploy on Vercel.
# Usage: ./deploy.sh ["commit message"]
# Requires: gh + vercel CLIs signed in (one-time setup).

set -e
cd "$(dirname "$0")"

MSG="${1:-Update cloaked-homepage}"
REPO="https://github.com/hi-christine-design/cloaked-homepage.git"

# 1. Ensure the GitHub remote is configured.
if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$REPO"
fi

# 2. Commit any pending changes.
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git -c user.email="hi.christinechung@gmail.com" -c user.name="Christine Yun" \
      commit -m "$MSG"
fi

# 3. Push to GitHub. First push uses --force to align with the web-uploaded
#    state (local history was created separately from the web upload); after
#    that, --force-with-lease is the safer default and will only overwrite
#    if no one else has pushed in the meantime.
echo "→ Pushing to GitHub…"
if ! git push -u origin main --force-with-lease 2>/dev/null; then
  echo "  histories diverged — using --force to align (first push only)"
  git push -u origin main --force
fi

# 4. Deploy to Vercel production.
echo "→ Deploying to Vercel…"
vercel --prod --yes

cat <<EOF

✓ GitHub:  https://github.com/hi-christine-design/cloaked-homepage
✓ Live:    https://cloaked-homepage.vercel.app
EOF
