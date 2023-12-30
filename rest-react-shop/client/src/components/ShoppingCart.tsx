import { Offcanvas, Stack } from "react-bootstrap"
import { useShoppingCart } from "../context/ShoppingCartContext"
import CartItem from "./CartItem"
import { Product } from '../model/Product';

type ShoppingCartProps = {
  isOpen: boolean
}

const ShoppingCart: React.FC = () => {

  const { closeCart, cartItems } = useShoppingCart()
  return (
    <Offcanvas show={true} onHide={closeCart} placement="end">
      <Offcanvas.Header closeButton>
        <Offcanvas.Title>Cart</Offcanvas.Title>
      </Offcanvas.Header>
      <Offcanvas.Body>
        <Stack gap={3}>
          {cartItems.map(item => (
            <CartItem product={item} key={item.id}  />
          ))}
          <div className="ms-auto fw-bold fs-5">
            Total{" cash"}
            {/* {
              cartItems.reduce((total, cartItem) => {
                const item = storeItems.find(i => i.id === cartItem.id)
                return total + (item?.price || 0) * cartItem.quantity
              }, 0)
            } */}
          </div>
        </Stack>
      </Offcanvas.Body>
    </Offcanvas>
  )
}

export default ShoppingCart