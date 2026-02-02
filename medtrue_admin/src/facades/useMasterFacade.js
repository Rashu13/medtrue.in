import { useState, useEffect, useCallback } from 'react';
import api from '../services/api';

/**
 * Facade hook for Master Data operations.
 * @param {string} endpoint - The API endpoint suffix (e.g., 'masters/companies')
 */
export const useMasterFacade = (endpoint) => {
    const [data, setData] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const fetchAll = useCallback(async () => {
        setLoading(true);
        try {
            const result = await api.get(`/${endpoint}`);
            setData(result);
            setError(null);
        } catch (err) {
            setError(err.message || 'Failed to fetch data');
        } finally {
            setLoading(false);
        }
    }, [endpoint]);

    const create = async (item) => {
        setLoading(true);
        try {
            await api.post(`/${endpoint}`, item);
            await fetchAll(); // Refresh list
        } catch (err) {
            setError(err.message || 'Failed to create item');
            throw err;
        } finally {
            setLoading(false);
        }
    };

    const update = async (id, item) => {
        setLoading(true);
        try {
            await api.put(`/${endpoint}/${id}`, item);
            await fetchAll();
        } catch (err) {
            setError(err.message || 'Failed to update item');
            throw err;
        } finally {
            setLoading(false);
        }
    };

    const remove = async (id) => {
        setLoading(true);
        try {
            await api.delete(`/${endpoint}/${id}`);
            await fetchAll(); // Refresh list
        } catch (err) {
            setError(err.message || 'Failed to delete item');
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
        create,
        update,
        remove,
        refresh: fetchAll
    };
};
