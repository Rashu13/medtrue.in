import React, { useEffect, useState } from 'react';

const FeaturedSections = () => {
    const [sections, setSections] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState('');
    const [formData, setFormData] = useState({
        title: '',
        sectionType: 'newly_added',
        scopeType: 'global',
        style: 'default',
        sortOrder: 0,
        isActive: true,
        shortDescription: '',
        backgroundColor: '#ffffff',
        textColor: '#000000',
    });

    useEffect(() => {
        fetchSections();
    }, []);

    const fetchSections = async () => {
        try {
            const response = await fetch('/api/featured-sections');
            const data = await response.json();
            setSections(data.items || data.Items || []);
        } catch (error) {
            console.error('Error fetching sections:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm('Are you sure you want to delete this section?')) {
            try {
                await fetch(`/api/featured-sections/${id}`, { method: 'DELETE' });
                fetchSections();
            } catch (error) {
                console.error('Error deleting section:', error);
            }
        }
    };

    const handleInputChange = (e) => {
        const { name, value, type, checked } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSaving(true);
        setError('');

        try {
            const slug = formData.title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
            const payload = {
                title: formData.title,
                slug: slug,
                sectionType: formData.sectionType,
                scopeType: formData.scopeType,
                style: formData.style,
                sortOrder: parseInt(formData.sortOrder) || 0,
                isActive: formData.isActive,
                shortDescription: formData.shortDescription,
                backgroundColor: formData.backgroundColor,
                textColor: formData.textColor,
            };

            const response = await fetch('/api/featured-sections', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload),
            });

            if (!response.ok) {
                const errText = await response.text();
                throw new Error(errText || 'Failed to create section');
            }

            setShowModal(false);
            setFormData({
                title: '', sectionType: 'newly_added', scopeType: 'global', style: 'default',
                sortOrder: 0, isActive: true, shortDescription: '', backgroundColor: '#ffffff', textColor: '#000000',
            });
            fetchSections();
        } catch (err) {
            setError(err.message);
        } finally {
            setSaving(false);
        }
    };

    return (
        <div className="p-6">
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold text-gray-800 dark:text-white">Featured Sections</h1>
                <button
                    className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition-colors"
                    onClick={() => setShowModal(true)}
                >
                    Add Section
                </button>
            </div>

            {loading ? (
                <p className="text-gray-600 dark:text-gray-400">Loading...</p>
            ) : (
                <div className="overflow-x-auto bg-white dark:bg-gray-800 rounded-lg shadow transition-colors duration-200">
                    <table className="min-w-full">
                        <thead className="bg-gray-50 dark:bg-gray-700 border-b dark:border-gray-700">
                            <tr>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Title</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Type</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Scope</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Sort Order</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Status</th>
                                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
                            {sections.length === 0 ? (
                                <tr>
                                    <td colSpan="6" className="px-6 py-8 text-center text-gray-500 dark:text-gray-400">
                                        No sections found. Click "Add Section" to create one.
                                    </td>
                                </tr>
                            ) : (
                                sections.map((section) => (
                                    <tr key={section.id} className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                                        <td className="px-6 py-4 whitespace-nowrap font-medium text-gray-900 dark:text-gray-100">{section.title}</td>
                                        <td className="px-6 py-4 whitespace-nowrap text-gray-500 dark:text-gray-400">{section.sectionType}</td>
                                        <td className="px-6 py-4 whitespace-nowrap text-gray-500 dark:text-gray-400">{section.scopeType}</td>
                                        <td className="px-6 py-4 whitespace-nowrap text-gray-500 dark:text-gray-400">{section.sortOrder}</td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${section.isActive ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300' : 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300'}`}>
                                                {section.isActive ? 'Active' : 'Inactive'}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                            <button onClick={() => handleDelete(section.id)} className="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-300 ml-4">Delete</button>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            )}

            {/* Add Section Modal */}
            {showModal && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
                    <div className="bg-white dark:bg-gray-800 rounded-xl shadow-2xl w-full max-w-lg mx-4 max-h-[90vh] overflow-y-auto">
                        <div className="flex justify-between items-center px-6 py-4 border-b dark:border-gray-700">
                            <h2 className="text-xl font-bold text-gray-800 dark:text-white">Add New Section</h2>
                            <button onClick={() => setShowModal(false)} className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 text-2xl">&times;</button>
                        </div>

                        {error && (
                            <div className="mx-6 mt-4 p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg text-red-700 dark:text-red-300 text-sm">
                                {error}
                            </div>
                        )}

                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            {/* Title */}
                            <div>
                                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Title *</label>
                                <input
                                    type="text" name="title" required value={formData.title} onChange={handleInputChange}
                                    className="w-full px-3 py-2 border dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                                    placeholder="e.g. Newly Added Products"
                                />
                            </div>

                            {/* Section Type */}
                            <div>
                                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Section Type</label>
                                <select name="sectionType" value={formData.sectionType} onChange={handleInputChange}
                                    className="w-full px-3 py-2 border dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500">
                                    <option value="newly_added">Newly Added</option>
                                    <option value="best_seller">Best Seller</option>
                                    <option value="trending">Trending</option>
                                    <option value="offers">Offers</option>
                                    <option value="custom">Custom</option>
                                </select>
                            </div>

                            {/* Scope */}
                            <div>
                                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Scope</label>
                                <select name="scopeType" value={formData.scopeType} onChange={handleInputChange}
                                    className="w-full px-3 py-2 border dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500">
                                    <option value="global">Global</option>
                                    <option value="regional">Regional</option>
                                    <option value="store">Store</option>
                                </select>
                            </div>

                            {/* Short Description */}
                            <div>
                                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Short Description</label>
                                <textarea name="shortDescription" value={formData.shortDescription} onChange={handleInputChange} rows="2"
                                    className="w-full px-3 py-2 border dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500"
                                    placeholder="Brief description of this section"
                                />
                            </div>

                            {/* Sort Order */}
                            <div>
                                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Sort Order</label>
                                <input type="number" name="sortOrder" value={formData.sortOrder} onChange={handleInputChange}
                                    className="w-full px-3 py-2 border dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500"
                                />
                            </div>

                            {/* Active Toggle */}
                            <div className="flex items-center gap-3">
                                <label className="relative inline-flex items-center cursor-pointer">
                                    <input type="checkbox" name="isActive" checked={formData.isActive} onChange={handleInputChange} className="sr-only peer" />
                                    <div className="w-11 h-6 bg-gray-200 peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-600 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-500 peer-checked:bg-blue-600"></div>
                                </label>
                                <span className="text-sm font-medium text-gray-700 dark:text-gray-300">Active</span>
                            </div>

                            {/* Submit */}
                            <div className="flex justify-end gap-3 pt-4 border-t dark:border-gray-700">
                                <button type="button" onClick={() => setShowModal(false)}
                                    className="px-4 py-2 border dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                                    Cancel
                                </button>
                                <button type="submit" disabled={saving}
                                    className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors">
                                    {saving ? 'Saving...' : 'Create Section'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default FeaturedSections;
