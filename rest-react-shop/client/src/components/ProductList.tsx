import React, { useState, useEffect } from 'react'
import { Product } from '../model/Product';
import SingleProduct from './SingleProduct';
import ProductController from '../api/ProductController';


interface Props {
    category: string;
    // products: Product[];
    // setProducts: React.Dispatch<React.SetStateAction<Product[]>>
}

const ProductList = ({ category }: Props) => {
  const [products, setProducts] = useState<Product[]>([])
  const [productToCart, setProductToCart] = useState<Product>()

  useEffect(() => {
    ProductController.getAllProducts(category)
      .then((response) => {
        if(response.status === 200){
          setProducts(response.data.data);
        }
      })
      .catch((error) => {
        console.log(error);
      })
  }, [])


  return (
    <div className='d-flex flex-column align-content-center flex-grow-1 flex-wrap m-5 mh-100'>
        <div className='mt-4'><h3>Product List</h3></div>
        <div>
            {products.map(product => (
                <SingleProduct product={product} key={product.id} products={products} setProducts={setProducts} />
            ))}
        </div>
    </div>

  )
}

export default ProductList