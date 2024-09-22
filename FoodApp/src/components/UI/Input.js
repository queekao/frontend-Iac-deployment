import { forwardRef } from "react";
import classes from "./Input.module.css";
const Input = forwardRef((props, ref) => {
  // child pass ref to parent
  return (
    <div className={`${props.className} ${classes.input}`}>
      <input ref={ref} {...props.input}></input>
      <label htmlFor={props.input.id}>{props.label}</label>
    </div>
  ); //here we use an 'obj' outside of component the set our attribute
}); //and we can use seperate operator to set the input attribute
export default Input;
