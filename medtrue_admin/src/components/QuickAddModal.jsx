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
            <div className="bg-white p-6 rounded-lg shadow-xl w-96">
                <h3 className="text-lg font-bold mb-4 uppercase text-teal-800">Add New {title}</h3>
                <form onSubmit={formik.handleSubmit} className="space-y-4">
                    {currentConfig.fields.map((field) => (
                        <div key={field.name} className="flex flex-col gap-1">
                            <label className="text-sm font-medium text-gray-700">{field.label}</label>
                            <input
                                name={field.name}
                                onChange={formik.handleChange}
                                value={formik.values[field.name]}
                                className="border border-gray-400 px-2 py-1 text-sm focus:border-teal-600 focus:outline-none"
                            />
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
