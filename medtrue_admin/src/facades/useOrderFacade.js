import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../services/api';

export const useOrderFacade = (initialPageSize = 20) => {
    const queryClient = useQueryClient();
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(initialPageSize);

    const queryKey = ['orders', page, pageSize];

    const {
        data: queryResult,
        isLoading: loading,
        error: queryError,
        refetch
    } = useQuery({
        queryKey,
        queryFn: async () => {
            const result = await api.get(`/orders?page=${page}&pageSize=${pageSize}`);
            return {
                items: result.items || result.Items || [],
                total: result.totalCount || result.TotalCount || 0
            };
        },
        staleTime: 60 * 1000,
    });

    const data = queryResult?.items || [];
    const total = queryResult?.total || 0;
    const error = queryError?.message || null;

    // TODO: Add Status Update Mutation if needed

    return {
        data,
        loading,
        error,
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
