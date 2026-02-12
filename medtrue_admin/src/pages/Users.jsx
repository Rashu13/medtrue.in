import { useState } from 'react';
import { useMasterFacade } from '../facades/useMasterFacade';
import MasterTable from '../components/MasterTable';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import { X } from 'lucide-react';

const Users = () => {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingItem, setEditingItem] = useState(null);

    const { data, loading, create, update, remove, pagination, refresh } = useMasterFacade('users');

    const columns = [
        { label: 'Name', key: 'name' },
        { label: 'Mobile', key: 'mobile' },
        { label: 'Email', key: 'email' },
        {
            label: 'Status', key: 'status', render: (row) => (
                <span className={`px-2 py-1 rounded-full text-xs font-semibold
                ${row.status === 'active' ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400' :
                        'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'}`}>
                    {(row.status || 'active').toUpperCase()}
                </span>
            )
        },
        { label: 'Role', key: 'accessPanel' },
        {
            label: 'Joined', key: 'createdAt', render: (row) =>
                row.createdAt ? new Date(row.createdAt).toLocaleDateString() : '—'
        },
    ];

    const fields = [
        { name: 'name', label: 'Full Name', type: 'text' },
        { name: 'email', label: 'Email', type: 'email' },
        { name: 'mobile', label: 'Mobile Number', type: 'text' },
        {
            name: 'status',
            label: 'Status',
            type: 'select',
            options: [
                { value: 'active', label: 'Active' },
                { value: 'inactive', label: 'Inactive' }
            ]
        },
        {
            name: 'accessPanel',
            label: 'Role',
            type: 'select',
            options: [
                { value: 'web', label: 'User' },
                { value: 'admin', label: 'Admin' },
                { value: 'seller', label: 'Seller' }
            ]
        },
    ];

    const formik = useFormik({
        initialValues: editingItem || {},
        enableReinitialize: true,
        onSubmit: async (values, { resetForm }) => {
            try {
                if (editingItem) {
                    const id = values.id;
                    await update(id, values);
                } else {
                    // Set default password for new user
                    values.password = values.password || 'default123';
                    await create(values);
                }
                setIsModalOpen(false);
                setEditingItem(null);
                resetForm();
            } catch (e) {
                alert("Operation failed: " + e.message);
            }
        },
    });

    const handleEdit = (item) => {
        setEditingItem(item);
        setIsModalOpen(true);
    };

    const handleDelete = async (item) => {
        if (window.confirm(`Are you sure you want to delete user "${item.name}"?`)) {
            await remove(item.id);
        }
    };

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-gray-800 dark:text-gray-100">User Management</h1>

            <MasterTable
                title="Users"
                data={data}
                loading={loading}
                columns={columns}
                onAdd={() => { setEditingItem(null); setIsModalOpen(true); }}
                onEdit={handleEdit}
                onDelete={handleDelete}
                pagination={pagination}
            />

            {/* Modal */}
            {isModalOpen && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="rounded-lg w-full shadow-xl overflow-hidden max-w-2xl bg-white dark:bg-gray-800 transition-colors">
                        <div className="flex justify-between items-center px-4 py-3 bg-[#2E5A5A] dark:bg-teal-900 text-white">
                            <h3 className="font-bold text-base uppercase tracking-wider">
                                {editingItem ? 'Edit' : 'Add'} User
                            </h3>
                            <button onClick={() => setIsModalOpen(false)} className="text-white hover:text-gray-200">
                                <X size={20} />
                            </button>
                        </div>

                        <form onSubmit={formik.handleSubmit} className="p-6 space-y-4">
                            {fields.map((field) => (
                                <div key={field.name} className="grid grid-cols-[140px_1fr] items-center gap-4">
                                    <label className="text-gray-700 dark:text-gray-300 font-medium text-right">{field.label}</label>
                                    {field.type === 'select' ? (
                                        <select
                                            name={field.name}
                                            onChange={formik.handleChange}
                                            value={formik.values[field.name] || ''}
                                            className="w-full px-3 py-2 border rounded-md dark:bg-gray-700 dark:border-gray-600 dark:text-white"
                                        >
                                            <option value="">Select...</option>
                                            {field.options.map(opt => (
                                                <option key={opt.value} value={opt.value}>{opt.label}</option>
                                            ))}
                                        </select>
                                    ) : (
                                        <input
                                            type={field.type}
                                            name={field.name}
                                            onChange={formik.handleChange}
                                            value={formik.values[field.name] || ''}
                                            className="w-full px-3 py-2 border rounded-md dark:bg-gray-700 dark:border-gray-600 dark:text-white"
                                        />
                                    )}
                                </div>
                            ))}

                            {/* Password field only for new users */}
                            {!editingItem && (
                                <div className="grid grid-cols-[140px_1fr] items-center gap-4">
                                    <label className="text-gray-700 dark:text-gray-300 font-medium text-right">Password</label>
                                    <input
                                        type="password"
                                        name="password"
                                        onChange={formik.handleChange}
                                        value={formik.values.password || ''}
                                        placeholder="Leave blank for default"
                                        className="w-full px-3 py-2 border rounded-md dark:bg-gray-700 dark:border-gray-600 dark:text-white"
                                    />
                                </div>
                            )}

                            <div className="flex justify-end gap-3 pt-4 border-t border-gray-200 dark:border-gray-700">
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
                                    Save
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Users;
