import React, { useState } from "react";
import Header from "./components/Layout/Header";
import Meals from "./components/Meals/Meals";
import Cart from "./components/Cart/Cart";
import CartContextProvider from "./store/CartContextProvider";
function App() {
  // we manage the "onClose" in our parents component
  const [cartShow, setCart] = useState(false);
  const hideCart = () => {
    setCart(false);
  };
  const showCart = () => {
    setCart(true);
  };
  return (
    <CartContextProvider>
      {/* we will need to access to all the component so we wrap in App.js */}
      {cartShow && <Cart onCloseCart={hideCart} />}
      {/* when the Your Cart click you should call the cart */}
      {/* <Header onShowCart={showCart} /> */}
      <main>
        <Meals />
      </main>
    </CartContextProvider>
  );
}

export default App;
