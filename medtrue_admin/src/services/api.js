import axios from 'axios';

// Use VITE_API_URL from environment or fallback to production URL
const baseURL = import.meta.env.VITE_API_URL || 'https://medtrue.cloud/api';

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
