#!/bin/bash

echo "════════════════════════════════════════════════════════"
echo "  BENTOBOX WALLPAPER DEBUG TRACE"
echo "════════════════════════════════════════════════════════"
echo ""

echo "1️⃣  What script is being executed?"
echo "────────────────────────────────────────────────────────"
which set-wallpaper.sh 2>/dev/null || echo "Not in PATH"
echo ""

echo "2️⃣  Script locations in repository:"
echo "────────────────────────────────────────────────────────"
find ~/.local/share/omakub -name "set-wallpaper.sh" -type f 2>/dev/null
echo ""

echo "3️⃣  What path is the script looking for?"
echo "────────────────────────────────────────────────────────"
grep "WALLPAPER_SOURCE_DIR=" ~/.local/share/omakub/omakub/install/desktop/set-wallpaper.sh 2>/dev/null || echo "File not found"
grep "WALLPAPER_SOURCE_DIR=" ~/.local/share/omakub/install/desktop/set-wallpaper.sh 2>/dev/null || echo "File not found"
echo ""

echo "4️⃣  Where are wallpapers ACTUALLY located?"
echo "────────────────────────────────────────────────────────"
echo "Checking: ~/.local/share/omakub/wallpaper/"
ls ~/.local/share/omakub/wallpaper/*.jpg 2>/dev/null && echo "✅ FOUND HERE!" || echo "❌ Not here"
echo ""
echo "Checking: ~/.local/share/omakub/omakub/wallpaper/"
ls ~/.local/share/omakub/omakub/wallpaper/*.jpg 2>/dev/null && echo "✅ FOUND HERE!" || echo "❌ Not here"
echo ""

echo "5️⃣  Repository structure:"
echo "────────────────────────────────────────────────────────"
ls -la ~/.local/share/omakub/ | head -20
echo ""

echo "6️⃣  Current git commit:"
echo "────────────────────────────────────────────────────────"
cd ~/.local/share/omakub && git log -1 --oneline
echo ""

echo "7️⃣  Run the script manually to see exact error:"
echo "────────────────────────────────────────────────────────"
bash -x ~/.local/share/omakub/omakub/install/desktop/set-wallpaper.sh 2>&1 | head -50
echo ""
echo "════════════════════════════════════════════════════════"



