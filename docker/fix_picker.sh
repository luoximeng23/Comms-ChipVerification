#!/bin/bash
# ============================================================
# UCAgent Docker - Picker Build Fix
# Fixes two known issues in v1.0.0:
#   1. /usr/bin/time missing (Picker Makefile dependency)
#   2. SWIG version requirement 4.2.0 -> 4.0 (template compatibility)
# ============================================================
set -e

echo "╔══════════════════════════════════════╗"
echo "║   Picker Build Fix for UCAgent       ║"
echo "╚══════════════════════════════════════╝"
echo ""

FIXED=0

# Fix 1: /usr/bin/time wrapper
if [ ! -f /usr/bin/time ]; then
    echo "[Fix 1] Creating /usr/bin/time wrapper..."
    cat > /usr/bin/time << 'WRAP'
#!/bin/bash
exec "$@"
WRAP
    chmod +x /usr/bin/time
    echo "  Done: /usr/bin/time wrapper created"
    FIXED=1
else
    echo "[Fix 1] /usr/bin/time already exists"
fi

# Fix 2: Lower SWIG version requirement in Picker template
TEMPLATE="/usr/local/share/picker/template/python/CMakeLists.txt"
if [ -f "$TEMPLATE" ] && grep -q "find_package(SWIG 4.2.0 REQUIRED)" "$TEMPLATE" 2>/dev/null; then
    echo "[Fix 2] Patching SWIG version 4.2.0 -> 4.0..."
    sed -i "s/find_package(SWIG 4.2.0 REQUIRED)/find_package(SWIG 4.0 REQUIRED)/" "$TEMPLATE"
    echo "  Done: SWIG version patched in $TEMPLATE"
    FIXED=1
elif [ -f "$TEMPLATE" ]; then
    echo "[Fix 2] SWIG template already patched"
else
    echo "[Fix 2] Picker template not found at $TEMPLATE - skipping"
fi

echo ""
if [ $FIXED -eq 1 ]; then
    echo "=== Fixes applied! Picker export should now work. ==="
else
    echo "=== No fixes needed - already patched. ==="
fi

echo ""
echo "Verify: picker export <your_rtl.v> --rw 1 --sname MyDUT --tdir ./output/ -c -w output.fst"
