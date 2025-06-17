//#region Stars

const starsInput = document.querySelectorAll('.radio__inputs input');
const starsLabel = document.querySelectorAll('.radio__inputs img');
let rating = 0;

document.addEventListener('DOMContentLoaded', () => {
    starsInput.forEach((element, index) => {
        element.addEventListener('click', () => markStar(index));
    });
    document.querySelector('.quantity__button--decrease').addEventListener('click', decreaseQuantity);
    document.querySelector('.quantity__button--increase').addEventListener('click', increaseQuantity);
});

const decreaseQuantity = () => {

    const inputElem = document.querySelector('#productQuantity');
    let value = parseInt(inputElem.value);

    if (value > 1) inputElem.value = value - 1;

};

const increaseQuantity = () => {

    const inputElem = document.querySelector('#productQuantity');
    let value = parseInt(inputElem.value);

    if (value >= 1) inputElem.value = value + 1;

};


const markStar = (index) => {

    rating = index;

    starsLabel.forEach(label => label.src = '/static/images/empity_star.svg');

    for (let i = 0; i <= index; i++) {
        starsLabel[i].src = '/static/images/full_star.svg';
    }

};

//#endregion

import { fetchApi } from './fetchFunction.js';

const purchaseButton = document.querySelector('.product__button');
const quantity = document.getElementById('productQuantity');

const commentButton = document.querySelector('.user-comment__button');
const messageInput = document.querySelector('.user-comment__comment');

document.addEventListener('DOMContentLoaded', async function () {

    const response = (await fetchApi('/api/users/logged')).data;

        commentButton.addEventListener('click', async function (event) {
        
        event.preventDefault();

        const url = window.location.pathname.split('/');
        const productID = url[url.length - 1];

        const comment = await fetchApi(`/api/comments/create/${productID}`, {

            method: 'POST',

            headers: {
                'Content-Type': 'application/json'
            },

            body: JSON.stringify({

                message: messageInput.value,
                rating: (rating + 1),
                user_email: response.user_data.email

            })

        });

        console.log(comment)

        if (comment.status_code == 200)
        {
            window.location.reload();
        }

        else
        {
            Swal.fire({
                title: "Erro!",
                icon: "error",
                timer: 2000
            });
        }

    });

    purchaseButton.addEventListener('click', async function () {

        if (!response?.is_logged)
        {
            location.href = '/login';
        }

        const cart = await fetchApi(`/api/carts/get-by-user`);

        console.log(cart);

        const added = await fetchApi(`/api/carts/add-item/${cart.data.cart_id}?product_id=${productID}&quantity=${quantity.value}`);

        if (added.status_code == 200)
        {
            Swal.fire({
                title: "Sucesso!",
                icon: "sucess",
                timer: 2000
            });
        }

        else
        {
            Swal.fire({
                title: "Erro!",
                icon: "error",
                timer: 2000
            });
        }

    });

});