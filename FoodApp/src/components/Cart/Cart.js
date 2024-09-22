import React, { useContext, useState } from "react";
import Button from "../UI/Button";
import classes from "./Cart.module.css";
import Modal from "../UI/Modal";
import CartContext from "../../store/CartContext";
import Checkout from "./Checkout";
const Cart = (props) => {
  //Now we use update the Item in Modal here
  const cartData = useContext(CartContext);
  const [showCheckout, setShowCheckout] = useState(false);
  const [isSubmit, setIsSubmit] = useState(false); //loading
  const [didSubmit, setDidSubmit] = useState(false); //success msg
  const [error, setError] = useState(null);
  const cartTotalAmount = `$${cartData.totalAmount.toFixed(2)}`;
  const hasItem = cartData.item.length > 0;
  const removeItemHandler = (id) => {
    cartData.removeItem(id);
  };
  const addItemHandler = (item) => {
    cartData.addItem({
      ...item, //we use seperate operate to move other data and amount plus one
      amount: 1,
    }); //the item should be obj
  };
  const submitData = async (userData) => {
    try {
      setIsSubmit(true);
      //receive data from the checkout component
      const response = await fetch(
        "https://food-app-5f4d3-default-rtdb.firebaseio.com/order.json",
        {
          //specify a new node of 'order'
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ user: userData, orderItem: cartData.item }),
        }
      ); //with only pass the data to the backend server we dont even need resolve method
      if (!response.ok) throw new Error("Fail to submit");
      setIsSubmit(false);
      setDidSubmit(true);
      cartData.submitItem();
    } catch (err) {
      setError(err.message);
    }
  };
  // map cartItems
  const cartItems = cartData.item.map((item) => (
    <li
      className={classes["cart-item"]}
      key={item.id}
      id={item.id}
      name={item.name}
      amount={item.amount}
      price={item.price}
    >
      <div>
        <h2>{item.name}</h2>
        <div className={classes.summary}>
          <span className={classes.price}>💲{item.price}</span>
          <span className={classes.amount}>ⅹ {item.amount}</span>
        </div>
      </div>
      <div className={classes.btnGroup}>
        <Button
          className={classes.btnRemove}
          onClick={removeItemHandler.bind(cartData, item.id)}
        >
          ⎻
        </Button>
        <Button
          className={classes.btnAdd}
          onClick={addItemHandler.bind(cartData, item)}
        >
          +
        </Button>
        {/* in order to make btn work we need bind original 
        obj and re-configure the function */}
      </div>
    </li>
  ));
  // map cartItems
  const orderHandler = () => {
    setShowCheckout(true);
  };
  // Close Cofirm
  const closeCheckout = () => {
    setShowCheckout(false);
  };
  const modalActions = (
    <div className={classes.actions}>
      <Button onClick={props.onCloseCart} className={classes["button--alt"]}>
        Close
      </Button>
      {hasItem && (
        <Button onClick={orderHandler} className={classes.button}>
          Order
        </Button>
      )}
    </div>
  );
  const submitSuccessContent = <p>You are successfully submit the content😀</p>;
  const isSubmitContent = <p>Sending order data...</p>;
  const modalContent = (
    <React.Fragment>
      <ul className={classes["cart-items"]}>{cartItems}</ul>
      <div className={classes.total}>
        <span>Total Amount</span>
        <span>{cartTotalAmount}</span>
      </div>
      {showCheckout ? (
        <Checkout onSubmit={submitData} onCancel={props.onCloseCart} />
      ) : (
        modalActions
      )}
    </React.Fragment>
  );
  return (
    <Modal onCloseCart={props.onCloseCart} className={props.className}>
      {!isSubmit && !didSubmit && modalContent}
      {isSubmit && isSubmitContent}
      {!isSubmit && didSubmit && submitSuccessContent}
    </Modal>
  );
};
export default Cart;
