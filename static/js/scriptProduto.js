const starsInput = document.querySelectorAll('.radio__inputs input');
const starsLabel = document.querySelectorAll('.radio__inputs img');

document.addEventListener('DOMContentLoaded',()=>{
    starsInput.forEach((element,index)=>{
        element.addEventListener('click', ()=>markStar(index));
    });
    document.querySelector('.quantity__button--decrease').addEventListener('click',decreaseQuantity);
    document.querySelector('.quantity__button--increase').addEventListener('click',increaseQuantity);
});

const decreaseQuantity = ()=>{
    const inputElem = document.querySelector('#productQuantity');
    let value = parseInt(inputElem.value);
    if(value>1)inputElem.value = value-1;
};

const increaseQuantity = ()=>{
    const inputElem = document.querySelector('#productQuantity');
    let value = parseInt(inputElem.value);
    if(value>=1)inputElem.value = value+1;
};


const markStar = (index)=>{
    starsLabel.forEach(label=>label.src='/static/images/empity_star.svg');
    for(let i=0;i<=index;i++){
        starsLabel[i].src = '/static/images/full_star.svg';
    }
};

