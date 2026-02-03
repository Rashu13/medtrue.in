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
                        if (file instanceof File) {
                            const formData = new FormData();
                            formData.append('file', file);
                            formData.append('displayOrder', index);
                            formData.append('isPrimary', index === 0); // First image is primary

                            await api.post(`/products/${productId}/images`, formData, {
                                headers: { 'Content-Type': 'multipart/form-data' }
                            });
                        }
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

    const update = async (id, productData, images = []) => {
        setLoading(true);
        try {
            await api.put(`/products/${id}`, productData);

            if (images && images.length > 0) {
                // Implement image upload logic for update if needed
                // For now, similar to create logic or separate endpoint
                await Promise.all(images.map(async (file, index) => {
                    if (file instanceof File) {
                        const formData = new FormData();
                        formData.append('file', file);
                        formData.append('displayOrder', index);
                        formData.append('isPrimary', index === 0);

                        await api.post(`/products/${id}/images`, formData, {
                            headers: { 'Content-Type': 'multipart/form-data' }
                        });
                    }
                }));
            }

            await fetchAll();
        } catch (err) {
            setError(err.message || 'Failed to update product');
            throw err;
        } finally {
            setLoading(false);
        }
    };

    const getById = async (id) => {
        setLoading(true);
        try {
            const [product, images] = await Promise.all([
                api.get(`/products/${id}`),
                api.get(`/products/${id}/images`)
            ]);
            return { ...product, images };
        } catch (err) {
            setError(err.message || 'Failed to fetch product details');
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

    const generateSku = async () => {
        try {
            const result = await api.get('/products/generate-sku');
            return result.sku; // Assuming API returns { sku: "..." }
        } catch (err) {
            console.error("Failed to generate SKU", err);
            return "";
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
        getById,
        remove,
        refresh: fetchAll,
        generateSku
    };
};
