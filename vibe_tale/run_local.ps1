# Run VibeTale against the LOCAL backend (FastAPI :8000 + local Supabase :54321).
#
# Android emulator reaches the host machine via 10.0.2.2.
# For a PHYSICAL device, replace 10.0.2.2 with your PC's LAN IP (e.g. 192.168.1.x)
# and make sure the device is on the same network.

$ApiBase  = "http://10.0.2.2:8000"
$SbUrl    = "http://10.0.2.2:54321"
$SbAnon   = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"

flutter run `
  --dart-define=API_BASE_URL=$ApiBase `
  --dart-define=SUPABASE_URL=$SbUrl `
  --dart-define=SUPABASE_ANON_KEY=$SbAnon
