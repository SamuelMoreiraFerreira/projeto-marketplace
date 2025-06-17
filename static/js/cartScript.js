import { fetchApi } from './fetchFunction.js';

async function renderCart ()
{

    let cart = await fetchApi('/api/cart/');
    cart = cart.data;

    console.log(cart);

}

document.addEventListener('DOMContentLoaded', async function () {

    await renderCart();

});