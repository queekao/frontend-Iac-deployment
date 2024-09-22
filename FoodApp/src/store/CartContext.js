import React from "react";
//Store the dummy data store folder is for the data storage
const CartContext = React.createContext({
  item: [],
  totalAmount: 0,
  removeItem(id) {},
  addItem(item) {},
  // ID is looking for the item to remove
});

export default CartContext;
