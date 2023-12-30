import React, { useState } from 'react'
import { Product } from '../model/Product';
import { BiDrink } from 'react-icons/bi'
import { TbShoppingCartPlus } from 'react-icons/tb'
import { MdAttachMoney, MdFastfood } from 'react-icons/md'

interface Props {
    product: Product;
}

const CartItem: React.FC<Props> = ({product}: Props) => {

  const [productToCart, setProductToCart] = useState()

  // const handleAddToCart = (e) => {
  //     e.preventDefault()

  // }


  return (
    <form className={"d-flex justify-content-between p-3 mb-2 bg-secondary text-white rounded"}>
        {product.category==='drink' &&
          <span className='fs-2'><BiDrink /></span>
        }
        {!(product.category==='drink') &&
          <span className='fs-2'><MdFastfood /></span>
        }
        <span>{product.name}</span>
        <span><MdAttachMoney /></span>
        <span>{product.price}</span>
        <button type="button" className="btn btn-success"><TbShoppingCartPlus /></button>
    </form>
  )
}

export default CartItem