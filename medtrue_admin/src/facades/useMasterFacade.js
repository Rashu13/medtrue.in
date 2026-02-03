import { useState, useCallback } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../services/api';

/**
 * Facade hook for Master Data operations using React Query for caching.
 * @param {string} endpoint - The API endpoint suffix (e.g., 'masters/companies')
 * @param {number} initialPageSize - Default page size for fetching
 */
export const useMasterFacade = (endpoint, initialPageSize = 10) => {
    const queryClient = useQueryClient();

    // Pagination State
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(initialPageSize);

    // Query Key based on dependencies
    const queryKey = [endpoint, page, pageSize];

    // 1. Fetch Data with Caching
    const {
        data: queryResult,
        isLoading: loading,
        error: queryError,
        refetch
    } = useQuery({
        queryKey,
        queryFn: async () => {
            const result = await api.get(`/${endpoint}?page=${page}&pageSize=${pageSize}`);

            // Normalize response
            const items = result.items || result.Items;
            const totalCount = result.totalCount || result.TotalCount;

            if (items) {
                return { items, total: totalCount };
            } else {
                // Fallback for non-paged
                return { items: result, total: result.length || 0 };
            }
        },
        staleTime: 5 * 60 * 1000, // 5 minutes cache
        placeholderData: (prev) => prev,   // Keep showing old data while fetching new page
    });

    // Derived state
    const data = queryResult?.items || [];
    const total = queryResult?.total || 0;
    const error = queryError?.message || null;

    // 2. Mutations
    const createMutation = useMutation({
        mutationFn: (item) => api.post(`/${endpoint}`, item),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [endpoint] });
        },
    });

    const updateMutation = useMutation({
        mutationFn: ({ id, item }) => api.put(`/${endpoint}/${id}`, item),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [endpoint] });
        },
    });

    const deleteMutation = useMutation({
        mutationFn: (id) => api.delete(`/${endpoint}/${id}`),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [endpoint] });
        },
    });

    // Wrapper functions to match old interface
    const create = async (item) => {
        try {
            await createMutation.mutateAsync(item);
        } catch (err) {
            throw err;
        }
    };

    const update = async (id, item) => {
        try {
            await updateMutation.mutateAsync({ id, item });
        } catch (err) {
            throw err;
        }
    };

    const remove = async (id) => {
        try {
            await deleteMutation.mutateAsync(id);
        } catch (err) {
            throw err;
        }
    };

    return {
        data,
        loading: loading || createMutation.isPending || updateMutation.isPending || deleteMutation.isPending,
        error: error || createMutation.error?.message || updateMutation.error?.message || deleteMutation.error?.message,
        create,
        update,
        remove,
        refresh: refetch,
        pagination: {
            page,
            pageSize,
            total,
            setPage,
            setPageSize
        }
    };
};
