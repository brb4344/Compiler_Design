accepts=0; rejects=0;
echo "=== Testing ACCEPTED files ==="
for file in test/accepts/*.re; do
    [ -e "$file" ] || continue
    echo "--- $file ---"
    echo "Content:"
    cat "$file"              # FIX: print file content first
    echo ""
    echo "Output:"
    ./parse "$file"
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Result: accepts"
        ((accepts++))
    else
        echo "Result: rejects"
        ((rejects++))
    fi
    echo ""
done
echo "Accepted: $accepts | Rejected: $rejects"

accepts=0; rejects=0;
echo "=== Testing REJECTED files ==="
for file in test/rejects/*.re; do
    [ -e "$file" ] || continue
    echo "--- $file ---"
    echo "Content:"
    cat "$file"              # FIX: print file content first
    echo ""
    echo "Output:"
    ./parse "$file"
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Result: accepts"
        ((accepts++))
    else
        echo "Result: rejects"
        ((rejects++))
    fi
    echo ""
done
echo "Accepted: $accepts | Rejected: $rejects"