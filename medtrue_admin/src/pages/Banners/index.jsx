import { useState, useRef } from 'react';
import { useBannerFacade } from '../../facades/useBannerFacade';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import { X, Upload, Plus, Trash2 } from 'lucide-react';
import { IMAGE_BASE_URL } from '../../services/api';

const Banners = () => {
    const { data: banners, loading, create, remove } = useBannerFacade();
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [previewImage, setPreviewImage] = useState(null);
    const fileInputRef = useRef(null);

    const formik = useFormik({
        initialValues: {
            title: '',
            image: null,
            type: 'main_slider',
            position: 0,
            linkType: '',
            linkId: '',
            isActive: true
        },
        validationSchema: Yup.object({
            title: Yup.string().required('Title is required'),
            image: Yup.mixed().required('Image is required'),
            type: Yup.string().required('Type is required'),
        }),
        onSubmit: async (values, { resetForm }) => {
            try {
                const formData = new FormData();
                Object.keys(values).forEach(key => {
                    formData.append(key, values[key]);
                });

                await create(formData);
                setIsModalOpen(false);
                resetForm();
                setPreviewImage(null);
            } catch (error) {
                console.error("Banner creation error:", error);
                const errorMsg = error.response?.data?.message ||
                    error.response?.data?.Message ||
                    error.response?.data?.title ||
                    error.message;
                alert('Failed to create banner: ' + errorMsg);
            }
        },
    });

    const handleImageChange = (event) => {
        const file = event.currentTarget.files[0];
        if (file) {
            formik.setFieldValue('image', file);
            setPreviewImage(URL.createObjectURL(file));
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm('Are you sure you want to delete this banner?')) {
            try {
                await remove(id);
            } catch (error) {
                console.error('Error deleting banner:', error);
            }
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold text-gray-800 dark:text-gray-100">Banners</h1>
                <button
                    onClick={() => setIsModalOpen(true)}
                    className="flex items-center gap-2 bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-md transition-colors text-sm font-medium"
                >
                    <Plus size={16} />
                    Add Banner
                </button>
            </div>

            {loading ? (
                <div className="text-center py-8 text-gray-500">Loading banners...</div>
            ) : banners.length === 0 ? (
                <div className="text-center py-8 text-gray-500 bg-white dark:bg-gray-800 rounded-lg border dark:border-gray-700">
                    No banners found. Add one to get started.
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {banners.map((banner) => (
                        <div key={banner.id || banner.bannerId} className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden group">
                            <div className="relative h-48 bg-gray-100 dark:bg-gray-700">
                                <img
                                    src={banner.imagePath?.startsWith('http') ? banner.imagePath : `${IMAGE_BASE_URL}${banner.imagePath}`}
                                    alt={banner.title}
                                    className="w-full h-full object-cover"
                                />
                                <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <button
                                        onClick={() => handleDelete(banner.id || banner.bannerId)}
                                        className="p-2 bg-red-600 text-white rounded-full hover:bg-red-700 shadow-sm"
                                    >
                                        <Trash2 size={16} />
                                    </button>
                                </div>
                                <div className="absolute bottom-2 left-2">
                                    <span className={`px-2 py-0.5 text-xs font-semibold rounded-full ${banner.isActive
                                        ? 'bg-green-100 text-green-800 dark:bg-green-900/50 dark:text-green-300'
                                        : 'bg-red-100 text-red-800 dark:bg-red-900/50 dark:text-red-300'
                                        }`}>
                                        {banner.isActive ? 'Active' : 'Inactive'}
                                    </span>
                                </div>
                            </div>
                            <div className="p-4">
                                <h3 className="font-semibold text-lg text-gray-800 dark:text-gray-100 mb-1">{banner.title}</h3>
                                <div className="text-sm text-gray-500 dark:text-gray-400 space-y-1">
                                    <p>Type: <span className="font-medium">{banner.type}</span></p>
                                    <p>Position: <span className="font-medium">{banner.position}</span></p>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Modal */}
            {isModalOpen && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl w-full max-w-lg overflow-hidden">
                        <div className="flex justify-between items-center px-6 py-4 border-b border-gray-200 dark:border-gray-700">
                            <h3 className="text-lg font-bold text-gray-800 dark:text-gray-100">Add New Banner</h3>
                            <button onClick={() => setIsModalOpen(false)} className="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200">
                                <X size={20} />
                            </button>
                        </div>

                        <form onSubmit={formik.handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Title</label>
                                <input
                                    type="text"
                                    name="title"
                                    onChange={formik.handleChange}
                                    value={formik.values.title}
                                    className="w-full px-3 py-2 border rounded-md dark:bg-gray-700 dark:border-gray-600 dark:text-white focus:ring-teal-500 focus:border-teal-500"
                                    placeholder="Enter banner title"
                                />
                                {formik.touched.title && formik.errors.title && (
                                    <p className="text-red-500 text-xs mt-1">{formik.errors.title}</p>
                                )}
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Banner Image</label>
                                <div
                                    onClick={() => fileInputRef.current.click()}
                                    className="border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg p-6 text-center cursor-pointer hover:border-teal-500 transition-colors"
                                >
                                    {previewImage ? (
                                        <img src={previewImage} alt="Preview" className="h-32 mx-auto object-contain" />
                                    ) : (
                                        <div className="flex flex-col items-center text-gray-500 dark:text-gray-400">
                                            <Upload className="mb-2" />
                                            <span className="text-sm">Click to upload image</span>
                                        </div>
                                    )}
                                    <input
                                        type="file"
                                        ref={fileInputRef}
                                        className="hidden"
                                        accept="image/*"
                                        onChange={handleImageChange}
                                    />
                                </div>
                                {formik.touched.image && formik.errors.image && (
                                    <p className="text-red-500 text-xs mt-1">{formik.errors.image}</p>
                                )}
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Type</label>
                                    <select
                                        name="type"
                                        onChange={formik.handleChange}
                                        value={formik.values.type}
                                        className="w-full px-3 py-2 border rounded-md dark:bg-gray-700 dark:border-gray-600 dark:text-white"
                                    >
                                        <option value="main_slider">Main Slider</option>
                                        <option value="promo_1">Promo 1</option>
                                        <option value="promo_2">Promo 2</option>
                                        <option value="footer_promo">Footer Promo</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Position</label>
                                    <input
                                        type="number"
                                        name="position"
                                        onChange={formik.handleChange}
                                        value={formik.values.position}
                                        className="w-full px-3 py-2 border rounded-md dark:bg-gray-700 dark:border-gray-600 dark:text-white"
                                    />
                                </div>
                            </div>

                            <div className="flex items-center gap-2">
                                <input
                                    type="checkbox"
                                    name="isActive"
                                    id="isActive"
                                    onChange={formik.handleChange}
                                    checked={formik.values.isActive}
                                    className="rounded text-teal-600 focus:ring-teal-500 dark:bg-gray-700 dark:border-gray-600"
                                />
                                <label htmlFor="isActive" className="text-sm font-medium text-gray-700 dark:text-gray-300">Active</label>
                            </div>

                            <div className="flex justify-end gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={() => setIsModalOpen(false)}
                                    className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="px-4 py-2 text-sm font-medium text-white bg-teal-600 hover:bg-teal-700 rounded-md"
                                >
                                    Create Banner
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Banners;
