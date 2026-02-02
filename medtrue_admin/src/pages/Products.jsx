import { useProductFacade } from '../facades/useProductFacade';
import MasterTable from '../components/MasterTable';
import { useNavigate } from 'react-router-dom';

const Products = () => {
    const { data, loading, remove } = useProductFacade();
    const navigate = useNavigate();

    const columns = [
        { label: 'Name', key: 'name' },
        { label: 'Packing', key: 'packing_desc' },
        { label: 'MRP', key: 'mrp' },
        { label: 'Min Qty', key: 'min_qty' },
    ];

    const handleDelete = async (item) => {
        if (window.confirm(`Are you sure you want to delete "${item.name}"?`)) {
            try {
                // Ensure we are using the correct ID field. The backend returns 'productId' or 'product_id' depending on serialization.
                // Based on MasterModels, it seems PascalCase 'ProductId' might be expected in C# but API returns correct JSON.
                // Let's safe check both.
                const id = item.productId || item.product_id;
                await remove(id);
            } catch (e) {
                alert("Failed to delete product: " + e.message);
            }
        }
    };

    const handleEdit = (item) => {
        // Navigate to edit page (To be implemented fully later if needed, mostly AddProduct handles it?)
        // For now, redirect to AddProduct with ID potentially or just log.
        // Since we don't have a dedicated Edit route setup in Plan, I'll point to add with query or ID.
        // Checking App.jsx: Route path="products/add" is the only one.
        // Ideally we should have products/edit/:id.
        // For this task, I'll just focus on List and Delete.
        console.log("Edit clicked", item);
        alert("Edit functionality to be linked to AddProduct page");
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold text-gray-800">Products</h1>
            </div>

            <MasterTable
                title="Product List"
                data={data}
                loading={loading}
                columns={columns}
                onAdd={() => navigate('/products/add')}
                onEdit={handleEdit}
                onDelete={handleDelete}
            />
        </div>
    );
};

export default Products;
