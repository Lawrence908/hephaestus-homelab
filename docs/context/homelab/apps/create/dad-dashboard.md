## Dad Dashboard – Simple, Accessible Web Launcher (Prompt)

### Objective
Create a containerized, ultra-simple web “computer” with large, high-contrast buttons for a few daily activities. It should be touch-friendly, resilient, and easy to update. The dashboard opens links/apps your dad uses most (weather, video calls, photos, radio, calendar, notes/messages, etc.).

### Design principles
- Big buttons, large text (18–24pt+), high contrast, minimal choices.
- One screen primary; optional 2nd screen for settings (PIN-protected).
- Works on tablet, old laptop in kiosk mode, or TV browser.
- Zero-maintenance: statically served UI with a thin API proxy for integrations.
- Network-link buttons should tolerate target downtime and show friendly errors.

### Primary actions (initial set – confirm during interview)
- Weather (current + 3-day forecast)
- Video call: Jitsi/Zoom/Meet quick-join link for family room
- Photos: link to Immich shared album or external library viewer
- Family chat/message shortcut (e.g., Signal/Matrix/WhatsApp Web)
- Calendar: read-only Google Calendar embed for upcoming events
- Radio/Music: play/pause favorite stations/Spotify playlist
- “I need help” button: sends SMS/notify to family and shows confirmation
- Notes/Reminders: simple list with large add/mark-done controls

### Secondary actions (optional)
- Medication schedule quick view
- Smart home quick toggles (lights/thermostat) via Home Assistant webhook
- Quick bookmark tiles (bank, news, email) with simplified labels

### Accessibility & UX
- High-contrast themes (dark/light toggle), WCAG AA+ colors
- Button size minimum 64×64 px, hit area 80×80 px
- Voice prompts (TTS) for confirmations; optional speech-to-text input
- Offline-capable PWA: caches shell and shows helpful offline page

### Architecture
- Frontend: lightweight SSG (Astro/Vite/React) or static HTML with HTMX; PWA enabled.
- Backend: very small API for secure actions (notify family, fetch weather) using Flask or FastAPI.
- Reverse proxy: existing Caddy/Traefik.
- Secrets: `.env` mounted (API keys, webhook URLs, contact list).

### Data flow
- Weather → public API (e.g., Open-Meteo) via backend proxy (no keys needed) or OpenWeather.
- Video calls → prebuilt room links (Jitsi is easiest, Meet/Zoom supported).
- Photos → Immich URL with shared album slug.
- Help button → backend triggers one or more: email, SMS gateway (Twilio), Matrix/Telegram bot.
- Notes/Reminders → simple JSON file or SQLite on host volume; optionally sync to Google Tasks/Cal.

### Host paths and variables
- APP_ROOT: `/srv/apps/dad-dashboard`
- DATA_ROOT: `/srv/apps/dad-dashboard/data` (notes, minimal state)
- TIMEZONE: `America/Los_Angeles`
- PUID/PGID: host user/group that owns data

### Directory bootstrap (commands to run)
```bash
sudo mkdir -p /srv/apps/dad-dashboard/{data,config}
sudo chown -R 1000:1000 /srv/apps/dad-dashboard

# Example env file
cat >/srv/apps/dad-dashboard/config/.env <<'ENV'
TZ=America/Los_Angeles
PUID=1000
PGID=1000

# External links
IMMICH_URL=https://photos.example.lan/library/shared/abc123
JITSI_ROOM_URL=https://meet.jit.si/FamilyRoom123
CALENDAR_EMBED_URL=https://calendar.google.com/calendar/embed?src=...
RADIO_STREAM_URL=https://stream.radiostation.example/hi.aac

# Weather
WEATHER_PROVIDER=open-meteo
OPENWEATHER_API_KEY=
LAT=37.7749
LON=-122.4194

# Notifications (choose one or more)
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_FROM=+10000000000
HELP_TARGETS=+15551234567,+15557654321

# Security
SETTINGS_PIN=1234
ALLOWED_ORIGINS=https://dashboard.example.lan
ENV
```

### Docker compose (Flask backend + static frontend)
Place as `/srv/apps/dad-dashboard/compose.yml`.

```yaml
version: "3.9"

services:
  dashboard-api:
    image: ghcr.io/hyperupcall/dad-dashboard-api:latest
    # If publishing your own image, change to your registry/repo
    container_name: dad-dashboard-api
    env_file:
      - /srv/apps/dad-dashboard/config/.env
    environment:
      - TZ=${TZ:-America/Los_Angeles}
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
    volumes:
      - /srv/apps/dad-dashboard/data:/app/data
    ports:
      - "8081:8081"
    restart: unless-stopped

  dashboard-web:
    image: ghcr.io/hyperupcall/dad-dashboard-web:latest
    container_name: dad-dashboard-web
    env_file:
      - /srv/apps/dad-dashboard/config/.env
    environment:
      - TZ=${TZ:-America/Los_Angeles}
      - API_BASE_URL=http://dad-dashboard-api:8081
    depends_on:
      - dashboard-api
    ports:
      - "8080:8080"
    restart: unless-stopped
```

Notes
- If public images do not exist, build from the sample templates below and push to your registry.
- Put the dashboard behind your proxy at `https://dashboard.example.lan`.

### Backend sketch (FastAPI/Flask)
Minimal endpoints:
- `GET /healthz`
- `GET /weather` → fetches and caches forecast
- `POST /notify/help` → sends alerts; rate-limited; logs result
- `GET/POST /notes` → simple list stored in `/app/data/notes.json`
- `GET /config` → read-only config for the frontend (labels/links)

### Frontend sketch
- Single page grid with 2–3 columns of large tiles; responsive for 7–15” screens.
- Buttons open targets in same tab by default; long-press can show options.
- Big clock/date at top; status bar for connectivity and weather icon.
- PWA installable; on Android tablet use kiosk mode; on Linux use Chrome --kiosk.

### Kiosk mode guidance
Chrome/Chromium example startup flags:
```bash
chromium --kiosk --incognito --start-fullscreen --disable-pinch --overscroll-history-navigation=0 https://dashboard.example.lan
```

### Reverse proxy considerations
- Short idle timeouts, keep-alives enabled, WebSocket support (not heavily used but harmless).
- Force HTTPS; optionally put behind SSO but allow device pin-bypass for home LAN.

### Backups and updates
- Data volume `/srv/apps/dad-dashboard/data` (notes/logs) should be backed up.
- Update with `docker compose -f /srv/apps/dad-dashboard/compose.yml pull && docker compose -f /srv/apps/dad-dashboard/compose.yml up -d`.

### Interview checklist (fill before building MVP)
- Daily tasks to surface (rank top 5)
- Preferred services for video calls (Jitsi/Zoom/Meet/FaceTime alt?)
- Family photo source (Immich link/album)
- Radio/music preferences and devices
- Calendar accounts and visibility
- Who receives “Help” alerts; preferred contact method(s)
- Accessibility needs: font size, color scheme, audio prompts, language
- Devices he’ll use: tablet/laptop/TV; network constraints

### Success criteria
- First screen loads in <1s on LAN and shows Weather + buttons clearly.
- “Help” reliably notifies family and shows on-screen confirmation.
- Buttons are readable from 6–8 feet; tap targets are forgiving.
- System survives reboots and updates with no manual steps.

### Optional: Build your own images
If you want to build locally instead of using prebuilt images, scaffold two repos:

1) API (FastAPI example)
```Dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
ENV PORT=8081
CMD ["uvicorn","app:app","--host","0.0.0.0","--port","8081"]
```

2) Web (Vite/React example)
```Dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx","-g","daemon off;"]
```

Then update the compose images to your built tags.

### Launch
```bash
docker compose -f /srv/apps/dad-dashboard/compose.yml up -d
```


