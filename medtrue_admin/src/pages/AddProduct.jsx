import { useFormik } from 'formik';
import * as Yup from 'yup';
import { Upload, X } from 'lucide-react';
import { useState } from 'react';
import { useMasterFacade } from '../facades/useMasterFacade';
import { useProductFacade } from '../facades/useProductFacade';
import { useNavigate, useParams } from 'react-router-dom';
import { useEffect } from 'react';
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
import QuickAddModal from '../components/QuickAddModal';

// Legacy Layout Helper
const LegacyInput = ({ label, name, type = 'text', placeholder, formik, ...props }) => (
    <div className="grid grid-cols-[160px_1fr] items-center gap-2">
        <label className="text-gray-900 font-medium text-right pr-2 text-sm">{label}</label>
        <span className="hidden">:</span>
        <input
            type={type}
            {...formik.getFieldProps(name)}
            className="w-full px-2 py-0.5 border border-gray-400 bg-white focus:outline-none focus:border-teal-600 h-7 text-sm"
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
    const { id } = useParams();
    const isEditMode = !!id;
    const [images, setImages] = useState([]);
    const { create: createProduct, update: updateProduct, getById, generateSku, loading: productLoading } = useProductFacade();

    // Auto-generate SKU on mount (Add Mode only)
    useEffect(() => {
        if (!isEditMode) {
            const fetchSku = async () => {
                const sku = await generateSku();
                if (sku) formik.setFieldValue('sku', sku);
            };
            fetchSku();
        }
    }, [isEditMode]);

    const [quickAddType, setQuickAddType] = useState(null); // 'company', 'category', 'salt', 'unit'

    // Facades for Dropdowns - Extract create and refresh
    const { data: companies, loading: loadingCompanies, create: createCompany, refresh: refreshCompanies } = useMasterFacade('masters/companies', 2000);
    const { data: categories, loading: loadingCategories, create: createCategory, refresh: refreshCategories } = useMasterFacade('masters/categories', 2000);
    const { data: salts, loading: loadingSalts, create: createSalt, refresh: refreshSalts } = useMasterFacade('masters/salts', 2000);
    const { data: units, loading: loadingUnits, create: createUnit, refresh: refreshUnits } = useMasterFacade('masters/units', 2000);
    const { data: hsnCodes, loading: loadingHsn, create: createHsn, refresh: refreshHsn } = useMasterFacade('masters/hsncodes', 2000);
    const { data: packingSizes, loading: loadingPackingSizes, create: createPackingSize, refresh: refreshPackingSizes } = useMasterFacade('masters/packingsizes', 2000);

    const handleQuickSave = async (values) => {
        try {
            if (quickAddType === 'company') {
                await createCompany(values);
                refreshCompanies();
            } else if (quickAddType === 'category') {
                await createCategory(values);
                refreshCategories();
            } else if (quickAddType === 'salt') {
                await createSalt(values);
                refreshSalts();
            } else if (quickAddType === 'unit') {
                await createUnit(values);
                refreshUnits();
            } else if (quickAddType === 'hsn') {
                await createHsn(values);
                refreshHsn();
            } else if (quickAddType === 'packingsize') {
                await createPackingSize(values);
                refreshPackingSizes();
            }
            alert(`${quickAddType.toUpperCase()} added successfully!`);
        } catch (error) {
            console.error(error);
            alert(`Failed to add ${quickAddType}`);
        }
    };

    const formik = useFormik({
        initialValues: {
            name: '',
            description: '',
            companyId: '',
            categoryId: '',
            saltId: '',
            unitPrimaryId: '',
            unitSecondaryId: '',
            packingSizeId: '',
            mrp: '',
            discountPercent: '',
            purchaseRate: '',
            salePrice: '',
            sku: '',
            stock: '',
            minQty: '',
            maxQty: '',
            hsnCode: '',
        },
        validationSchema,
        onSubmit: async (values) => {
            try {
                // Map frontend keys to backend keys
                const payload = {
                    ...values,
                    productId: id, // Required for backend validation
                    packingDesc: values.description,
                    barcode: values.sku,
                    unitPrimaryId: values.unitPrimaryId,
                    unitSecondaryId: values.unitSecondaryId,
                    packingSizeId: values.packingSizeId || null,
                    itemDiscount1: values.discountPercent || 0,
                    salePrice: values.salePrice || 0,
                    currentStock: values.stock || 0,
                    minQty: values.minQty || 0,
                    maxQty: values.maxQty || 0,
                    hsnCode: values.hsnCode || null,
                };

                if (isEditMode) {
                    await updateProduct(id, payload, images);
                    alert('Product Updated Successfully!');
                } else {
                    await createProduct(payload, images);
                    alert('Product Saved Successfully!');
                }
                navigate('/products');
            } catch (error) {
                console.error('Failed to save product:', error);
                alert('Failed to save product. Check console for details.');
            }
        },
    });

    useEffect(() => {
        const loadProduct = async () => {
            if (isEditMode) {
                try {
                    const product = await getById(id);
                    if (product) {
                        formik.setValues({
                            name: product.name || '',
                            description: product.packingDesc || '', // Map from Backend name
                            companyId: product.companyId || '',
                            categoryId: product.categoryId || '',
                            saltId: product.saltId || '',
                            unitPrimaryId: product.unitPrimaryId || '',
                            unitSecondaryId: product.unitSecondaryId || '',
                            packingSizeId: product.packingSizeId || '',
                            mrp: product.mrp || '',
                            discountPercent: product.itemDiscount1 || '',
                            purchaseRate: product.purchaseRate || '',
                            salePrice: product.salePrice || '',
                            sku: product.barcode || '', // Map from Backend name
                            stock: product.currentStock || '',
                            minQty: product.minQty || '',
                            maxQty: product.maxQty || '',
                            hsnCode: product.hsnCode || '',
                        });
                        setImages(product.images || []);
                    }
                } catch (error) {
                    console.error("Error loading product", error);
                    alert("Could not load product details");
                    navigate('/products');
                }
            }
        };
        loadProduct();
    }, [id]);

    // ... existing image handlers ...

    // Insert Inputs in JSX
    /* 
       Ideally I would replace the whole component content or use multiple replace blocks 
       but since replace_file_content is restricted to contiguous blocks, I have to ensure 
       I target the right place for JSX insertion.
       Actually, the UI part is further down.
       I will use this block to handle LOGIC (initialValues, onSubmit, useEffect).
       Then I will make another call for the UI.
    */


    const handleImageUpload = (e) => {
        const files = Array.from(e.target.files);
        setImages([...images, ...files]);
    };

    const removeImage = (index) => {
        setImages(images.filter((_, i) => i !== index));
    };

    return (
        <div className="max-w-5xl mx-auto mt-2 shadow-xl rounded-lg overflow-hidden border border-gray-300">
            {/* Legacy Header */}
            <div className="bg-[#2E5A5A] px-4 py-2 flex justify-between items-center text-white">
                <h1 className="text-lg font-bold uppercase tracking-wider">{isEditMode ? 'Edit Product' : 'Add New Product'}</h1>
                <button
                    onClick={() => navigate('/products')}
                    className="text-white hover:text-gray-200"
                >
                    <X size={20} />
                </button>
            </div>

            {/* Legacy Body */}
            <div className="bg-sky-50 p-3 grid grid-cols-1 lg:grid-cols-2 gap-4 font-menu text-sm">

                {/* Left Column: General & Pricing */}
                <div className="space-y-1.5">
                    <h3 className="font-bold text-teal-800 border-b border-teal-200 pb-0.5 mb-2 text-sm">General Information</h3>

                    <LegacyInput formik={formik} label="Product Name" name="name" />

                    <div className="grid grid-cols-[160px_1fr] items-start gap-2">
                        <label className="text-gray-900 font-medium text-right pr-2 pt-1 text-sm">Description</label>
                        <textarea
                            {...formik.getFieldProps('description')}
                            rows="2"
                            className="w-full px-2 py-1 border border-gray-400 bg-white focus:outline-none focus:border-teal-600 text-sm"
                        />
                    </div>

                    <SearchableSelect
                        formik={formik}
                        label="Company"
                        name="companyId"
                        loading={loadingCompanies}
                        options={companies.map(c => ({ value: c.companyId, label: c.name }))}
                        onAdd={() => setQuickAddType('company')}
                    />

                    <SearchableSelect
                        formik={formik}
                        label="Category"
                        name="categoryId"
                        loading={loadingCategories}
                        options={categories.map(c => ({ value: c.categoryId, label: c.name }))}
                        onAdd={() => setQuickAddType('category')}
                    />

                    <SearchableSelect
                        formik={formik}
                        label="Salt Composition"
                        name="saltId"
                        loading={loadingSalts}
                        options={salts.map(s => ({ value: s.saltId, label: s.name }))}
                        onAdd={() => setQuickAddType('salt')}
                    />

                    <SearchableSelect
                        formik={formik}
                        label="HSN/SAC Code"
                        name="hsnCode"
                        loading={loadingHsn}
                        options={hsnCodes.map(h => ({ value: h.hsnSac, label: `${h.hsnSac} - ${h.shortName || ''}` }))}
                        onAdd={() => setQuickAddType('hsn')}
                    />

                    <h3 className="font-bold text-teal-800 border-b border-teal-200 pb-0.5 mb-2 mt-3 text-sm">Unit Packing</h3>
                    <div className="grid grid-cols-1 gap-2">
                        <SearchableSelect
                            formik={formik}
                            label="Primary Unit"
                            name="unitPrimaryId"
                            placeholder="e.g. Strip, Bottle, Vial"
                            loading={loadingUnits}
                            options={units.map(u => ({ value: u.unitId, label: u.name }))}
                            onAdd={() => setQuickAddType('unit')}
                        />
                        <SearchableSelect
                            formik={formik}
                            label="Secondary Unit"
                            name="unitSecondaryId"
                            placeholder="e.g. Tabs, Caps, Syp, Gran"
                            loading={loadingUnits}
                            options={units.map(u => ({ value: u.unitId, label: u.name }))}
                            onAdd={() => setQuickAddType('unit')}
                        />
                        <SearchableSelect
                            formik={formik}
                            label="Packing Size"
                            name="packingSizeId"
                            placeholder="e.g. 10Tabs, 200ml, 100gm"
                            loading={loadingPackingSizes}
                            options={packingSizes.map(p => ({ value: p.packingSizeId, label: p.name }))}
                            onAdd={() => setQuickAddType('packingsize')}
                        />
                    </div>

                    <h3 className="font-bold text-teal-800 border-b border-teal-200 pb-0.5 mb-2 mt-3 text-sm">Pricing</h3>
                    <LegacyInput formik={formik} label="MRP" name="mrp" type="number" onChange={(e) => {
                        formik.handleChange(e);
                        const mrp = parseFloat(e.target.value) || 0;
                        const discount = parseFloat(formik.values.discountPercent) || 0;
                        formik.setFieldValue('salePrice', (mrp - (mrp * discount / 100)).toFixed(2));
                    }} />
                    <LegacyInput formik={formik} label="Discount %" name="discountPercent" type="number" placeholder="e.g. 10" onChange={(e) => {
                        formik.handleChange(e);
                        const mrp = parseFloat(formik.values.mrp) || 0;
                        const discount = parseFloat(e.target.value) || 0;
                        formik.setFieldValue('salePrice', (mrp - (mrp * discount / 100)).toFixed(2));
                    }} />
                    <LegacyInput formik={formik} label="Purchase Rate" name="purchaseRate" type="number" />
                    <LegacyInput formik={formik} label="Sale Price" name="salePrice" type="number" />

                </div>

                {/* Right Column: Inventory & Images */}
                <div className="space-y-1.5">
                    <h3 className="font-bold text-teal-800 border-b border-teal-200 pb-0.5 mb-2 text-sm">Inventory</h3>
                    <LegacyInput formik={formik} label="SKU / Barcode" name="sku" />
                    <LegacyInput formik={formik} label="Stock Quantity" name="stock" type="number" />
                    <LegacyInput formik={formik} label="Min Qty" name="minQty" type="number" />
                    <LegacyInput formik={formik} label="Max Qty" name="maxQty" type="number" />

                    <h3 className="font-bold text-teal-800 border-b border-teal-200 pb-0.5 mb-2 mt-3 text-sm">Product Images</h3>
                    <div className="grid grid-cols-[160px_1fr] gap-2">
                        <label className="text-gray-900 font-medium text-right pr-2 pt-1 text-sm">Upload Files</label>
                        <div>
                            <div className="border border-dashed border-gray-400 bg-white p-2 text-center cursor-pointer hover:bg-gray-50 relative">
                                <input
                                    type="file"
                                    multiple
                                    onChange={handleImageUpload}
                                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                                />
                                <Upload className="mx-auto text-gray-500 mb-1" size={20} />
                                <span className="text-gray-600 text-xs">Click to upload</span>
                            </div>

                            {images.length > 0 && (
                                <ul className="mt-2 space-y-1">
                                    {images.map((file, idx) => {
                                        // Determine Name and Preview URL
                                        let name = file.name;
                                        let thumbUrl = null;

                                        if (!name && file.imagePath) {
                                            // It's a server image
                                            name = file.imagePath.split('/').pop().split('_').slice(1).join('_'); // Remove ID prefix if possible or just show full
                                            if (!name) name = file.imagePath.split('/').pop();
                                            thumbUrl = file.imagePath; // Use relative path, proxy handles it
                                        } else if (file instanceof File) {
                                            // It's a local file
                                            thumbUrl = URL.createObjectURL(file);
                                        }

                                        return (
                                            <li key={idx} className="flex justify-between items-center bg-white border border-gray-200 px-2 py-1">
                                                <div className="flex items-center gap-2 overflow-hidden">
                                                    {thumbUrl && (
                                                        <img src={thumbUrl} alt="prev" className="h-8 w-8 object-cover border border-gray-300" />
                                                    )}
                                                    <span className="text-xs truncate max-w-[170px]" title={name}>{name}</span>
                                                </div>
                                                <button onClick={() => removeImage(idx)} className="text-red-500 hover:text-red-700" type="button">
                                                    <X size={14} />
                                                </button>
                                            </li>
                                        );
                                    })}
                                </ul>
                            )}
                        </div>
                    </div>
                </div>
            </div>

            {/* Footer Actions */}
            <div className="bg-gray-100 px-4 py-2 flex justify-end gap-3 border-t border-gray-300">
                <button
                    onClick={() => navigate('/products')}
                    className="px-6 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 uppercase shadow-sm"
                >
                    Cancel
                </button>
                <button
                    onClick={formik.handleSubmit}
                    disabled={productLoading}
                    className="px-6 py-1.5 text-sm font-medium text-white bg-[#2E5A5A] hover:bg-[#234444] uppercase shadow-sm disabled:opacity-70"
                >
                    {productLoading ? 'Saving...' : (isEditMode ? 'Update Product' : 'Save Product')}
                </button>
            </div>
            {/* Quick Add Modal */}
            <QuickAddModal
                isOpen={!!quickAddType}
                onClose={() => setQuickAddType(null)}
                type={quickAddType}
                title={quickAddType}
                onSave={handleQuickSave}
            />
        </div>
    );
};

export default AddProduct;
