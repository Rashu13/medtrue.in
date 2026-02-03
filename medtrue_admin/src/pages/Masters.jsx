import { useState, useRef } from 'react';
import { useMasterFacade } from '../facades/useMasterFacade';
import MasterTable from '../components/MasterTable';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import { X, Upload } from 'lucide-react';
import api from '../services/api'; // Direct API access for upload

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
            // Extended Fields
            { name: 'preferenceOrderForm', label: 'Order Form', type: 'number' },
            { name: 'preferenceInvoicePrinting', label: 'Invoice Printing', type: 'number' },
            { name: 'dumpDays', label: 'Dump Days', type: 'number' },
            { name: 'expiryReceiveUpto', label: 'Expiry Receive Upto', type: 'number' },
            { name: 'minimumMargin', label: 'Minimum Margin', type: 'number' },
            { name: 'salesTax', label: 'Sales Tax %', type: 'number' },
            { name: 'salesCess', label: 'CESS %', type: 'number' },
            { name: 'purchaseTax', label: 'Purchase Tax %', type: 'number' },
            { name: 'purchaseCess', label: 'CESS %', type: 'number' }
        ]
    },
    categories: {
        title: 'Categories',
        endpoint: 'masters/categories',
        idField: 'categoryId',
        columns: [
            { label: 'Name', key: 'name' },
            { label: 'Image', key: 'imagePath', type: 'image' },
        ],
        schema: Yup.object({
            name: Yup.string().required('Name is required'),
        }),
        fields: [
            { name: 'name', label: 'Category Name', type: 'text' },
            { name: 'imagePath', label: 'Image/Logo', type: 'image' },
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
    packingsizes: {
        title: 'Packing Sizes',
        endpoint: 'masters/packingsizes',
        idField: 'packingSizeId',
        columns: [
            { label: 'Name', key: 'name' },
        ],
        schema: Yup.object({
            name: Yup.string().required('Name is required'),
        }),
        fields: [
            { name: 'name', label: 'Packing Size', type: 'text', placeholder: 'e.g. 100ml, 1x10 tabs, 30 Capsules' },
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
    hsncodes: {
        title: 'HSN/SAC',
        endpoint: 'masters/hsncodes',
        idField: 'hsnSac',
        columns: [
            { label: 'HSN/SAC', key: 'hsnSac' },
            { label: 'Short Name', key: 'shortName' },
            { label: 'IGST %', key: 'igstRate' },
        ],
        schema: Yup.object({
            hsnSac: Yup.string().required('HSN/SAC Code is required'),
        }),
        fields: [
            { name: 'hsnSac', label: 'HSN/SAC Code', type: 'text' },
            { name: 'shortName', label: 'Short Name', type: 'text' },
            { name: 'sgstRate', label: 'SGST %', type: 'number' },
            { name: 'cgstRate', label: 'CGST %', type: 'number' },
            { name: 'igstRate', label: 'IGST %', type: 'number' },
            {
                name: 'type',
                label: 'Type',
                type: 'select',
                options: [{ value: 'Goods', label: 'Goods' }, { value: 'Services', label: 'Services' }]
            },
            { name: 'uqc', label: 'UQC (Unit)', type: 'text' },
            { name: 'cessRate', label: 'CESS %', type: 'number' },
        ]
    },
};

const Masters = () => {
    const [activeTab, setActiveTab] = useState('companies');
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingItem, setEditingItem] = useState(null);
    const fileInputRef = useRef(null);
    const [isUploading, setIsUploading] = useState(false);

    const config = masterConfig[activeTab];
    const { data, loading, create, update, remove, pagination, refresh } = useMasterFacade(config.endpoint);

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

    const handleUploadClick = () => {
        fileInputRef.current.click();
    };

    const handleFileUpload = async (event) => {
        const file = event.target.files[0];
        if (!file) return;

        const formData = new FormData();
        formData.append('file', file);
        setIsUploading(true);

        try {
            await api.post(`/masters/upload/${activeTab}`, formData, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });
            alert('Upload successful! Data imported.');
            refresh();
        } catch (error) {
            console.error(error);
            alert('Upload failed: ' + (error.response?.data || error.message));
        } finally {
            setIsUploading(false);
            event.target.value = null; // Reset input
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold text-gray-800">Master Data Management</h1>
                <div className="flex gap-2">
                    <input
                        type="file"
                        ref={fileInputRef}
                        onChange={handleFileUpload}
                        accept=".xlsx, .xls"
                        className="hidden"
                    />
                    <button
                        onClick={handleUploadClick}
                        disabled={isUploading}
                        className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:bg-gray-400"
                    >
                        <Upload size={16} />
                        {isUploading ? 'Uploading...' : 'Upload XLS'}
                    </button>
                    {/* Template Download Button */}
                    <a
                        href={`${import.meta.env.VITE_API_URL || '/api'}/masters/template/${activeTab}`}
                        target="_blank"
                        rel="noreferrer"
                        className="flex items-center gap-2 px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700"
                        title="Download Demo Excel Template"
                    >
                        <span className="text-sm font-medium">Demo XLS</span>
                    </a>
                </div>
            </div>

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
                                // Specific handling for Salts to skip grouped fields
                                if (activeTab === 'salts' && ['isNarcotic', 'isScheduleH', 'isScheduleH1', 'isContinued', 'isProhibited', 'type', 'maximumRate'].includes(field.name)) return null;

                                // Specific handling for Companies to skip grouped fields
                                if (activeTab === 'companies' && ['preferenceOrderForm', 'preferenceInvoicePrinting', 'dumpDays', 'expiryReceiveUpto', 'minimumMargin', 'salesTax', 'salesCess', 'purchaseTax', 'purchaseCess'].includes(field.name)) return null;

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
                                        ) : field.type === 'image' ? (
                                            <div className="flex items-center gap-2">
                                                <input
                                                    type="file"
                                                    accept="image/*"
                                                    onChange={async (e) => {
                                                        const file = e.target.files[0];
                                                        if (file) {
                                                            const formData = new FormData();
                                                            formData.append('file', file);
                                                            try {
                                                                const res = await api.post('/products/upload-image', formData);
                                                                formik.setFieldValue(field.name, res.data.path);
                                                            } catch (err) {
                                                                alert('Image upload failed');
                                                            }
                                                        }
                                                    }}
                                                    className="flex-1 px-2 py-1 border border-gray-400 bg-white focus:outline-none focus:border-teal-600 h-8 text-sm"
                                                />
                                                {formik.values[field.name] && (
                                                    <img
                                                        src={formik.values[field.name]}
                                                        alt="Preview"
                                                        className="h-8 w-8 object-cover border"
                                                        onError={(e) => e.target.style.display = 'none'}
                                                    />
                                                )}
                                            </div>
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

                            {/* Special Layout ONLY for Companies */}
                            {activeTab === 'companies' && (
                                <div className="space-y-3 mt-2">
                                    {/* Preferences Row */}
                                    <div className="flex items-center">
                                        <label className="w-[180px] text-right font-medium pr-2 text-gray-900">Preferences</label>
                                        <span className="text-gray-700 font-bold px-2">:</span>
                                        <div className="flex items-center">
                                            <div className="w-[230px] flex items-center gap-2">
                                                <span className="text-gray-700">Order Form :</span>
                                                <input
                                                    name="preferenceOrderForm"
                                                    type="number"
                                                    value={formik.values.preferenceOrderForm || ''}
                                                    onChange={formik.handleChange}
                                                    className="border border-gray-400 px-1 py-0.5 w-16 text-center focus:outline-none focus:border-teal-600"
                                                />
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <span className="text-gray-700">Invoice Printing :</span>
                                                <input
                                                    name="preferenceInvoicePrinting"
                                                    type="number"
                                                    value={formik.values.preferenceInvoicePrinting || ''}
                                                    onChange={formik.handleChange}
                                                    className="border border-gray-400 px-1 py-0.5 w-16 text-center focus:outline-none focus:border-teal-600"
                                                />
                                            </div>
                                        </div>
                                    </div>

                                    {/* Dump Days Row */}
                                    <div className="flex items-center">
                                        <label className="w-[180px] text-right font-medium pr-2 text-gray-900">Dump Days</label>
                                        <span className="text-gray-700 font-bold px-2">:</span>
                                        <div className="flex items-center">
                                            <div className="w-[230px] flex items-center gap-2">
                                                <input
                                                    name="dumpDays"
                                                    type="number"
                                                    value={formik.values.dumpDays || ''}
                                                    onChange={formik.handleChange}
                                                    className="border border-gray-400 px-1 py-0.5 w-16 text-center focus:outline-none focus:border-teal-600"
                                                />
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <span className="text-gray-700">Expiry Receive Upto :</span>
                                                <input
                                                    name="expiryReceiveUpto"
                                                    type="number"
                                                    value={formik.values.expiryReceiveUpto || ''}
                                                    onChange={formik.handleChange}
                                                    className="border border-gray-400 px-1 py-0.5 w-16 text-center focus:outline-none focus:border-teal-600"
                                                />
                                            </div>
                                        </div>
                                    </div>

                                    {/* Minimum Margin */}
                                    <div className="flex items-center">
                                        <label className="w-[180px] text-right font-medium pr-2 text-gray-900">Minimum Margin</label>
                                        <span className="text-gray-700 font-bold px-2">:</span>
                                        <div className="w-[230px]">
                                            <input
                                                name="minimumMargin"
                                                type="number"
                                                value={formik.values.minimumMargin || ''}
                                                onChange={formik.handleChange}
                                                className="border border-gray-400 px-1 py-0.5 w-24 text-right focus:outline-none focus:border-teal-600"
                                                placeholder="0.00"
                                            />
                                        </div>
                                    </div>

                                    {/* Sales Tax */}
                                    <div className="flex items-center">
                                        <label className="w-[180px] text-right font-medium pr-2 text-gray-900">Sales Tax %</label>
                                        <span className="text-gray-700 font-bold px-2">:</span>
                                        <div className="flex items-center">
                                            <div className="w-[230px]">
                                                <input
                                                    name="salesTax"
                                                    type="number"
                                                    value={formik.values.salesTax || ''}
                                                    onChange={formik.handleChange}
                                                    className="border border-gray-400 px-1 py-0.5 w-24 text-right focus:outline-none focus:border-teal-600"
                                                    placeholder="0.00"
                                                />
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <span className="text-gray-700">CESS % :</span>
                                                <input
                                                    name="salesCess"
                                                    type="number"
                                                    value={formik.values.salesCess || ''}
                                                    onChange={formik.handleChange}
                                                    className="border border-gray-400 px-1 py-0.5 w-24 text-right focus:outline-none focus:border-teal-600"
                                                    placeholder="0.00"
                                                />
                                            </div>
                                        </div>
                                    </div>

                                    {/* Purchase Tax */}
                                    <div className="flex items-center">
                                        <label className="w-[180px] text-right font-medium pr-2 text-gray-900">Purchase Tax %</label>
                                        <span className="text-gray-700 font-bold px-2">:</span>
                                        <div className="flex items-center">
                                            <div className="w-[230px]">
                                                <input
                                                    name="purchaseTax"
                                                    type="number"
                                                    value={formik.values.purchaseTax || ''}
                                                    onChange={formik.handleChange}
                                                    className="border border-gray-400 px-1 py-0.5 w-24 text-right focus:outline-none focus:border-teal-600"
                                                    placeholder="0.00"
                                                />
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <span className="text-gray-700">CESS % :</span>
                                                <input
                                                    name="purchaseCess"
                                                    type="number"
                                                    value={formik.values.purchaseCess || ''}
                                                    onChange={formik.handleChange}
                                                    className="border border-gray-400 px-1 py-0.5 w-24 text-right focus:outline-none focus:border-teal-600"
                                                    placeholder="0.00"
                                                />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            )}

                            {/* Special Group for Flags (Salts Only) */}
                            {activeTab === 'salts' && (
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
                            )}

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
