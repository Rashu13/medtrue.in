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
            { label: 'Dosage', key: 'dosage' },
            { label: 'Type', key: 'type' },
        ],
        schema: Yup.object({
            name: Yup.string().required('Name is required'),
        }),
        fields: [
            { name: 'name', label: 'Salt Name', type: 'text' },
            { name: 'indications', label: 'Indications', type: 'textarea' },
            { name: 'dosage', label: 'Dosage', type: 'textarea' },
            { name: 'sideEffects', label: 'Side Effects', type: 'textarea' },
            { name: 'specialPrecautions', label: 'Special Precautions', type: 'textarea' },
            { name: 'drugInteractions', label: 'Drug Interactions', type: 'textarea' },
            { name: 'description', label: 'Note', type: 'textarea' },
            {
                name: 'isNarcotic',
                label: 'Narcotic',
                type: 'select',
                options: [{ value: false, label: 'N' }, { value: true, label: 'Y' }]
            },
            {
                name: 'isScheduleH',
                label: 'Schedule H',
                type: 'select',
                options: [{ value: false, label: 'N' }, { value: true, label: 'Y' }]
            },
            {
                name: 'isScheduleH1',
                label: 'Schedule H1',
                type: 'select',
                options: [{ value: false, label: 'N' }, { value: true, label: 'Y' }]
            },
            {
                name: 'type',
                label: 'Type',
                type: 'select',
                options: [{ value: 'Normal', label: 'Normal' }, { value: 'Antibiotic', label: 'Antibiotic' }] // Add more as needed
            },
            { name: 'maximumRate', label: 'Maximum Rate', type: 'number' },
            {
                name: 'isContinued',
                label: 'Continued',
                type: 'select',
                options: [{ value: true, label: 'Yes' }, { value: false, label: 'No' }]
            },
            {
                name: 'isProhibited',
                label: 'Prohibited',
                type: 'select',
                options: [{ value: false, label: 'No' }, { value: true, label: 'Yes' }]
            },
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
                pagination={pagination}
            />

            {/* Modal - Could be extracted to component */}
            {isModalOpen && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="rounded-lg w-full shadow-xl overflow-hidden max-w-4xl bg-sky-50">

                        {/* Header */}
                        <div className="flex justify-between items-center px-4 py-3 bg-[#2E5A5A] text-white">
                            <h3 className="font-bold text-base uppercase tracking-wider">
                                {editingItem ? 'Edit' : 'Add'} {config.title.toUpperCase()}
                            </h3>
                            <button onClick={() => setIsModalOpen(false)} className="text-white hover:text-gray-200">
                                <X size={20} />
                            </button>
                        </div>

                        {/* Unified Legacy Form Layout */}
                        <form onSubmit={formik.handleSubmit} className="p-6 space-y-1 text-sm font-menu bg-sky-50">
                            {config.fields.map((field) => {
                                // Group small usage flags
                                if (['isNarcotic', 'isScheduleH', 'isScheduleH1', 'isContinued', 'isProhibited', 'type', 'maximumRate'].includes(field.name)) return null;

                                return (
                                    <div key={field.name} className="grid grid-cols-[180px_1fr] items-center gap-4">
                                        <label className="text-gray-900 font-medium text-right pr-2">{field.label}</label>
                                        <span className="hidden">:</span> {/* Visual separator if needed */}
                                        {field.type === 'textarea' ? (
                                            <input
                                                name={field.name}
                                                onChange={formik.handleChange}
                                                value={formik.values[field.name] || ''}
                                                className="w-full px-2 py-1 border border-gray-400 bg-white focus:outline-none focus:border-teal-600 h-8"
                                            />
                                        ) : (
                                            <input
                                                type={field.type}
                                                name={field.name}
                                                onChange={formik.handleChange}
                                                value={formik.values[field.name] || ''}
                                                className="w-full px-2 py-1 border border-gray-400 bg-white focus:outline-none focus:border-teal-600 h-8"
                                            />
                                        )}
                                    </div>
                                );
                            })}

                            {/* Special Group for Flags */}
                            <div className="grid grid-cols-[180px_1fr] items-start gap-4 mt-4 pt-4 border-t border-gray-300">
                                <label className="text-gray-900 font-medium text-right pt-1">Classifications</label>
                                <div className="grid grid-cols-2 md:grid-cols-3 gap-x-8 gap-y-2">
                                    {[
                                        { name: 'isNarcotic', label: 'Narcotic' },
                                        { name: 'isScheduleH', label: 'Schedule H' },
                                        { name: 'isScheduleH1', label: 'Schedule H1' },
                                        { name: 'isContinued', label: 'Continued' },
                                        { name: 'isProhibited', label: 'Prohibited' }
                                    ].map(flag => (
                                        <div key={flag.name} className="flex items-center gap-2">
                                            <span className="text-gray-700 min-w-[80px]">{flag.label}</span>
                                            <span className="font-bold">:</span>
                                            <select
                                                name={flag.name}
                                                value={formik.values[flag.name]}
                                                onChange={(e) => formik.setFieldValue(flag.name, e.target.value === 'true')}
                                                className="border border-gray-400 px-1 py-0.5 w-16 text-center"
                                            >
                                                <option value={false}>N</option>
                                                <option value={true}>Y</option>
                                            </select>
                                        </div>
                                    ))}

                                    <div className="flex items-center gap-2">
                                        <span className="text-gray-700 min-w-[80px]">Type</span>
                                        <span className="font-bold">:</span>
                                        <select
                                            name="type"
                                            value={formik.values.type}
                                            onChange={formik.handleChange}
                                            className="border border-gray-400 px-1 py-0.5 w-24"
                                        >
                                            <option value="Normal">Normal</option>
                                            <option value="Antibiotic">Antibiotic</option>
                                        </select>
                                    </div>

                                    <div className="flex items-center gap-2">
                                        <span className="text-gray-700 min-w-[80px]">Max Rate</span>
                                        <span className="font-bold">:</span>
                                        <input
                                            name="maximumRate"
                                            type="number"
                                            value={formik.values.maximumRate || ''}
                                            onChange={formik.handleChange}
                                            className="border border-gray-400 px-1 py-0.5 w-20 text-right"
                                        />
                                    </div>
                                </div>
                            </div>

                            <div className="flex justify-end gap-3 mt-8 pt-4 border-t border-gray-300">
                                <button
                                    type="button"
                                    onClick={() => setIsModalOpen(false)}
                                    className="px-6 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 hover:bg-gray-50"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="px-6 py-1.5 text-sm font-medium text-white bg-[#2E5A5A] hover:bg-[#234444]"
                                >
                                    Save Record
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
