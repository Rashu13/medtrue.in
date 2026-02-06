import axios from 'axios';

// Production API URL - hardcoded for reliability
// Production API URL - hardcoded for reliability
export const baseURL = 'https://medtrue.cloud/api';
export const IMAGE_BASE_URL = 'https://medtrue.cloud';

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
