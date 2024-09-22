import React, { useContext, useEffect, useState } from "react";
import classes from "./HeaderCartButton.module.css";
import CartIcon from "../Cart/CartIcon";
import CartContext from "../../store/CartContext";

const HeaderCartButton = (props) => {
  const cartData = useContext(CartContext);
  const itemValue = cartData.item.reduce((acc, cur) => acc + cur.amount, 0);
  // My solution
  // let btnClasses = `${classes.button} ${classes.bump}`;
  // useEffect(() => {
  //   const btn = document.querySelector(`.${classes.button}`);
  //   if (btn.classList.contains(`${classes.bump}`)) {
  //     btn.classList.remove(`${classes.bump}`);
  //   } else {
  //     btn.classList.add(`${classes.bump}`);
  //   }
  //   console.log("add");
  //   return () => {
  //     setTimeout(() => {
  //       document
  //         .querySelector(`.${classes.button}`)
  //         .classList.remove(`${classes.bump}`);
  //       console.log("remove");
  //     }, 1000);
  //   };
  // }, [itemValue]);
  //Teacher solution
  const [btnClick, setBtnClick] = useState(false);
  const btnClasses = `${classes.button} ${btnClick ? classes.bump : ""}`;
  const { item } = cartData; //teacher use 'alias' here
  useEffect(() => {
    if (item.length === 0) return;
    setBtnClick(true);
    const timer = setTimeout(() => {
      setBtnClick(false);
    }, 300);
    return () => {
      clearTimeout(timer); //wherever the effect rerun we clear Timer
      //if we wanna set new timer better to clear out
    };
  }, [item]);
  return (
    <button onClick={props.onClick} className={btnClasses}>
      <span>
        <CartIcon className={classes.icon} />
      </span>
      <span className={classes.text}>Your Cart</span>
      <span className={classes.badge}>{itemValue}</span>
      {/* the above one span is for '+' number*/}
    </button>
  );
};
export default HeaderCartButton;
