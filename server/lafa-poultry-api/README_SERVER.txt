LAFA POULTRY v5.5 CLOUD API

UPLOAD THIS FOLDER TO:
public_html/lafa-poultry-api/

Expected public endpoints:
https://lafasoftware.co.tz/lafa-poultry-api/version.php
https://lafasoftware.co.tz/lafa-poultry-api/content.php

ADMIN UPDATE ENDPOINT:
https://lafasoftware.co.tz/lafa-poultry-api/admin-update.php

IMPORTANT:
1. Edit admin-update.php and replace CHANGE_THIS_TO_A_LONG_RANDOM_SECRET.
2. Keep the website on HTTPS.
3. Ensure server/lafa-poultry-api/data/ is writable by PHP.
4. Every successful admin-update POST automatically increases content version.
5. The mobile app checks version.php first and downloads content.php only when a new version exists.

POST BODY FORMAT:
{
  "items": [
    {
      "id": "unique-id",
      "type": "Disease",
      "titleSw": "Kichwa",
      "titleEn": "Title",
      "bodySw": "Maelezo",
      "bodyEn": "Content",
      "tags": "tag1,tag2",
      "published": true,
      "updatedAt": "2026-08-20T00:00:00+03:00"
    }
  ]
}

HEADER:
X-LAFA-API-KEY: YOUR_SECRET_KEY
