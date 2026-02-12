import { Home, Package, Users, Settings, LogOut, FileText, Image, Star, Truck, ShoppingBag } from 'lucide-react';
import { Link, useLocation } from 'react-router-dom';
import clsx from 'clsx';

import logo from '../assets/logo.jpg';

const Sidebar = () => {
    const location = useLocation();

    const navItems = [
        { label: 'Dashboard', icon: Home, path: '/' },
        { label: 'Products', icon: Package, path: '/products' },
        { label: 'Orders', icon: ShoppingBag, path: '/orders' },
        { label: 'Banners', icon: Image, path: '/banners' },
        { label: 'Featured Sections', icon: Star, path: '/featured-sections' },
        { label: 'Master Data', icon: FileText, path: '/masters' },
        { label: 'Logistics', icon: Truck, path: '/logistics' },
        { label: 'Users', icon: Users, path: '/users' },
        { label: 'Settings', icon: Settings, path: '/settings' },
    ];

    return (
        <div className="w-64 bg-gray-900 dark:bg-gray-950 text-white min-h-screen flex flex-col transition-colors duration-200">
            <div className="p-6 border-b border-gray-800 dark:border-gray-900 flex justify-center">
                <img src={logo} alt="MedTrue Logo" className="h-12 w-auto object-contain" />
            </div>

            <nav className="flex-1 p-4 space-y-2">
                {navItems.map((item) => {
                    const isActive = location.pathname === item.path;
                    return (
                        <Link
                            key={item.path}
                            to={item.path}
                            className={clsx(
                                "flex items-center gap-3 px-4 py-3 rounded-lg transition-colors",
                                isActive
                                    ? "bg-teal-600 text-white shadow-md"
                                    : "text-gray-400 hover:bg-gray-800 dark:hover:bg-gray-900 hover:text-white"
                            )}
                        >
                            <item.icon size={20} />
                            <span className="font-medium">{item.label}</span>
                        </Link>
                    );
                })}
            </nav>

            <div className="p-4 border-t border-gray-800 dark:border-gray-900">
                <button className="flex items-center gap-3 px-4 py-3 w-full text-left text-gray-400 hover:text-red-400 hover:bg-gray-800 dark:hover:bg-gray-900 rounded-lg transition-colors">
                    <LogOut size={20} />
                    <span className="font-medium">Logout</span>
                </button>
            </div>
        </div>
    );
};

export default Sidebar;
