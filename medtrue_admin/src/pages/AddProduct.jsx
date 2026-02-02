import { useFormik } from 'formik';
import * as Yup from 'yup';
import { Upload, X } from 'lucide-react';
import { useState } from 'react';
import { useMasterFacade } from '../facades/useMasterFacade';
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

const AddProduct = () => {
    const [images, setImages] = useState([]);

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
        onSubmit: (values) => {
            console.log('Form Values:', values);
            console.log('Images:', images);
            alert('Product Saved (Check Console)');
        },
    });

    const handleImageUpload = (e) => {
        const files = Array.from(e.target.files);
        setImages([...images, ...files]);
    };

    const removeImage = (index) => {
        setImages(images.filter((_, i) => i !== index));
    };

    const InputField = ({ label, name, type = 'text', placeholder, ...props }) => (
        <div>
            <label className="block text-sm font-semibold text-gray-700 mb-1.5">{label}</label>
            <input
                type={type}
                {...formik.getFieldProps(name)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-1 focus:ring-black focus:border-black focus:outline-none transition-all placeholder:text-gray-400"
                placeholder={placeholder}
                {...props}
            />
            {formik.touched[name] && formik.errors[name] && (
                <p className="text-red-600 text-xs mt-1 font-medium">{formik.errors[name]}</p>
            )}
        </div>
    );

    return (
        <div className="max-w-6xl mx-auto">
            <div className="flex justify-between items-center mb-8">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Add New Product</h1>
                    <p className="text-gray-500 text-sm mt-1">Create a new product in your inventory</p>
                </div>
                <button
                    onClick={formik.handleSubmit}
                    className="bg-black hover:bg-gray-800 text-white px-8 py-2.5 rounded-md font-medium transition-colors text-sm"
                >
                    Save Product
                </button>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Left Column - General Info */}
                <div className="lg:col-span-2 space-y-8">
                    {/* General Information Section */}
                    <div className="bg-white border border-gray-200 rounded-lg p-6">
                        <h2 className="text-lg font-bold text-gray-900 mb-6 border-b border-gray-100 pb-2">General Information</h2>
                        <div className="space-y-5">
                            <InputField label="Product Name" name="name" placeholder="e.g. Dollo 650" />

                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-1.5">Description</label>
                                <textarea
                                    {...formik.getFieldProps('description')}
                                    rows="4"
                                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-1 focus:ring-black focus:border-black focus:outline-none placeholder:text-gray-400"
                                    placeholder="Enter product description"
                                />
                            </div>

                            <div className="grid grid-cols-2 gap-6">
                                <div>
                                    <label className="block text-sm font-semibold text-gray-700 mb-1.5">Company / Brand</label>
                                    <select
                                        {...formik.getFieldProps('companyId')}
                                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-1 focus:ring-black focus:border-black focus:outline-none bg-white"
                                    >
                                        <option value="">Select Company</option>
                                        {loadingCompanies ? <option>Loading...</option> :
                                            companies.map(comp => (
                                                <option key={comp.companyId} value={comp.companyId}>{comp.name}</option>
                                            ))
                                        }
                                    </select>
                                    {formik.touched.companyId && formik.errors.companyId && (
                                        <p className="text-red-600 text-xs mt-1 font-medium">{formik.errors.companyId}</p>
                                    )}
                                </div>
                                <div>
                                    <label className="block text-sm font-semibold text-gray-700 mb-1.5">Category</label>
                                    <select
                                        {...formik.getFieldProps('categoryId')}
                                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-1 focus:ring-black focus:border-black focus:outline-none bg-white"
                                    >
                                        <option value="">Select Category</option>
                                        {loadingCategories ? <option>Loading...</option> :
                                            categories.map(cat => (
                                                <option key={cat.categoryId} value={cat.categoryId}>{cat.name}</option>
                                            ))
                                        }
                                    </select>
                                    {formik.touched.categoryId && formik.errors.categoryId && (
                                        <p className="text-red-600 text-xs mt-1 font-medium">{formik.errors.categoryId}</p>
                                    )}
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-1.5">Salt / Composition</label>
                                <select
                                    {...formik.getFieldProps('saltId')}
                                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-1 focus:ring-black focus:border-black focus:outline-none bg-white"
                                >
                                    <option value="">Select Composition</option>
                                    {loadingSalts ? <option>Loading...</option> :
                                        salts.map(salt => (
                                            <option key={salt.saltId} value={salt.saltId}>{salt.name}</option>
                                        ))
                                    }
                                </select>
                            </div>
                        </div>
                    </div>

                    {/* Pricing Section */}
                    <div className="bg-white border border-gray-200 rounded-lg p-6">
                        <h2 className="text-lg font-bold text-gray-900 mb-6 border-b border-gray-100 pb-2">Pricing</h2>
                        <div className="grid grid-cols-3 gap-6">
                            <InputField label="MRP" name="mrp" type="number" placeholder="0.00" />
                            <InputField label="Purchase Rate" name="purchaseRate" type="number" placeholder="0.00" />
                            <InputField label="Sale Price" name="salePrice" type="number" placeholder="0.00" />
                        </div>
                    </div>
                </div>

                {/* Right Column - Media & Inventory */}
                <div className="space-y-8">
                    {/* Image Upload */}
                    <div className="bg-white border border-gray-200 rounded-lg p-6">
                        <h2 className="text-lg font-bold text-gray-900 mb-6 border-b border-gray-100 pb-2">Product Images</h2>
                        <div className="border border-dashed border-gray-300 rounded-lg p-8 flex flex-col items-center justify-center text-center hover:bg-gray-50 hover:border-black transition-colors cursor-pointer relative group">
                            <input
                                type="file"
                                multiple
                                onChange={handleImageUpload}
                                className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                            />
                            <Upload className="text-gray-400 mb-3 group-hover:text-gray-600 transition-colors" size={40} />
                            <p className="text-sm font-medium text-gray-700">Click to upload image</p>
                            <p className="text-xs text-gray-500 mt-1">SVG, PNG, JPG or GIF</p>
                        </div>

                        {/* Image Preview List */}
                        {images.length > 0 && (
                            <div className="mt-6 space-y-3">
                                {images.map((file, idx) => (
                                    <div key={idx} className="flex items-center justify-between p-3 bg-gray-50 border border-gray-200 rounded-md">
                                        <span className="text-xs font-medium text-gray-700 truncate max-w-[150px]">{file.name}</span>
                                        <button onClick={() => removeImage(idx)} className="text-gray-400 hover:text-red-600 transition-colors">
                                            <X size={16} />
                                        </button>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>

                    {/* Inventory Section */}
                    <div className="bg-white border border-gray-200 rounded-lg p-6">
                        <h2 className="text-lg font-bold text-gray-900 mb-6 border-b border-gray-100 pb-2">Inventory</h2>
                        <div className="space-y-5">
                            <InputField label="SKU / Barcode" name="sku" />
                            <InputField label="Stock Quantity" name="stock" type="number" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default AddProduct;
