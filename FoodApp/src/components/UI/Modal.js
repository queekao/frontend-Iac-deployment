import React from "react";
import ReactDom from "react-dom";
import classes from "./Modal.module.css";
const Backdrop = (props) => {
  return <div onClick={props.onClick} className={classes.backdrop}></div>;
  //if we "useContext" this backdrop will be specific and not able  to use in another content
};
const ModalOverlay = (props) => {
  return (
    <div onClick={props.onCloseCart} className={classes.modal}>
      {props.children}
    </div>
  );
};
const Modal = (props) => {
  const portalEl = document.querySelector("#Modal");
  return (
    // <React.Fragment>
    //   {ReactDom.createPortal(
    //     <div className={classes.backdrop}></div>,
    //     document.getElementById("Modal")
    //   )}
    //   {ReactDom.createPortal(
    //     <Cart className={classes.modal}></Cart>,
    //     document.getElementById("Modal")
    //   )}
    // </React.Fragment>
    //we can create a lot of components in one component
    <React.Fragment>
      {/* In mutiple component we also need to set on its own component */}
      {ReactDom.createPortal(
        <Backdrop onClick={props.onCloseCart} />,
        portalEl
      )}
      ;
      {ReactDom.createPortal(
        <ModalOverlay>{props.children}</ModalOverlay>,
        portalEl
      )}
    </React.Fragment>
  );
};
export default Modal;
