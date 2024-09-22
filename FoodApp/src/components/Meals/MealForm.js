import { useRef, useState } from "react";
import ButtonIcon from "../Cart/ButtonIcon";
import Button from "../UI/Button";
import Input from "../UI/Input";
import classes from "./MealForm.module.css";

const MealForm = (props) => {
  const inputAmountRef = useRef();
  const [invalid] = useState(false);
  const mealHandler = (e) => {
    e.preventDefault();
    const enterNumber = inputAmountRef.current.value;
    //we set enterNumber in the 'mealHandler' to deal with the value
    if (
      enterNumber.trim().length === 0 ||
      +enterNumber < 1 ||
      +enterNumber > 5
    ) {
      //validation for invalid value
      return;
    }
    //here we want to get our context but not in use component
    props.onAddToCart(+enterNumber);
  };
  const inputAttribute = {
    // and go to the component that receive 'ref' and use 'forwardRef'
    id: "amount_" + props.id,
    // make every 'id' unique
    type: "number",
    min: "1",
    max: "5",
    step: "1",
    defaultValue: "1",
    key: Math.random().toFixed(2),
    // this 'defaultValue' is for the input which is populated first time
  };
  return (
    <form onSubmit={mealHandler}>
      <Input ref={inputAmountRef} label="Amount" input={inputAttribute} />
      <Button className={classes.button}>
        <ButtonIcon className={classes.buttonIcon} />
        Add
      </Button>
      {invalid && <p>Please enter number between 1 to 5</p>}
    </form>
  );
};
export default MealForm;
