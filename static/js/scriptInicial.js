//#region Carrosel

// $('.carousel').carousel({

//     interval: 2000

// });

//#endregion

import { renderProducts } from "./renderProducts.js";

const highlightsContainer = document.querySelector('.main__destaques');

async function getHighlights() 
{

    let request = await fetch('/api/products/get-highlights/4');
    request = await request.json();

    if (request.status_code != 200) return false;

    return request.data;

}

document.addEventListener('DOMContentLoaded', async function () {

    // Destaques

    const highlights = await getHighlights();
    renderProducts(highlights, highlightsContainer);

});