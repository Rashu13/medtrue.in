import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider } from './context/ThemeContext';
import MainLayout from './layout/MainLayout';
import Dashboard from './pages/Dashboard';
import Products from './pages/Products';
import AddProduct from './pages/AddProduct';
import Masters from './pages/Masters';
import Banners from './pages/Banners';
import FeaturedSections from './pages/FeaturedSections';
import Logistics from './pages/Logistics';
import Orders from './pages/Orders';
import Users from './pages/Users';


function App() {
    return (
        <ThemeProvider>
            <BrowserRouter>
                <Routes>
                    <Route path="/" element={<MainLayout />}>
                        <Route index element={<Dashboard />} />
                        <Route path="products" element={<Products />} />
                        <Route path="products/add" element={<AddProduct />} />
                        <Route path="products/edit/:id" element={<AddProduct />} />
                        <Route path="masters" element={<Masters />} />
                        <Route path="banners" element={<Banners />} />
                        <Route path="featured-sections" element={<FeaturedSections />} />
                        <Route path="logistics" element={<Logistics />} />
                        <Route path="orders" element={<Orders />} />
                        <Route path="users" element={<Users />} />
                        {/* Add more routes here */}
                    </Route>
                </Routes>
            </BrowserRouter>
        </ThemeProvider>
    );
}

export default App;
