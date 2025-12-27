# Admin Dashboard Environment Setup

## Quick Setup

1. Create a `.env` file in the `admin-dashboard` directory
2. Copy the following content:

```env
# Backend API Configuration
# Backend PORT is configured in backend/.env (default: 3000 from ENV_CONFIG.txt)
VITE_API_URL=http://localhost:3000/api/v1

# Environment
VITE_NODE_ENV=development
```

## Configuration Details

### Backend API URL

The admin dashboard connects to the backend API. The configuration is based on:

- **Backend PORT**: Default is `3000` (configured in `backend/.env` or `backend/ENV_CONFIG.txt`)
- **API Base Path**: `/api/v1`
- **Full URL**: `http://localhost:3000/api/v1`

### Matching Backend Configuration

Ensure your backend `.env` file has:
```env
PORT=3000
NODE_ENV=development
```

See `backend/ENV_CONFIG.txt` for complete backend environment variables.

### Changing the Backend Port

If your backend runs on a different port (e.g., 5000):

1. Update `backend/.env`:
   ```env
   PORT=5000
   ```

2. Update `admin-dashboard/.env`:
   ```env
   VITE_API_URL=http://localhost:5000/api/v1
   ```

### Production Configuration

For production, update the `.env` file:
```env
VITE_API_URL=https://your-api-domain.com/api/v1
VITE_NODE_ENV=production
```

## Verification

After setting up the `.env` file:

1. Start the backend server:
   ```bash
   cd backend
   npm start
   ```

2. Start the admin dashboard:
   ```bash
   cd admin-dashboard
   npm run dev
   ```

3. Check the browser console - you should see:
   ```
   🔗 API Base URL: http://localhost:3000/api/v1
   ```

## Troubleshooting

- **API connection errors**: Verify the backend is running on the configured port
- **CORS errors**: Ensure backend has CORS enabled (should be in `backend/server.js`)
- **401 Unauthorized**: Check that admin credentials are correct (default: `admin@nexus.com` / `admin123`)

