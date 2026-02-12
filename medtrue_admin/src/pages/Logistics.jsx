import { useState } from 'react';
import { useMasterFacade } from '../facades/useMasterFacade';
import MasterTable from '../components/MasterTable';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import { X } from 'lucide-react';

const logisticsConfig = {
    'delivery-boys': {
        title: 'Delivery Boys',
        endpoint: 'logistics/delivery-boys',
        idField: 'id',
        columns: [
            { label: 'Full Name', key: 'fullName' },
            { label: 'Vehicle Type', key: 'vehicleType' },
            { label: 'Status', key: 'status' },
        ],
        schema: Yup.object({
            fullName: Yup.string().required('Name is required'),
            vehicleType: Yup.string().required('Vehicle Type is required'),
        }),
        fields: [
            { name: 'fullName', label: 'Full Name', type: 'text' },
            { name: 'address', label: 'Address', type: 'textarea' },
            {
                name: 'vehicleType',
                label: 'Vehicle Type',
                type: 'select',
                options: [{ value: 'bike', label: 'Bike' }, { value: 'scooter', label: 'Scooter' }, { value: 'van', label: 'Van' }]
            },
            { name: 'vehicleRegistration', label: 'Vehicle Reg. No.', type: 'text' },
            {
                name: 'status',
                label: 'Status',
                type: 'select',
                options: [{ value: 'active', label: 'Active' }, { value: 'inactive', label: 'Inactive' }]
            },
        ]
    },
    'delivery-zones': {
        title: 'Delivery Zones',
        endpoint: 'logistics/delivery-zones',
        idField: 'id',
        columns: [
            { label: 'Name', key: 'name' },
            { label: 'Radius (km)', key: 'radiusKm' },
            { label: 'Status', key: 'status' },
        ],
        schema: Yup.object({
            name: Yup.string().required('Name is required'),
            radiusKm: Yup.number().required('Radius is required'),
        }),
        fields: [
            { name: 'name', label: 'Zone Name', type: 'text' },
            { name: 'slug', label: 'Slug', type: 'text' },
            { name: 'centerLatitude', label: 'Latitude', type: 'number' },
            { name: 'centerLongitude', label: 'Longitude', type: 'number' },
            { name: 'radiusKm', label: 'Radius (KM)', type: 'number' },
            {
                name: 'status',
                label: 'Status',
                type: 'select',
                options: [{ value: 'active', label: 'Active' }, { value: 'inactive', label: 'Inactive' }]
            },
        ]
    },
    'stores': {
        title: 'Stores',
        endpoint: 'logistics/stores',
        idField: 'id',
        columns: [
            { label: 'Name', key: 'name' },
            { label: 'City', key: 'city' },
            { label: 'Contact', key: 'contactNumber' },
            { label: 'Status', key: 'status' },
        ],
        schema: Yup.object({
            name: Yup.string().required('Name is required'),
            contactNumber: Yup.string().required('Contact Number is required'),
        }),
        fields: [
            { name: 'name', label: 'Store Name', type: 'text' },
            { name: 'slug', label: 'Slug', type: 'text' },
            { name: 'address', label: 'Address', type: 'textarea' },
            { name: 'city', label: 'City', type: 'text' },
            { name: 'state', label: 'State', type: 'text' },
            { name: 'zipcode', label: 'Zipcode', type: 'text' },
            { name: 'contactNumber', label: 'Contact Number', type: 'text' },
            { name: 'contactEmail', label: 'Email', type: 'email' },
            {
                name: 'status',
                label: 'Status',
                type: 'select',
                options: [{ value: 'online', label: 'Online' }, { value: 'offline', label: 'Offline' }]
            },
        ]
    }
};

const Logistics = () => {
    const [activeTab, setActiveTab] = useState('delivery-boys');
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingItem, setEditingItem] = useState(null);

    const config = logisticsConfig[activeTab];
    const { data, loading, create, update, remove, pagination } = useMasterFacade(config.endpoint);

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
            await remove(id);
        }
    };

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-gray-800 dark:text-gray-100">Logistics Management</h1>

            {/* Tabs */}
            <div className="flex border-b border-gray-200 dark:border-gray-700 space-x-6">
                {Object.keys(logisticsConfig).map(key => (
                    <button
                        key={key}
                        onClick={() => setActiveTab(key)}
                        className={`pb-3 text-sm font-medium border-b-2 transition-colors ${activeTab === key
                            ? 'border-teal-600 text-teal-600 dark:text-teal-400 dark:border-teal-400'
                            : 'border-transparent text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200'
                            }`}
                    >
                        {logisticsConfig[key].title}
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
                pagination={pagination}
            />

            {/* Modal */}
            {isModalOpen && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="rounded-lg w-full shadow-xl overflow-hidden max-w-2xl bg-white dark:bg-gray-800 transition-colors">
                        <div className="flex justify-between items-center px-4 py-3 bg-[#2E5A5A] dark:bg-teal-900 text-white">
                            <h3 className="font-bold text-base uppercase tracking-wider">
                                {editingItem ? 'Edit' : 'Add'} {config.title}
                            </h3>
                            <button onClick={() => setIsModalOpen(false)} className="text-white hover:text-gray-200">
                                <X size={20} />
                            </button>
                        </div>

                        <form onSubmit={formik.handleSubmit} className="p-6 space-y-4">
                            {config.fields.map((field) => (
                                <div key={field.name} className="grid grid-cols-[140px_1fr] items-center gap-4">
                                    <label className="text-gray-700 dark:text-gray-300 font-medium text-right">{field.label}</label>
                                    {field.type === 'textarea' ? (
                                        <textarea
                                            name={field.name}
                                            onChange={formik.handleChange}
                                            value={formik.values[field.name] || ''}
                                            className="w-full px-3 py-2 border rounded-md dark:bg-gray-700 dark:border-gray-600 dark:text-white"
                                            rows="3"
                                        />
                                    ) : field.type === 'select' ? (
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

export default Logistics;
