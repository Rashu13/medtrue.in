import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [react()],
    server: {
        proxy: {
            '/api': {
                target: 'http://mcckwgkkkwk0k84kg00s0448.62.72.13.162.sslip.io',
                changeOrigin: true,
                secure: false,
            },
            '/uploads': {
                target: 'http://mcckwgkkkwk0k84kg00s0448.62.72.13.162.sslip.io',
                changeOrigin: true,
                secure: false,
            }
        }
    }
})
