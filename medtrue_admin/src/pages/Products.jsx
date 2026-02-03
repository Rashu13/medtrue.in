import { useProductFacade } from '../facades/useProductFacade';
import MasterTable from '../components/MasterTable';
import { useNavigate } from 'react-router-dom';

const Products = () => {
    const { data, loading, remove } = useProductFacade();
    const navigate = useNavigate();

    const columns = [
        { label: 'Name', key: 'name' },
        { label: 'Packing', key: 'unitPrimaryName' }, // Shows Unit Name instead of Description
        { label: 'MRP', key: 'mrp' },
        { label: 'Min Qty', key: 'minQty' },
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
        const id = item.productId || item.product_id;
        if (id) {
            navigate(`/products/edit/${id}`);
        } else {
            console.error("No ID found for item", item);
            alert("Error: Product ID missing.");
        }
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
