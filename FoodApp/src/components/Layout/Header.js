import React from "react";
import classes from "./Header.module.css";
import mealImage from "../../assets/meals.jpg";
import HeaderCartButton from "./HeaderCartButton";
//IF we wanna use image we need to import it
// which transformed to include image to application to deploy the server
const Header = (props) => {
  return (
    <React.Fragment>
      <header className={classes.header}>
        <h1>ReactMeals</h1>
        <HeaderCartButton onClick={props.onShowCart} />
      </header>
      <div className={classes["main-image"]}>
        <img src={mealImage} alt="Just a img"></img>
      </div>
    </React.Fragment>
  );
  //we also can just add URL to the src
  // we can choose return one or two component
};
export default Header;
