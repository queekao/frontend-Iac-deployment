import {useContext, useEffect, useState} from "react";
import {useLottie} from "lottie-react";
import animation from "../../assets/lotties/lf30_editor_zugvminb.json";
//we useContext here to update data
import classes from "./AvailableMeals.module.css";
import Card from "../UI/Card";
import MealForm from "./MealForm";
import React from "react";
import CartContext from "../../store/CartContext";
//render the meal list
const AvailableMeals = (props) => {
  //
  const options = {
    animationData: animation,
    loop: false,
    autoplay: true,
  };
  const {View} = useLottie(options);
  const cartData = useContext(CartContext);
  const [meals, setMeals] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  //Meals originally was empty so we nedd to use setMeal in order to load meal
  useEffect(() => {
    //useEffect cant use async fn because it will return clean up fn not
    setIsLoading(true);
    setError(null);
    const fetchMeal = async () => {
      try {
        const response = await fetch(
          "https://food-app-5f4d3-default-rtdb.firebaseio.com/meals.json"
        );
        console.log(response);
        if (!response.ok) throw new Error("Cannot read the data");
        const data = await response.json();
        const loadedMeals = [];
        console.log(loadedMeals);
        for (const key in data) {
          loadedMeals.push({
            id: key,
            name: data[key].name,
            description: data[key].description,
            price: data[key].price,
          });
        }
        setMeals(loadedMeals);
        setIsLoading(false);
      } catch (err) {
        setIsLoading(false);
        throw new Error(err);
      }
    };
    fetchMeal().catch((err) => {
      setError(err.message);
      setIsLoading(false);
    }); //return promise
    //if we try to catch a error of a promise then promise will be rejected
    // If you specify here anything went wrong in 'fetchMeal' will be shown
  }, []);
  console.log(meals);
  if (isLoading) {
    return <p className={classes.mealLoading}>Loading...</p>;
  }
  if (!isLoading && error) {
    return (
      <section>
        <p className={classes.error}>{error}</p>
      </section>
    );
  }
  const mealList = meals.map((meal) => {
    const addToCart = (amount) => {
      console.log(amount);
      cartData.addItem({
        id: meal.id,
        key: meal.id,
        name: meal.name,
        price: meal.price,
        amount: amount,
      });
    };
    return (
      <div key={meal.id} className={classes.wrapper}>
        {/* this is from the form unique id */}
        <li id={meal.id} key={meal.id}>
          <h3>{meal.name}</h3>
          <p>{meal.description}</p>
          <span>${meal.price}</span>
        </li>
        <MealForm
          onAddToCart={addToCart}
          // be called when we submit the form
          className={classes.mealForm}
        ></MealForm>
      </div>
    );
  });
  // const mealList = DUMMY_MEALS.map((meal) => {
  //   const addToCart = (amount) => {
  //     console.log(amount);
  //     cartData.addItem({
  //       id: meal.id,
  //       key: meal.id,
  //       name: meal.name,
  //       price: meal.price,
  //       amount: amount,
  //     });
  //     //we pass an obj in the 'addItem' because we forward this obj to reducer
  //   };
  //   return (
  //     <div key={meal.id} className={classes.wrapper}>
  //       {/* this is from the form unique id */}
  //       <li id={meal.id} key={meal.id}>
  //         <h3>{meal.name}</h3>
  //         <p>{meal.description}</p>
  //         <span>${meal.price}</span>
  //       </li>
  //       <MealForm
  //         onAddToCart={addToCart}
  //         // be called when we submit the form
  //         className={classes.mealForm}
  //       ></MealForm>
  //     </div>
  //   );
  // });
  //Immutable element to do this we copy them 👆

  return (
    <React.Fragment>
      <section className={classes.meals}>
        <Card>
          <ul>{mealList}</ul>
          {/* you need to set the state before you render the mealList */}
        </Card>
      </section>
      <div>{View}</div>
    </React.Fragment>
  ); //Wrapper the 'mealList' with the card UI component
};
export default AvailableMeals;
