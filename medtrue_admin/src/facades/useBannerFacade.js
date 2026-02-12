import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../services/api';

export const useBannerFacade = (initialPageSize = 20) => {
    const queryClient = useQueryClient();
    const queryKey = ['banners'];

    const {
        data: banners = [],
        isLoading: loading,
        error,
        refetch
    } = useQuery({
        queryKey,
        queryFn: async () => {
            const result = await api.get('/banners');
            // Support both paginated and flat list responses
            return result.items || result.Items || result || [];
        },
        staleTime: 5 * 60 * 1000,
    });

    const createMutation = useMutation({
        mutationFn: async (inputData) => {
            // 1. Upload Image
            const imageFile = inputData.get('image');
            let imagePath = '';

            if (imageFile instanceof File) {
                const uploadData = new FormData();
                uploadData.append('file', imageFile);
                const uploadRes = await api.post('/banners/upload', uploadData, {
                    headers: { 'Content-Type': 'multipart/form-data' }
                });
                imagePath = uploadRes.path;
            }

            // 2. Prepare JSON Payload
            // Map UI fields to Backend Model
            // UI 'Type' -> Backend 'Position' (e.g. main_slider)
            // UI 'Position' -> Backend 'DisplayOrder'
            // UI 'isActive' -> Backend 'VisibilityStatus'

            const title = inputData.get('title');
            const typeOption = inputData.get('type');

            const payload = {
                title: title,
                slug: title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, ''), // Generate slug
                position: typeOption,
                displayOrder: parseInt(inputData.get('position')) || 0,
                type: 'custom', // Default Type
                isActive: inputData.get('isActive') === 'true', // Map to backend boolean
                imagePath: imagePath
            };

            // 3. Create Banner
            return api.post('/banners', payload);
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey });
        },
    });

    const deleteMutation = useMutation({
        mutationFn: (id) => api.delete(`/banners/${id}`),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey });
        },
    });

    const create = async (formData) => {
        await createMutation.mutateAsync(formData);
    };

    const remove = async (id) => {
        await deleteMutation.mutateAsync(id);
    };

    return {
        data: banners,
        loading,
        error: error?.message,
        create,
        remove,
        refresh: refetch,
        isCreating: createMutation.isPending,
        isDeleting: deleteMutation.isPending
    };
};
