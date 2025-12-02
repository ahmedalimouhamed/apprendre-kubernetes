#!/bin/bash
URL=$1
echo "Testing PHP : $URL"
response=$(curl -s "$URL")
echo "$response" > result.json
echo "Result saved to result.json"