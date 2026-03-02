accepts=0; rejects=0;
echo "for accepted"
for file in accepted/*.txt; do
    [ -e "$file" ] || continue
    
    # Use ./parse to tell bash it is in the current folder
    OUTPUT=$(./parse "$file" 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        echo "Testing $file: accepts"
        ((accepts++))
    else
        echo "Testing $file: rejects (Reason: $OUTPUT)"
        ((rejects++))
    fi
done
echo "Accepted: $accepts | Rejected: $rejects"

accepts=0; rejects=0;
echo "from rejected"
for file in rejected/*.txt; do
    [ -e "$file" ] || continue
    
    # Use ./parse to tell bash it is in the current folder
    OUTPUT=$(./parse "$file" 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        echo "Testing $file: accepts"
        ((accepts++))
    else
        echo "Testing $file: rejects (Reason: $OUTPUT)"
        ((rejects++))
    fi
done
echo "Accepted: $accepts | Rejected: $rejects"