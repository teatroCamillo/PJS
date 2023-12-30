import React, { useState, useEffect } from 'react';
import './App.css';
import ProductList from './components/ProductList';
import Cart from './components/ShoppingCart';
import { Routes, Route } from 'react-router-dom'
import Menu from './components/Menu'

const App: React.FC = () => {

  return (
    <div className={"d-flex flex-column text-bg-dark h-100"}>
      <Menu />
      <Routes>
        <Route path='/' element={<ProductList category="/" />} />
        <Route path='/drink' element={<ProductList category="/drink" />} />
        <Route path='/food' element={<ProductList category="/food"  />} />
        <Route path='/cart' element={<Cart />} />
      </Routes>
    </div>
  );
}

export default App;
