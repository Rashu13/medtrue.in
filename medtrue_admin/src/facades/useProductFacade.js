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

    const create = async (productData, images = []) => {
        setLoading(true);
        try {
            // 1. Create Product
            const newProduct = await api.post('/products', productData);

            // 2. Upload Images (if any)
            if (images && images.length > 0) {
                const productId = newProduct.productId || newProduct.id; // Adjust based on actual API response
                if (productId) {
                    await Promise.all(images.map(async (file, index) => {
                        const formData = new FormData();
                        formData.append('file', file);
                        formData.append('displayOrder', index);
                        formData.append('isPrimary', index === 0); // First image is primary

                        await api.post(`/products/${productId}/images`, formData, {
                            headers: { 'Content-Type': 'multipart/form-data' }
                        });
                    }));
                }
            }

            await fetchAll(); // Refresh list
            return newProduct;
        } catch (err) {
            setError(err.message || 'Failed to create product');
            throw err;
        } finally {
            setLoading(false);
        }
    };

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
        create,
        remove,
        refresh: fetchAll
    };
};
