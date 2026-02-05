import React from 'react';
import { useFormik } from 'formik';
import * as Yup from 'yup';

const QuickAddModal = ({ isOpen, onClose, type, onSave, title }) => {
    if (!isOpen) return null;

    // Define configuration for each type inside the component or outside
    const config = {
        company: {
            initialValues: { name: '', code: '' },
            validation: Yup.object({
                name: Yup.string().required('Name is required'),
                code: Yup.string().required('Code is required'),
            }),
            fields: [
                { name: 'name', label: 'Company Name' },
                { name: 'code', label: 'Company Code' },
            ]
        },
        category: {
            initialValues: { name: '' },
            validation: Yup.object({
                name: Yup.string().required('Name is required'),
            }),
            fields: [
                { name: 'name', label: 'Category Name' },
                { name: 'imagePath', label: 'Image/Logo', type: 'image' },
            ]
        },
        salt: {
            initialValues: { name: '' },
            validation: Yup.object({
                name: Yup.string().required('Name is required'),
            }),
            fields: [
                { name: 'name', label: 'Salt Name' },
            ]
        },
        unit: {
            initialValues: { name: '', description: '' },
            validation: Yup.object({
                name: Yup.string().required('Name is required'),
            }),
            fields: [
                { name: 'name', label: 'Unit Name' },
                { name: 'description', label: 'Description' },
            ]
        },
        hsn: {
            initialValues: { hsnSac: '', shortName: '', sgstRate: 0, cgstRate: 0, igstRate: 0, type: 'Goods', uqc: '', cessRate: 0 },
            validation: Yup.object({
                hsnSac: Yup.string().required('HSN/SAC Code is required'),
            }),
            fields: [
                { name: 'hsnSac', label: 'HSN/SAC Code' },
                { name: 'shortName', label: 'Short Name' },
                { name: 'sgstRate', label: 'SGST %', type: 'number' },
                { name: 'cgstRate', label: 'CGST %', type: 'number' },
                { name: 'igstRate', label: 'IGST %', type: 'number', readOnly: true },
                {
                    name: 'type',
                    label: 'Type',
                    type: 'select',
                    options: [{ value: 'Goods', label: 'Goods' }, { value: 'Services', label: 'Services' }]
                },
                { name: 'uqc', label: 'UQC (Unit)' },
                { name: 'cessRate', label: 'CESS %', type: 'number' },
            ]
        },
        packingsize: {
            initialValues: { name: '' },
            validation: Yup.object({
                name: Yup.string().required('Name is required'),
            }),
            fields: [
                { name: 'name', label: 'Packing Size (e.g. 10Tabs, 200ml)' },
            ]
        }
    };

    const currentConfig = config[type];

    const formik = useFormik({
        initialValues: currentConfig.initialValues,
        validationSchema: currentConfig.validation,
        onSubmit: async (values) => {
            await onSave(values);
            onClose();
        },
    });

    return (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-[9999]">
            <div className={`bg-white p-6 rounded-lg shadow-xl ${type === 'hsn' ? 'w-[500px]' : 'w-96'}`}>
                <h3 className="text-lg font-bold mb-4 uppercase text-teal-800">Add New {title}</h3>
                <form onSubmit={formik.handleSubmit} className="space-y-4">
                    {currentConfig.fields.map((field) => (
                        <div key={field.name} className="flex flex-col gap-1">
                            <label className="text-sm font-medium text-gray-700">{field.label}</label>
                            {field.type === 'select' ? (
                                <select
                                    name={field.name}
                                    onChange={formik.handleChange}
                                    value={formik.values[field.name]}
                                    className="border border-gray-400 px-2 py-1 text-sm focus:border-teal-600 focus:outline-none bg-white"
                                >
                                    {field.options.map(opt => (
                                        <option key={opt.value} value={opt.value}>{opt.label}</option>
                                    ))}
                                </select>
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
                                                    const res = await api.post('/masters/upload-image', formData, {
                                                        headers: { 'Content-Type': 'multipart/form-data' }
                                                    });
                                                    formik.setFieldValue(field.name, res.path);
                                                } catch (err) {
                                                    const msg = err.response?.data?.message || err.response?.data || err.message;
                                                    alert('Image upload failed: ' + msg);
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
                                    type={field.type || 'text'}
                                    name={field.name}
                                    onChange={(e) => {
                                        formik.handleChange(e);
                                        // Auto-calculate IGST for HSN
                                        if (type === 'hsn' && (field.name === 'sgstRate' || field.name === 'cgstRate')) {
                                            const sgst = field.name === 'sgstRate' ? parseFloat(e.target.value) || 0 : parseFloat(formik.values.sgstRate) || 0;
                                            const cgst = field.name === 'cgstRate' ? parseFloat(e.target.value) || 0 : parseFloat(formik.values.cgstRate) || 0;
                                            formik.setFieldValue('igstRate', sgst + cgst);
                                        }
                                    }}
                                    value={formik.values[field.name]}
                                    readOnly={field.readOnly}
                                    className={`border border-gray-400 px-2 py-1 text-sm focus:border-teal-600 focus:outline-none ${field.readOnly ? 'bg-gray-100' : 'bg-white'}`}
                                />
                            )}
                            {formik.touched[field.name] && formik.errors[field.name] && (
                                <span className="text-red-500 text-xs">{formik.errors[field.name]}</span>
                            )}
                        </div>
                    ))}

                    <div className="flex justify-end gap-2 mt-4">
                        <button
                            type="button"
                            onClick={onClose}
                            className="px-4 py-1 text-sm text-gray-600 border border-gray-300 hover:bg-gray-50"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={formik.isSubmitting}
                            className="px-4 py-1 text-sm text-white bg-teal-700 hover:bg-teal-800"
                        >
                            Save
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default QuickAddModal;
