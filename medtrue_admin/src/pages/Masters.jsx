import { useState } from 'react';
import { useMasterFacade } from '../facades/useMasterFacade';
import MasterTable from '../components/MasterTable';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import { X } from 'lucide-react';

// Configuration for different master types
const masterConfig = {
    companies: {
        title: 'Companies',
        endpoint: 'masters/companies',
        idField: 'companyId',
        columns: [
            { label: 'Name', key: 'name' },
            { label: 'Code', key: 'code' },
            { label: 'Contact', key: 'contactNumber' },
        ],
        schema: Yup.object({
            name: Yup.string().required('Name is required'),
            code: Yup.string().required('Code is required'),
            contactNumber: Yup.string(),
            address: Yup.string(),
        }),
        fields: [
            { name: 'name', label: 'Company Name', type: 'text' },
            { name: 'code', label: 'Code', type: 'text' },
            { name: 'contactNumber', label: 'Contact Number', type: 'text' },
            { name: 'address', label: 'Address', type: 'textarea' },
        ]
    },
    categories: {
        title: 'Categories',
        endpoint: 'masters/categories',
        idField: 'categoryId',
        columns: [
            { label: 'Name', key: 'name' },
        ],
        schema: Yup.object({
            name: Yup.string().required('Name is required'),
        }),
        fields: [
            { name: 'name', label: 'Category Name', type: 'text' },
        ]
    },
    salts: {
        title: 'Salts',
        endpoint: 'masters/salts',
        idField: 'saltId',
        columns: [
            { label: 'Name', key: 'name' },
            { label: 'Description', key: 'description' },
        ],
        schema: Yup.object({
            name: Yup.string().required('Name is required'),
        }),
        fields: [
            { name: 'name', label: 'Salt Name', type: 'text' },
            { name: 'description', label: 'Description', type: 'textarea' },
        ]
    },
    units: {
        title: 'Units',
        endpoint: 'masters/units',
        idField: 'unitId',
        columns: [
            { label: 'Name', key: 'name' },
            { label: 'Description', key: 'description' },
        ],
        schema: Yup.object({
            name: Yup.string().required('Name is required'),
        }),
        fields: [
            { name: 'name', label: 'Unit Name', type: 'text' },
            { name: 'description', label: 'Description', type: 'textarea' },
        ]
    },
    itemtypes: {
        title: 'Item Types',
        endpoint: 'masters/itemtypes',
        idField: 'typeId',
        columns: [
            { label: 'Name', key: 'name' },
        ],
        schema: Yup.object({
            name: Yup.string().required('Name is required'),
        }),
        fields: [
            { name: 'name', label: 'Item Type Name', type: 'text' },
        ]
    },
};

const Masters = () => {
    const [activeTab, setActiveTab] = useState('companies');
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingItem, setEditingItem] = useState(null);

    const config = masterConfig[activeTab];
    const { data, loading, create, update, remove } = useMasterFacade(config.endpoint);

    const formik = useFormik({
        initialValues: editingItem || {},
        enableReinitialize: true,
        onSubmit: async (values, { resetForm }) => {
            try {
                if (editingItem) {
                    const id = values[config.idField];
                    await update(id, values);
                } else {
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
        if (window.confirm('Are you sure you want to delete this item?')) {
            const id = item[config.idField];
            console.log("Attempting delete. Item:", item, "Config ID Field:", config.idField, "Extracted ID:", id);

            if (id !== undefined && id !== null) {
                await remove(id);
            } else {
                console.error("ID not found for deletion.");
                alert(`Delete failed.\nConfig Field: "${config.idField}"\nValue Found: ${id}\nItem Keys: ${Object.keys(item).join(', ')}`);
            }
        }
    };

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-gray-800">Master Data Management</h1>

            {/* Tabs */}
            <div className="flex border-b border-gray-200 space-x-6">
                {Object.keys(masterConfig).map(key => (
                    <button
                        key={key}
                        onClick={() => setActiveTab(key)}
                        className={`pb-3 text-sm font-medium border-b-2 transition-colors ${activeTab === key
                            ? 'border-teal-600 text-teal-600'
                            : 'border-transparent text-gray-500 hover:text-gray-700'
                            }`}
                    >
                        {masterConfig[key].title}
                    </button>
                ))}
            </div>

            <MasterTable
                title={config.title}
                data={data}
                loading={loading}
                columns={config.columns}
                onAdd={() => { setEditingItem(null); setIsModalOpen(true); }}
                onEdit={handleEdit}
                onDelete={handleDelete}
            />

            {/* Modal - Could be extracted to component */}
            {isModalOpen && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-lg w-full max-w-md p-6 shadow-xl">
                        <div className="flex justify-between items-center mb-4">
                            <h3 className="text-lg font-bold">{editingItem ? 'Edit' : 'Add'} {config.title}</h3>
                            <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                                <X size={20} />
                            </button>
                        </div>

                        <form onSubmit={formik.handleSubmit} className="space-y-4">
                            {config.fields.map((field) => (
                                <div key={field.name}>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">{field.label}</label>
                                    {field.type === 'textarea' ? (
                                        <textarea
                                            name={field.name}
                                            onChange={formik.handleChange}
                                            value={formik.values[field.name] || ''}
                                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-teal-500"
                                        />
                                    ) : (
                                        <input
                                            type={field.type}
                                            name={field.name}
                                            onChange={formik.handleChange}
                                            value={formik.values[field.name] || ''}
                                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-teal-500"
                                        />
                                    )}
                                </div>
                            ))}

                            <div className="flex justify-end gap-3 mt-6">
                                <button
                                    type="button"
                                    onClick={() => setIsModalOpen(false)}
                                    className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md"
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

export default Masters;
