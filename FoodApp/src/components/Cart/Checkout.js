import { useState, useRef } from "react";
import Button from "../UI/Button";
import classes from "./Checkout.module.css";
// const defaultState = { value: "", state: false };
// const inputReducer = () => {
//   return defaultState;
// };
//helper
const isEmpty = (value) => value.trim() === "";
const isFiveCharaters = (value) => value.trim().length === 5;
//
const Checkout = (props) => {
  const [formValid, setFormValid] = useState({
    name: true,
    postal: true,
    street: true,
    city: true,
  });
  //   const [inputState, dispatchInput] = useReducer(inputReducer, defaultState);
  const nameRef = useRef();
  const postalRef = useRef();
  const streetRef = useRef();
  const cityRef = useRef();
  const submitForm = (e) => {
    e.preventDefault();
    const nameValue = nameRef.current.value;
    const postalValue = postalRef.current.value;
    const streetValue = streetRef.current.value;
    const cityValue = cityRef.current.value;
    const nameValid = !isEmpty(nameValue);
    const postalValid = isFiveCharaters(postalValue);
    const streetValid = !isEmpty(streetValue);
    const cityValid = !isEmpty(cityValue);
    setFormValid({
      name: nameValid,
      postal: postalValid,
      street: streetValid,
      city: cityValid,
    });
    //you cant just 'setFormValid' here form will be only invalid
    //after the component re-evaluate and before that we already submit the form
    const formIsValid = nameValid && postalValid && streetValid && cityValid;
    console.log(nameValid, postalValid, streetValid, cityValid);
    console.log(formValid);
    //   if (!formValid) {
    //       return;//first time render is 'true
    // }
    if (!formIsValid) {
      return;
    }
    if (formValid) {
      props.onSubmit({
        name: nameValue,
        postal: postalValue,
        street: streetValue,
        city: cityValue,
      });
      nameRef.current.value = "";
      postalRef.current.value = "";
      streetRef.current.value = "";
      cityRef.current.value = "";
    }
  };
  return (
    <form className={classes.form} onSubmit={submitForm}>
      <div
        className={`${classes.control} ${!formValid.name && classes.invalid}`}
      >
        <label htmlFor="name">Name</label>
        <input id="name" type="text" ref={nameRef}></input>
        {!formValid.name && (
          <p className={classes.error}>Name Value invalid!!</p>
        )}
      </div>
      <div
        className={`${classes.control} ${!formValid.postal && classes.invalid}`}
      >
        <label htmlFor="postal">Postal Code</label>
        <input id="postal" type="text" ref={postalRef}></input>
        {!formValid.postal && (
          <p className={classes.error}>Postal Value must greater than 5!!</p>
        )}
      </div>
      <div
        className={`${classes.control} ${!formValid.street && classes.invalid}`}
      >
        <label htmlFor="street">Street</label>
        <input id="street" type="text" ref={streetRef}></input>
        {!formValid.street && (
          <p className={classes.error}>Street Value invalid!!</p>
        )}
      </div>
      <div
        className={`${classes.control} ${!formValid.city && classes.invalid}`}
      >
        <label htmlFor="city">City</label>
        <input id="city" type="text" ref={cityRef}></input>
        {!formValid.city && (
          <p className={classes.error}>City Value invalid!!</p>
        )}
      </div>
      <div className={classes.actions}>
        <Button
          type="button"
          className={classes.cancel}
          onClick={props.onCancel}
        >
          Cancel
        </Button>
        <Button type="submit" className={classes.confirm}>
          Confirm
        </Button>
      </div>
    </form>
  );
};
export default Checkout;
