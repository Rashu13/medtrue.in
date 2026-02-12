import { Edit, Trash2, Plus, ChevronLeft, ChevronRight } from 'lucide-react';
import { useState } from 'react';
import { IMAGE_BASE_URL } from '../services/api';

const MasterTable = ({
    title,
    data,
    columns,
    onAdd,
    onEdit,
    onDelete,
    loading,
    pagination
}) => {
    return (
        <div className="border border-gray-200 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 transition-colors duration-200">
            {/* Header */}
            <div className="flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-700">
                <h2 className="text-lg font-semibold text-gray-800 dark:text-gray-100">{title}</h2>
                <button
                    onClick={onAdd}
                    className="flex items-center gap-2 bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-md transition-colors text-sm font-medium"
                >
                    <Plus size={16} />
                    Add New
                </button>
            </div>

            {/* Table */}
            <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="bg-gray-50 dark:bg-gray-700 border-b border-gray-200 dark:border-gray-700">
                            {columns.map((col, idx) => (
                                <th key={idx} className="px-6 py-3 text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    {col.label}
                                </th>
                            ))}
                            <th className="px-6 py-3 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">
                                Actions
                            </th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
                        {loading ? (
                            <tr>
                                <td colSpan={columns.length + 1} className="px-6 py-8 text-center text-gray-500 dark:text-gray-400">
                                    Loading...
                                </td>
                            </tr>
                        ) : data.length === 0 ? (
                            <tr>
                                <td colSpan={columns.length + 1} className="px-6 py-8 text-center text-gray-500 dark:text-gray-400">
                                    No records found
                                </td>
                            </tr>
                        ) : (
                            data.map((item, idx) => (
                                <tr key={idx} className="hover:bg-gray-50/50 dark:hover:bg-gray-700/50 transition-colors">
                                    {columns.map((col, cIdx) => (
                                        <td key={cIdx} className="px-6 py-4 text-sm text-gray-700 dark:text-gray-300">
                                            {col.type === 'image' && item[col.key] ? (
                                                <img
                                                    src={item[col.key].startsWith('http') ? item[col.key] : `${IMAGE_BASE_URL}${item[col.key]}`}
                                                    alt="img"
                                                    className="h-10 w-10 object-cover border rounded"
                                                />
                                            ) : (
                                                item[col.key]
                                            )}
                                        </td>
                                    ))}
                                    <td className="px-6 py-4 text-right space-x-2">
                                        <button
                                            onClick={() => onEdit(item)}
                                            className="text-blue-600 hover:text-blue-800 p-1 rounded hover:bg-blue-50 transition-colors"
                                        >
                                            <Edit size={16} />
                                        </button>
                                        <button
                                            onClick={() => onDelete(item)}
                                            className="text-red-600 hover:text-red-800 p-1 rounded hover:bg-red-50 transition-colors"
                                        >
                                            <Trash2 size={16} />
                                        </button>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>

            {/* Pagination Controls */}
            {pagination && (
                <div className="flex items-center justify-between p-4 border-t border-gray-200 dark:border-gray-700">
                    <div className="text-sm text-gray-500 dark:text-gray-400">
                        Showing {((pagination.page - 1) * pagination.pageSize) + 1} to {Math.min(pagination.page * pagination.pageSize, pagination.total)} of {pagination.total} results
                    </div>
                    <div className="flex items-center gap-4">
                        <select
                            value={pagination.pageSize}
                            onChange={(e) => {
                                pagination.setPageSize(Number(e.target.value));
                                pagination.setPage(1); // Reset to first page
                            }}
                            className="p-2 border border-gray-300 dark:border-gray-600 rounded-md text-sm focus:outline-none focus:ring-1 focus:ring-teal-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                        >
                            <option value={10}>10 per page</option>
                            <option value={20}>20 per page</option>
                            <option value={50}>50 per page</option>
                            <option value={100}>100 per page</option>
                        </select>
                        <div className="flex items-center gap-2">
                            <button
                                onClick={() => pagination.setPage(p => Math.max(1, p - 1))}
                                disabled={pagination.page === 1}
                                className="p-2 border border-gray-300 dark:border-gray-600 rounded-md hover:bg-gray-50 dark:hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed text-gray-600 dark:text-gray-300"
                            >
                                <ChevronLeft size={16} />
                            </button>
                            <span className="text-sm font-medium text-gray-700">
                                Page {pagination.page}
                            </span>
                            <button
                                onClick={() => pagination.setPage(p => p + 1)}
                                disabled={pagination.page * pagination.pageSize >= pagination.total}
                                className="p-2 border border-gray-300 dark:border-gray-600 rounded-md hover:bg-gray-50 dark:hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed text-gray-600 dark:text-gray-300"
                            >
                                <ChevronRight size={16} />
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default MasterTable;
