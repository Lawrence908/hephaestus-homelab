#!/bin/bash

# Caddy Log Filter - Reduces noise in Caddy logs
# This script filters out common non-critical log entries

LOG_DIR="/data/logs"
FILTERED_DIR="/data/logs/filtered"

# Create filtered directory
mkdir -p "$FILTERED_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Caddy Log Filter ===${NC}"
echo "Filtering logs in: $LOG_DIR"
echo "Filtered logs in: $FILTERED_DIR"
echo

# Function to filter JSON logs
filter_json_logs() {
    local input_file="$1"
    local output_file="$2"
    local service_name="$3"
    
    if [[ -f "$input_file" ]]; then
        echo -e "${GREEN}Filtering $service_name logs...${NC}"
        
        # Filter out common noise and keep important entries
        jq -r '
            select(
                # Keep errors and warnings
                .level == "error" or .level == "warn" or
                # Keep important info messages
                (.level == "info" and (
                    .msg | contains("server running") or
                    contains("shutdown") or
                    contains("config") or
                    contains("tls") or
                    contains("admin") or
                    contains("automatic HTTPS") or
                    (.request != null and .request.status >= 400)
                ))
            ) |
            "\(.ts | strftime("%Y-%m-%d %H:%M:%S")) | \(.level | ascii_upcase) | \(.logger // "main") | \(.msg)"' \
            "$input_file" > "$output_file" 2>/dev/null
        
        # Count filtered entries
        local total_lines=$(wc -l < "$input_file" 2>/dev/null || echo "0")
        local filtered_lines=$(wc -l < "$output_file" 2>/dev/null || echo "0")
        
        echo -e "  Original: $total_lines lines"
        echo -e "  Filtered: $filtered_lines lines"
        echo -e "  Reduction: $(( (total_lines - filtered_lines) * 100 / total_lines ))%"
        echo
    else
        echo -e "${YELLOW}Log file $input_file not found${NC}"
    fi
}

# Function to create a real-time log monitor
create_log_monitor() {
    local output_file="$FILTERED_DIR/realtime-monitor.sh"
    
    cat > "$output_file" << 'EOF'
#!/bin/bash

# Real-time Caddy Log Monitor
# Monitors filtered logs in real-time

LOG_DIR="/data/logs"
FILTERED_DIR="/data/logs/filtered"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Real-time Caddy Log Monitor ===${NC}"
echo "Monitoring logs for important events..."
echo "Press Ctrl+C to stop"
echo

# Monitor multiple log files
tail -f "$LOG_DIR"/*.json 2>/dev/null | jq -r '
    select(
        .level == "error" or .level == "warn" or
        (.level == "info" and (
            .msg | contains("server running") or
            contains("shutdown") or
            contains("config") or
            contains("tls") or
            contains("admin") or
            contains("automatic HTTPS") or
            (.request != null and .request.status >= 400)
        ))
    ) |
    "\(.ts | strftime("%H:%M:%S")) | \(.level | ascii_upcase) | \(.logger // "main") | \(.msg)"
' | while read line; do
    if [[ $line == *"ERROR"* ]]; then
        echo -e "${RED}$line${NC}"
    elif [[ $line == *"WARN"* ]]; then
        echo -e "${YELLOW}$line${NC}"
    else
        echo -e "${GREEN}$line${NC}"
    fi
done
EOF

    chmod +x "$output_file"
    echo -e "${GREEN}Created real-time monitor: $output_file${NC}"
}

# Filter different log files
echo -e "${BLUE}=== Filtering Logs ===${NC}"

# Global logs
filter_json_logs "$LOG_DIR/caddy.json" "$FILTERED_DIR/caddy-filtered.txt" "Global"

# Error logs (already filtered, just copy)
if [[ -f "$LOG_DIR/caddy-errors.json" ]]; then
    echo -e "${GREEN}Processing error logs...${NC}"
    jq -r '"\(.ts | strftime("%Y-%m-%d %H:%M:%S")) | \(.level | ascii_upcase) | \(.logger // "main") | \(.msg)"' \
        "$LOG_DIR/caddy-errors.json" > "$FILTERED_DIR/errors-filtered.txt" 2>/dev/null
    echo -e "  Error logs processed"
fi

# Main domain logs
filter_json_logs "$LOG_DIR/chrislawrence-ca.json" "$FILTERED_DIR/main-domain-filtered.txt" "Main Domain"

# Dashboard logs
filter_json_logs "$LOG_DIR/dashboard.json" "$FILTERED_DIR/dashboard-filtered.txt" "Dashboard"

# Create real-time monitor
create_log_monitor

# Create a summary of filtered logs
echo -e "${BLUE}=== Filter Summary ===${NC}"
echo "Filtered logs available in: $FILTERED_DIR"
echo
echo "Files created:"
ls -la "$FILTERED_DIR"/*.txt 2>/dev/null | awk '{print "  " $9 " (" $5 " bytes)"}'

echo
echo -e "${GREEN}Log filtering complete!${NC}"
echo -e "${YELLOW}Use $FILTERED_DIR/realtime-monitor.sh to monitor logs in real-time${NC}"

