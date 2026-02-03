import { useFormik } from 'formik';
import * as Yup from 'yup';
import { Upload, X } from 'lucide-react';
import { useState } from 'react';
import { useMasterFacade } from '../facades/useMasterFacade';
import { useProductFacade } from '../facades/useProductFacade';
import { useNavigate } from 'react-router-dom';
import clsx from 'clsx';

// Flat Design: No shadows, light borders, high contrast labels
const validationSchema = Yup.object({
    name: Yup.string().required('Product Name is required'),
    mrp: Yup.number().required('MRP is required'),
    purchaseRate: Yup.number().required('Purchase Rate is required'),
    companyId: Yup.string().required('Company is required'),
    categoryId: Yup.string().required('Category is required'),
    saltId: Yup.string().nullable(), // Optional but recommended
});

import SearchableSelect from '../components/SearchableSelect';

// Legacy Layout Helper
const LegacyInput = ({ label, name, type = 'text', placeholder, formik, ...props }) => (
    <div className="grid grid-cols-[180px_1fr] items-center gap-4">
        <label className="text-gray-900 font-medium text-right pr-2">{label}</label>
        <span className="hidden">:</span>
        <input
            type={type}
            {...formik.getFieldProps(name)}
            className="w-full px-2 py-1 border border-gray-400 bg-white focus:outline-none focus:border-teal-600 h-8 text-sm"
            placeholder={placeholder}
            {...props}
        />
        {formik.touched[name] && formik.errors[name] && (
            <p className="text-red-600 text-xs text-right col-start-2">{formik.errors[name]}</p>
        )}
    </div>
);

const AddProduct = () => {
    const navigate = useNavigate();
    const [images, setImages] = useState([]);
    const { create: createProduct, loading: creating } = useProductFacade();

    // Facades for Dropdowns
    const { data: companies, loading: loadingCompanies } = useMasterFacade('masters/companies');
    const { data: categories, loading: loadingCategories } = useMasterFacade('masters/categories');
    const { data: salts, loading: loadingSalts } = useMasterFacade('masters/salts');

    const formik = useFormik({
        initialValues: {
            name: '',
            description: '',
            companyId: '',
            categoryId: '',
            saltId: '',
            mrp: '',
            purchaseRate: '',
            salePrice: '',
            sku: '',
            stock: '',
        },
        validationSchema,
        onSubmit: async (values) => {
            try {
                await createProduct(values, images);
                alert('Product Saved Successfully!');
                navigate('/products');
            } catch (error) {
                console.error('Failed to create product:', error);
                alert('Failed to save product. Check console for details.');
            }
        },
    });

    const handleImageUpload = (e) => {
        const files = Array.from(e.target.files);
        setImages([...images, ...files]);
    };

    const removeImage = (index) => {
        setImages(images.filter((_, i) => i !== index));
    };

    return (
        <div className="max-w-5xl mx-auto mt-6 shadow-xl rounded-lg overflow-hidden border border-gray-300">
            {/* Legacy Header */}
            <div className="bg-[#2E5A5A] px-6 py-3 flex justify-between items-center text-white">
                <h1 className="text-lg font-bold uppercase tracking-wider">Add New Product</h1>
                <button
                    onClick={() => navigate('/products')}
                    className="text-white hover:text-gray-200"
                >
                    <X size={20} />
                </button>
            </div>

            {/* Legacy Body */}
            <div className="bg-sky-50 p-6 grid grid-cols-1 lg:grid-cols-2 gap-8 font-menu text-sm">

                {/* Left Column: General & Pricing */}
                <div className="space-y-4">
                    <h3 className="font-bold text-teal-800 border-b border-teal-200 pb-1 mb-3">General Information</h3>

                    <LegacyInput formik={formik} label="Product Name" name="name" />

                    <div className="grid grid-cols-[180px_1fr] items-start gap-4">
                        <label className="text-gray-900 font-medium text-right pr-2 pt-1">Description</label>
                        <textarea
                            {...formik.getFieldProps('description')}
                            rows="3"
                            className="w-full px-2 py-1 border border-gray-400 bg-white focus:outline-none focus:border-teal-600 text-sm"
                        />
                    </div>

                    <SearchableSelect
                        formik={formik}
                        label="Company"
                        name="companyId"
                        loading={loadingCompanies}
                        options={companies.map(c => ({ value: c.companyId, label: c.name }))}
                    />

                    <SearchableSelect
                        formik={formik}
                        label="Category"
                        name="categoryId"
                        loading={loadingCategories}
                        options={categories.map(c => ({ value: c.categoryId, label: c.name }))}
                    />

                    <SearchableSelect
                        formik={formik}
                        label="Salt Composition"
                        name="saltId"
                        loading={loadingSalts}
                        options={salts.map(s => ({ value: s.saltId, label: s.name }))}
                    />

                    <h3 className="font-bold text-teal-800 border-b border-teal-200 pb-1 mb-3 mt-6">Pricing</h3>
                    <LegacyInput formik={formik} label="MRP" name="mrp" type="number" />
                    <LegacyInput formik={formik} label="Purchase Rate" name="purchaseRate" type="number" />
                    <LegacyInput formik={formik} label="Sale Price" name="salePrice" type="number" />

                </div>

                {/* Right Column: Inventory & Images */}
                <div className="space-y-4">
                    <h3 className="font-bold text-teal-800 border-b border-teal-200 pb-1 mb-3">Inventory</h3>
                    <LegacyInput formik={formik} label="SKU / Barcode" name="sku" />
                    <LegacyInput formik={formik} label="Stock Quantity" name="stock" type="number" />

                    <h3 className="font-bold text-teal-800 border-b border-teal-200 pb-1 mb-3 mt-6">Product Images</h3>
                    <div className="grid grid-cols-[180px_1fr] gap-4">
                        <label className="text-gray-900 font-medium text-right pr-2 pt-2">Upload Files</label>
                        <div>
                            <div className="border border-dashed border-gray-400 bg-white p-4 text-center cursor-pointer hover:bg-gray-50 relative">
                                <input
                                    type="file"
                                    multiple
                                    onChange={handleImageUpload}
                                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                                />
                                <Upload className="mx-auto text-gray-500 mb-2" size={24} />
                                <span className="text-gray-600 text-xs">Click to upload images</span>
                            </div>

                            {images.length > 0 && (
                                <ul className="mt-2 space-y-1">
                                    {images.map((file, idx) => (
                                        <li key={idx} className="flex justify-between items-center bg-white border border-gray-200 px-2 py-1">
                                            <span className="text-xs truncate max-w-[200px]">{file.name}</span>
                                            <button onClick={() => removeImage(idx)} className="text-red-500 hover:text-red-700">
                                                <X size={14} />
                                            </button>
                                        </li>
                                    ))}
                                </ul>
                            )}
                        </div>
                    </div>
                </div>
            </div>

            {/* Footer Actions */}
            <div className="bg-gray-100 px-6 py-4 flex justify-end gap-3 border-t border-gray-300">
                <button
                    onClick={() => navigate('/products')}
                    className="px-6 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 uppercase shadow-sm"
                >
                    Cancel
                </button>
                <button
                    onClick={formik.handleSubmit}
                    disabled={creating}
                    className="px-6 py-1.5 text-sm font-medium text-white bg-[#2E5A5A] hover:bg-[#234444] uppercase shadow-sm disabled:opacity-70"
                >
                    {creating ? 'Saving...' : 'Save Product'}
                </button>
            </div>
        </div>
    );
};

export default AddProduct;
