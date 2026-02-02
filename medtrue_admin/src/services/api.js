import axios from 'axios';

// Hardcode to /api for local dev to force Proxy
const baseURL = '/api';

// Create Axios Instance
const api = axios.create({
    baseURL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Interceptor for responses (e.g., global error handling)
api.interceptors.response.use(
    (response) => response.data, // Unpack data directly
    (error) => {
        console.error('API Error:', error);
        return Promise.reject(error);
    }
);

export default api;
