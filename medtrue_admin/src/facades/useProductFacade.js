import { useState, useEffect, useCallback } from 'react';
import api from '../services/api';

export const useProductFacade = () => {
    const [data, setData] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const fetchAll = useCallback(async () => {
        setLoading(true);
        try {
            const result = await api.get('/products');
            setData(result);
            setError(null);
        } catch (err) {
            setError(err.message || 'Failed to fetch products');
        } finally {
            setLoading(false);
        }
    }, []);

    const remove = async (id) => {
        setLoading(true);
        try {
            await api.delete(`/products/${id}`);
            await fetchAll(); // Refresh list
        } catch (err) {
            setError(err.message || 'Failed to delete product');
            throw err;
        } finally {
            setLoading(false);
        }
    };

    // Initial Fetch
    useEffect(() => {
        fetchAll();
    }, [fetchAll]);

    return {
        data,
        loading,
        error,
        remove,
        refresh: fetchAll
    };
};
