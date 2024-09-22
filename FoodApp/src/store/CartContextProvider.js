import React from "react";
import { useReducer } from "react";
import CartContext from "./CartContext";

const defaultCart = {
  item: [],
  totalAmount: 0,
  //this defaultcart is 'DUMMY' and 'cartState' is Dynamic
};
const cartReducer = (preState, action) => {
  // we dont directly use the 'preState'
  // because you wanna make you state 'immutable'

  if (action.type === "ADD") {
    const updatedTotalAmount =
      preState.totalAmount + action.item.price * action.item.amount;
    //we want to add 'item' when the item repeat
    const existItemIndex = preState.item.findIndex(
      (i) => i.id === action.item.id
      //this is check the cur and the new one is the same or not
    );
    const existItem = preState.item[existItemIndex]; //if no item will be 'null'
    let updatedItems;
    if (existItem) {
      const updateExistItem = {
        ...existItem,
        amount: existItem.amount + action.item.amount,
        //we update amount here because we wanna accumulate amount together
      };
      updatedItems = [...preState.item]; //shallow copy for 'immutable'
      //here we dont dispatch 'action' item because we 'only' update the amount
      updatedItems[existItemIndex] = updateExistItem;
      // here we overwrite the same Item
    } else {
      updatedItems = preState.item.concat(action.item);
    }

    return {
      item: updatedItems,
      totalAmount: updatedTotalAmount,
    };
  }
  if (action.type === "REMOVE") {
    const existItemIndex = preState.item.findIndex(
      (i) => i.id === action.id
      //no item but just 'id' because in removeItem we just dispatch id
    );
    const existItem = preState.item[existItemIndex];
    const updatedRmoveAmount = preState.totalAmount - existItem.price;
    let updatedItems;
    if (existItem.amount === 1) {
      updatedItems = preState.item.filter((i) => i.id !== action.id);
      //false is removing arr true is keeping arr
    } else {
      const updateItem = { ...existItem, amount: existItem.amount - 1 }; //this is 'obj' create by 'action'
      updatedItems = [...preState.item]; //this just for immutable
      updatedItems[existItemIndex] = updateItem; //Re-write the 'obj' we find
    }
    return {
      item: updatedItems,
      totalAmount: updatedRmoveAmount,
    };
  }
  if (action.type === "SUBMIT") {
    return defaultCart;
  }
  return defaultCart;
};
const CartContextProvider = (props) => {
  const [cartState, dispatchCart] = useReducer(cartReducer, defaultCart);
  //we can also add the concrete value here
  const addItemToCart = (item) => {
    dispatchCart({ type: "ADD", item: item });
  };
  //The App component will re-evaluate whenever the context change
  const removeItemFromCart = (id) => {
    dispatchCart({ type: "REMOVE", id: id });
  };
  const submitItem = (item) => {
    dispatchCart({ type: "SUBMIT" });
  };
  const CartValue = {
    item: cartState.item,
    totalAmount: cartState.totalAmount,
    addItem: addItemToCart,
    removeItem: removeItemFromCart,
    submitItem: submitItem,
  };
  return (
    <CartContext.Provider value={CartValue}>
      {props.children}
    </CartContext.Provider>
  );
  // now the stuff wrap by this component will get access to here to fetch data
};
export default CartContextProvider;
