import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

const data = [
    { name: 'Jan', Sales: 4000, Profit: 2400 },
    { name: 'Feb', Sales: 3000, Profit: 1398 },
    { name: 'Mar', Sales: 2000, Profit: 9800 },
    { name: 'Apr', Sales: 2780, Profit: 3908 },
    { name: 'May', Sales: 1890, Profit: 4800 },
    { name: 'Jun', Sales: 2390, Profit: 3800 },
];

const Dashboard = () => {
    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-gray-800 dark:text-gray-100">Dashboard</h1>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                {['Total Sales', 'Total Orders', 'Total Products', 'New Customers'].map((item) => (
                    <div key={item} className="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 transition-colors">
                        <h3 className="text-gray-500 dark:text-gray-400 text-sm font-medium">{item}</h3>
                        <p className="text-2xl font-bold text-gray-800 dark:text-gray-100 mt-2">1,234</p>
                        <span className="text-green-500 text-xs font-semibold">+12.5% from last month</span>
                    </div>
                ))}
            </div>

            {/* Chart */}
            <div className="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 h-96 transition-colors">
                <h3 className="text-lg font-bold text-gray-800 dark:text-gray-100 mb-4">Sales Overview</h3>
                <ResponsiveContainer width="100%" height="100%">
                    <BarChart data={data}>
                        <CartesianGrid strokeDasharray="3 3" vertical={false} />
                        <XAxis dataKey="name" />
                        <YAxis />
                        <Tooltip />
                        <Legend />
                        <Bar dataKey="Sales" fill="#2dd4bf" radius={[4, 4, 0, 0]} />
                        <Bar dataKey="Profit" fill="#3b82f6" radius={[4, 4, 0, 0]} />
                    </BarChart>
                </ResponsiveContainer>
            </div>
        </div>
    );
};

export default Dashboard;
