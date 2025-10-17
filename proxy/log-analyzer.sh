#!/bin/bash

# Caddy Log Analyzer for Hephaestus Homelab
# This script helps analyze and format Caddy logs for better readability

LOG_DIR="/data/logs"
OUTPUT_DIR="/data/logs/analysis"

# Create analysis directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Caddy Log Analyzer ===${NC}"
echo "Analyzing logs in: $LOG_DIR"
echo "Output directory: $OUTPUT_DIR"
echo

# Function to analyze JSON logs
analyze_json_logs() {
    local log_file="$1"
    local output_file="$2"
    local service_name="$3"
    
    if [[ -f "$log_file" ]]; then
        echo -e "${GREEN}Analyzing $service_name logs...${NC}"
        
        # Extract key information from JSON logs
        jq -r '
            select(.level == "error") | 
            "\(.ts | strftime("%Y-%m-%d %H:%M:%S")) | ERROR | \(.logger) | \(.msg)"' \
            "$log_file" > "$output_file-errors.txt" 2>/dev/null
        
        # Extract access patterns
        jq -r '
            select(.request != null) | 
            "\(.ts | strftime("%Y-%m-%d %H:%M:%S")) | \(.request.method) | \(.request.uri) | \(.request.remote_ip) | \(.status // "N/A")"' \
            "$log_file" > "$output_file-access.txt" 2>/dev/null
        
        # Count errors by type
        echo "Error Summary for $service_name:"
        jq -r 'select(.level == "error") | .msg' "$log_file" 2>/dev/null | \
            sort | uniq -c | sort -nr | head -10
        
        echo
    else
        echo -e "${YELLOW}Log file $log_file not found${NC}"
    fi
}

# Function to analyze access logs
analyze_access_logs() {
    local log_file="$1"
    local output_file="$2"
    
    if [[ -f "$log_file" ]]; then
        echo -e "${GREEN}Analyzing access logs...${NC}"
        
        # Top IPs
        echo "Top 10 IPs:"
        awk '{print $1}' "$log_file" | sort | uniq -c | sort -nr | head -10
        
        # Top paths
        echo -e "\nTop 10 paths:"
        awk '{print $7}' "$log_file" | sort | uniq -c | sort -nr | head -10
        
        # Status codes
        echo -e "\nStatus code distribution:"
        awk '{print $9}' "$log_file" | sort | uniq -c | sort -nr
        
        echo
    fi
}

# Analyze different log files
echo -e "${BLUE}=== Global Caddy Logs ===${NC}"
analyze_json_logs "$LOG_DIR/caddy.json" "$OUTPUT_DIR/global" "Global"

echo -e "${BLUE}=== Error Logs ===${NC}"
analyze_json_logs "$LOG_DIR/caddy-errors.json" "$OUTPUT_DIR/errors" "Global Errors"

echo -e "${BLUE}=== Main Domain Logs ===${NC}"
analyze_json_logs "$LOG_DIR/chrislawrence-ca.json" "$OUTPUT_DIR/main-domain" "Main Domain"

echo -e "${BLUE}=== Main Domain Errors ===${NC}"
analyze_json_logs "$LOG_DIR/chrislawrence-ca-errors.json" "$OUTPUT_DIR/main-domain-errors" "Main Domain Errors"

echo -e "${BLUE}=== Access Logs ===${NC}"
analyze_access_logs "$LOG_DIR/chrislawrence-ca-access.log" "$OUTPUT_DIR/access"

# Create a summary report
echo -e "${BLUE}=== Summary Report ===${NC}"
cat > "$OUTPUT_DIR/summary.txt" << EOF
Caddy Log Analysis Summary
Generated: $(date)
Log Directory: $LOG_DIR

=== File Sizes ===
$(du -h "$LOG_DIR"/*.json "$LOG_DIR"/*.log 2>/dev/null | sort -hr)

=== Recent Errors (Last 10) ===
$(find "$LOG_DIR" -name "*-errors.json" -exec jq -r 'select(.level == "error") | "\(.ts | strftime("%Y-%m-%d %H:%M:%S")) | \(.logger) | \(.msg)"' {} \; 2>/dev/null | tail -10)

=== Top Error Messages ===
$(find "$LOG_DIR" -name "*-errors.json" -exec jq -r 'select(.level == "error") | .msg' {} \; 2>/dev/null | sort | uniq -c | sort -nr | head -10)
EOF

echo -e "${GREEN}Analysis complete! Check $OUTPUT_DIR for detailed reports.${NC}"
echo -e "${YELLOW}Summary report: $OUTPUT_DIR/summary.txt${NC}"

