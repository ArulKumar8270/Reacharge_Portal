# Razorpay Domain Verification Setup Guide

## Issue
Razorpay requires domain verification for deep linking to work properly. You need to host a Digital Asset Links JSON file on your domain.

## Steps to Fix

### 1. Get Your Release Keystore SHA-256 Fingerprint

For production, you need the SHA-256 fingerprint from your **release keystore**, not the debug keystore.

```bash
# Replace with your actual keystore path and alias
keytool -list -v -keystore /path/to/your/release.keystore -alias your_alias
```

**Note:** The current `assetlinks.json` file uses the debug keystore fingerprint. You must update it with your release keystore fingerprint before going to production.

### 2. Update assetlinks.json

Edit `assetlinks.json` and replace the SHA-256 fingerprint with your release keystore fingerprint:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.nexus4.nexus4_MI",
      "sha256_cert_fingerprints": [
        "YOUR_RELEASE_SHA256_FINGERPRINT_HERE"
      ]
    }
  }
]
```

### 3. Host the File on Your Domain

Upload the `assetlinks.json` file to your web server at:

```
https://yourdomain.com/.well-known/assetlinks.json
```

**Important Requirements:**
- The file MUST be accessible via HTTPS
- The file MUST be served with `Content-Type: application/json` header
- The file MUST be at the exact path: `/.well-known/assetlinks.json`

### 4. Server Configuration Examples

#### Apache (.htaccess)
```apache
<Files "assetlinks.json">
    Header set Content-Type "application/json"
</Files>
```

#### Nginx
```nginx
location /.well-known/assetlinks.json {
    add_header Content-Type application/json;
}
```

#### Node.js/Express
```javascript
app.get('/.well-known/assetlinks.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.sendFile(path.join(__dirname, 'assetlinks.json'));
});
```

### 5. Verify the File is Accessible

1. Open your browser and visit: `https://yourdomain.com/.well-known/assetlinks.json`
2. Check that:
   - The file loads correctly
   - The Content-Type header is `application/json` (check in browser DevTools → Network tab)
   - The JSON is valid

### 6. Test the Configuration

Use Google's Digital Asset Links API tester:
```
https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://yourdomain.com&relation=delegate_permission/common.handle_all_urls
```

### 7. Recheck in Razorpay Dashboard

After hosting the file:
1. Go to Razorpay Dashboard → Settings → Payment Gateway → App Links
2. Click "Recheck verification"
3. Wait a few minutes for verification to complete

## Current Configuration

- **Package Name:** `com.nexus4.nexus4_MI`
- **Debug SHA-256:** `B2:4F:AE:26:76:50:22:6C:C6:32:B8:AE:4E:D9:F9:EF:2E:86:E5:15:07:A2:F3:DB:17:6E:1F:A5:69:91:B0:F1`
- **AndroidManifest:** Already configured with Razorpay deep link intent filter

## Troubleshooting

1. **File not found (404):**
   - Ensure the file is at `/.well-known/assetlinks.json` (not `/well-known/assetlinks.json`)
   - Check file permissions on the server

2. **Wrong Content-Type:**
   - Verify your server is sending `Content-Type: application/json`
   - Use browser DevTools to check response headers

3. **JSON validation error:**
   - Validate JSON at https://jsonlint.com/
   - Ensure no trailing commas or syntax errors

4. **Still not verified:**
   - Wait 5-10 minutes after uploading (DNS/CDN propagation)
   - Clear browser cache and try again
   - Verify the SHA-256 fingerprint matches your release keystore

## Additional Notes

- For development/testing, the debug keystore fingerprint works
- For production, you MUST use the release keystore fingerprint
- If you have multiple build variants, you may need multiple entries in the JSON array
- The AndroidManifest.xml already includes the Razorpay deep link intent filter

