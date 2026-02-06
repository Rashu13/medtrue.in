import axios from 'axios';

// Use environment variable for API URL, fallback to local proxy path or production
// Hardcode to /api to ensure local proxy is ALWAYS used
export const baseURL = '/api';
// Use relative path for images to leverage proxy
export const IMAGE_BASE_URL = '';

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
