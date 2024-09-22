const ButtonIcon = (props) => {
  return (
    <span className={props.className}>
      <svg
        width="20"
        height="20"
        viewBox="0 0 20 20"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d="M10 0C15.5228 0 20 4.47715 20 10C20 15.5228 15.5228 20 10 20C4.47715 20 0 15.5228 0 10C0 4.47715 4.47715 0 10 0ZM10 1.5C5.30558 1.5 1.5 5.30558 1.5 10C1.5 14.6944 5.30558 18.5 10 18.5C14.6944 18.5 18.5 14.6944 18.5 10C18.5 5.30558 14.6944 1.5 10 1.5ZM10 5C10.4142 5 10.75 5.33579 10.75 5.75V9.25H14.25C14.6642 9.25 15 9.5858 15 10C15 10.4142 14.6642 10.75 14.25 10.75H10.75V14.25C10.75 14.6642 10.4142 15 10 15C9.5858 15 9.25 14.6642 9.25 14.25V10.75H5.75C5.33579 10.75 5 10.4142 5 10C5 9.5858 5.33579 9.25 5.75 9.25H9.25V5.75C9.25 5.33579 9.5858 5 10 5Z"
          fill="white"
        />
      </svg>
    </span>
  );
};
//We can add the ButtonIcon here because this icon is for the cart(also in header btn)
export default ButtonIcon;
