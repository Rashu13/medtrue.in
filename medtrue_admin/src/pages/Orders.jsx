import { useState } from 'react';
import { useOrderFacade } from '../facades/useOrderFacade';
import MasterTable from '../components/MasterTable';
import { X, Eye, CheckCircle } from 'lucide-react';
import api from '../services/api';

const ORDER_STATUSES = [
    { value: 'pending', label: 'Pending', color: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400' },
    { value: 'confirmed', label: 'Confirmed', color: 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400' },
    { value: 'processing', label: 'Processing', color: 'bg-indigo-100 text-indigo-800 dark:bg-indigo-900/30 dark:text-indigo-400' },
    { value: 'out_for_delivery', label: 'Out for Delivery', color: 'bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400' },
    { value: 'delivered', label: 'Delivered', color: 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400' },
    { value: 'cancelled', label: 'Cancelled', color: 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400' },
];

const getStatusStyle = (status) => {
    const found = ORDER_STATUSES.find(s => s.value === status);
    return found?.color || 'bg-gray-100 text-gray-800';
};

const Orders = () => {
    const { data, loading, pagination, refresh } = useOrderFacade();
    const [selectedOrder, setSelectedOrder] = useState(null);
    const [orderItems, setOrderItems] = useState([]);
    const [loadingDetails, setLoadingDetails] = useState(false);
    const [statusUpdating, setStatusUpdating] = useState(false);

    const columns = [
        { label: 'Order ID', key: 'slug' },
        {
            label: 'Date', key: 'createdAt', render: (row) =>
                row.createdAt ? new Date(row.createdAt).toLocaleDateString() : '—'
        },
        { label: 'Customer', key: 'billingName' },
        { label: 'Amount', key: 'finalTotal', render: (row) => `₹${row.finalTotal || 0}` },
        {
            label: 'Status', key: 'status', render: (row) => (
                <span className={`px-2 py-1 rounded-full text-xs font-semibold ${getStatusStyle(row.status)}`}>
                    {(row.status || 'pending').toUpperCase()}
                </span>
            )
        },
        {
            label: 'Payment', key: 'paymentStatus', render: (row) => (
                <span className={`px-2 py-1 rounded-full text-xs font-semibold ${row.paymentStatus === 'paid'
                    ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
                    : 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400'
                    }`}>
                    {(row.paymentStatus || 'pending').toUpperCase()}
                </span>
            )
        },
    ];

    const viewOrder = async (item) => {
        setLoadingDetails(true);
        try {
            const res = await api.get(`/orders/${item.id}`);
            setSelectedOrder(res.data.order || res.data.Order || item);
            setOrderItems(res.data.items || res.data.Items || []);
        } catch {
            setSelectedOrder(item);
            setOrderItems([]);
        }
        setLoadingDetails(false);
    };

    const updateStatus = async (orderId, newStatus) => {
        setStatusUpdating(true);
        try {
            await api.put(`/orders/${orderId}/status`, { status: newStatus });
            setSelectedOrder(prev => ({ ...prev, status: newStatus }));
            if (refresh) refresh();
        } catch (e) {
            alert("Failed to update status: " + e.message);
        }
        setStatusUpdating(false);
    };

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-gray-800 dark:text-gray-100">Orders</h1>

            <MasterTable
                title="Recent Orders"
                data={data}
                loading={loading}
                columns={columns}
                onAdd={null}
                onEdit={(item) => viewOrder(item)}
                onDelete={() => { }}
                pagination={pagination}
            />

            {/* Order Detail Modal */}
            {selectedOrder && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white dark:bg-gray-800 rounded-lg max-w-3xl w-full shadow-xl overflow-hidden">
                        <div className="flex justify-between items-center px-6 py-4 bg-[#2E5A5A] dark:bg-teal-900 text-white">
                            <h2 className="text-lg font-bold">Order: {selectedOrder.slug}</h2>
                            <button onClick={() => setSelectedOrder(null)} className="text-white hover:text-gray-200">
                                <X size={20} />
                            </button>
                        </div>

                        <div className="p-6 space-y-6 max-h-[70vh] overflow-y-auto">
                            {/* Order Info Grid */}
                            <div className="grid grid-cols-2 gap-4 text-sm">
                                <div>
                                    <p className="text-gray-500 dark:text-gray-400">Customer</p>
                                    <p className="font-medium dark:text-gray-100">{selectedOrder.billingName}</p>
                                </div>
                                <div>
                                    <p className="text-gray-500 dark:text-gray-400">Phone</p>
                                    <p className="font-medium dark:text-gray-100">{selectedOrder.billingPhone || '—'}</p>
                                </div>
                                <div>
                                    <p className="text-gray-500 dark:text-gray-400">Total</p>
                                    <p className="font-medium text-lg dark:text-gray-100">₹{selectedOrder.finalTotal}</p>
                                </div>
                                <div>
                                    <p className="text-gray-500 dark:text-gray-400">Payment</p>
                                    <p className="font-medium dark:text-gray-100">{selectedOrder.paymentMethod} - {selectedOrder.paymentStatus}</p>
                                </div>
                                <div className="col-span-2">
                                    <p className="text-gray-500 dark:text-gray-400">Shipping Address</p>
                                    <p className="font-medium dark:text-gray-100">
                                        {selectedOrder.shippingAddress1}
                                        {selectedOrder.shippingCity && `, ${selectedOrder.shippingCity}`}
                                        {selectedOrder.shippingState && `, ${selectedOrder.shippingState}`}
                                        {selectedOrder.shippingZip && ` - ${selectedOrder.shippingZip}`}
                                    </p>
                                </div>
                            </div>

                            {/* Status Update */}
                            <div className="border-t border-gray-200 dark:border-gray-700 pt-4">
                                <label className="block text-sm text-gray-500 dark:text-gray-400 mb-2">Update Status</label>
                                <div className="flex flex-wrap gap-2">
                                    {ORDER_STATUSES.map(s => (
                                        <button
                                            key={s.value}
                                            disabled={statusUpdating || selectedOrder.status === s.value}
                                            onClick={() => updateStatus(selectedOrder.id, s.value)}
                                            className={`px-3 py-1.5 rounded-full text-xs font-semibold border transition-all
                                                ${selectedOrder.status === s.value
                                                    ? `${s.color} border-current ring-2 ring-offset-1 ring-current`
                                                    : 'border-gray-300 dark:border-gray-600 text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700'
                                                }`}
                                        >
                                            {selectedOrder.status === s.value && <CheckCircle size={12} className="inline mr-1" />}
                                            {s.label}
                                        </button>
                                    ))}
                                </div>
                            </div>

                            {/* Order Items Table */}
                            {orderItems.length > 0 && (
                                <div className="border-t border-gray-200 dark:border-gray-700 pt-4">
                                    <h3 className="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3">Order Items</h3>
                                    <table className="w-full text-sm">
                                        <thead>
                                            <tr className="border-b dark:border-gray-700 text-left text-gray-500 dark:text-gray-400">
                                                <th className="pb-2">Item</th>
                                                <th className="pb-2">SKU</th>
                                                <th className="pb-2 text-right">Qty</th>
                                                <th className="pb-2 text-right">Price</th>
                                                <th className="pb-2 text-right">Subtotal</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            {orderItems.map((item, i) => (
                                                <tr key={i} className="border-b dark:border-gray-700">
                                                    <td className="py-2 dark:text-gray-200">{item.title}</td>
                                                    <td className="py-2 text-gray-500 dark:text-gray-400">{item.sku || '—'}</td>
                                                    <td className="py-2 text-right dark:text-gray-200">{item.quantity}</td>
                                                    <td className="py-2 text-right dark:text-gray-200">₹{item.price}</td>
                                                    <td className="py-2 text-right font-medium dark:text-gray-200">₹{item.subtotal}</td>
                                                </tr>
                                            ))}
                                        </tbody>
                                    </table>
                                </div>
                            )}
                        </div>

                        <div className="px-6 py-4 border-t dark:border-gray-700 flex justify-end">
                            <button
                                className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600"
                                onClick={() => setSelectedOrder(null)}
                            >
                                Close
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Orders;
