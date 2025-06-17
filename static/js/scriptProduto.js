//#region Stars

const starsInput = document.querySelectorAll('.radio__inputs input');
const starsLabel = document.querySelectorAll('.radio__inputs img');
const rating = 0;

document.addEventListener('DOMContentLoaded',()=>{
    starsInput.forEach((element,index)=>{
        element.addEventListener('click', ()=>markStar(index));
    });
    document.querySelector('.quantity__button--decrease').addEventListener('click',decreaseQuantity);
    document.querySelector('.quantity__button--increase').addEventListener('click',increaseQuantity);
});

const decreaseQuantity = ()=> {

    const inputElem = document.querySelector('#productQuantity');
    let value = parseInt(inputElem.value);
    
    if (value > 1)inputElem.value = value - 1;

};

const increaseQuantity = ()=> {

    const inputElem = document.querySelector('#productQuantity');
    let value = parseInt(inputElem.value);

    if (value >= 1) inputElem.value = value+1;

};


const markStar = (index)=> {

    console.log(index);

    starsLabel.forEach(label=>label.src='/static/images/empity_star.svg');

    for (let i = 0; i <= index; i++)
    {
        starsLabel[i].src = '/static/images/full_star.svg';
    }

};

//#endregion

import { fetchApi } from './fetchFunction.js';

const purchaseButton = document.querySelector('.product__button');
const quantity = document.getElementById('productQuantity');

document.addEventListener('DOMContentLoaded', function () {

    purchaseButton.addEventListener('click', async function () {

        const response = await fetchApi('/api/users/logged');

        if (response?.data?.is_logged == true)
        {

            const url = window.location.pathname.split('/');

            const cart = await fetchApi(`/api/carts/get-by-user`);

            const added = await fetchApi(`/api/carts/add-item/${cart.data.cart_id}?product_id=${url[url.length - 1]}&quantity=${quantity.value}`);

            if (added.status_code == 200)
            {

                console.log('FUNCIONOU PORRA');

                // SWEET ALERT DE CONFIRMAÇÃO
            }

            else
            {

                console.log('ALGUMA COISA DEU ERRADO');

                // SWAL ERRO
            }

        }

        else
        {
            location.href = '/login';
        }

    });

});